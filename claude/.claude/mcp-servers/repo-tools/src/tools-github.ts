import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import { parseRepoUrl } from "./repo-cache.ts";
import { textResult, errorResult, truncate } from "./helpers.ts";

const GITHUB_API = "https://api.github.com";

async function fetchGH(path: string): Promise<Response> {
  const headers: Record<string, string> = {
    Accept: "application/vnd.github.v3+json",
    "User-Agent": "repo-tools-mcp",
  };

  const token = process.env.GITHUB_TOKEN ?? process.env.GH_TOKEN;
  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  const res = await fetch(`${GITHUB_API}${path}`, { headers });
  if (!res.ok) {
    throw new Error(`GitHub API ${res.status}: ${res.statusText} for ${path}`);
  }
  return res;
}

async function fetchRaw(owner: string, repo: string, path: string): Promise<string> {
  const token = process.env.GITHUB_TOKEN ?? process.env.GH_TOKEN;
  const headers: Record<string, string> = {
    "User-Agent": "repo-tools-mcp",
  };
  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  const res = await fetch(
    `https://raw.githubusercontent.com/${owner}/${repo}/HEAD/${path}`,
    { headers }
  );
  if (!res.ok) {
    throw new Error(`Failed to fetch ${path}: ${res.status} ${res.statusText}`);
  }
  return res.text();
}

// Tech stack detection based on files
function detectTechStack(files: string[]): string[] {
  const stack: string[] = [];
  const fileSet = new Set(files);
  const hasFile = (name: string) => fileSet.has(name);
  const hasExt = (ext: string) => files.some((f) => f.endsWith(ext));

  if (hasFile("package.json")) stack.push("Node.js");
  if (hasFile("tsconfig.json")) stack.push("TypeScript");
  if (hasFile("bun.lockb") || hasFile("bunfig.toml")) stack.push("Bun");
  if (hasFile("deno.json") || hasFile("deno.jsonc")) stack.push("Deno");
  if (hasFile("next.config.js") || hasFile("next.config.mjs") || hasFile("next.config.ts")) stack.push("Next.js");
  if (hasFile("nuxt.config.ts") || hasFile("nuxt.config.js")) stack.push("Nuxt");
  if (hasFile("svelte.config.js")) stack.push("SvelteKit");
  if (hasFile("astro.config.mjs") || hasFile("astro.config.ts")) stack.push("Astro");
  if (hasFile("vite.config.ts") || hasFile("vite.config.js")) stack.push("Vite");
  if (hasFile("webpack.config.js")) stack.push("Webpack");
  if (hasFile("Cargo.toml")) stack.push("Rust");
  if (hasFile("go.mod")) stack.push("Go");
  if (hasFile("pyproject.toml") || hasFile("setup.py") || hasFile("requirements.txt")) stack.push("Python");
  if (hasFile("Gemfile")) stack.push("Ruby");
  if (hasFile("pom.xml") || hasFile("build.gradle") || hasFile("build.gradle.kts")) stack.push("Java/Kotlin");
  if (hasFile("Dockerfile") || hasFile("docker-compose.yml") || hasFile("docker-compose.yaml")) stack.push("Docker");
  if (hasFile(".github/workflows")) stack.push("GitHub Actions");
  if (hasExt(".swift")) stack.push("Swift");
  if (hasFile("Makefile")) stack.push("Make");
  if (hasFile("flake.nix")) stack.push("Nix");
  if (hasFile("Earthfile")) stack.push("Earthly");

  return stack;
}

interface TreeEntry {
  path: string;
  type: string;
  size?: number;
}

export function registerGitHubTools(server: McpServer): void {
  // ─── gh_structure ─────────────────────────────────────────
  server.tool(
    "gh_structure",
    "Get repo structure via GitHub API with tech stack detection",
    {
      repo: z.string().describe("GitHub repo"),
      depth: z.number().optional().describe("Directory depth (default 2)"),
    },
    async ({ repo, depth }) => {
      try {
        const { owner, repo: repoName } = parseRepoUrl(repo);
        const maxDepth = depth ?? 2;

        const res = await fetchGH(`/repos/${owner}/${repoName}/git/trees/HEAD?recursive=1`);
        const data = (await res.json()) as { tree: TreeEntry[]; truncated: boolean };

        const rootFiles = data.tree
          .filter((e) => !e.path.includes("/"))
          .map((e) => e.path);

        const stack = detectTechStack(rootFiles);

        const filtered = data.tree.filter((e) => {
          const depth = e.path.split("/").length;
          return depth <= maxDepth;
        });

        const dirs = filtered
          .filter((e) => e.type === "tree")
          .map((e) => `  ${e.path}/`)
          .join("\n");

        const files = filtered
          .filter((e) => e.type === "blob")
          .map((e) => {
            const size = e.size ? ` (${formatSize(e.size)})` : "";
            return `  ${e.path}${size}`;
          })
          .join("\n");

        return textResult(
          [
            `## ${owner}/${repoName}`,
            stack.length > 0 ? `Tech Stack: ${stack.join(", ")}` : "",
            data.truncated ? "(tree truncated by GitHub API)" : "",
            "",
            "### Directories",
            dirs || "(none)",
            "",
            "### Files",
            files || "(none)",
          ]
            .filter(Boolean)
            .join("\n")
        );
      } catch (err: unknown) {
        return errorResult(err instanceof Error ? err.message : String(err));
      }
    }
  );

  // ─── gh_readme ────────────────────────────────────────────
  server.tool(
    "gh_readme",
    "Get the README of a GitHub repo",
    {
      repo: z.string().describe("GitHub repo"),
      maxLength: z.number().optional().describe("Max content length (default 5000)"),
    },
    async ({ repo, maxLength }) => {
      try {
        const { owner, repo: repoName } = parseRepoUrl(repo);
        const max = maxLength ?? 5000;

        const candidates = ["README.md", "readme.md", "README", "README.rst", "Readme.md"];
        for (const candidate of candidates) {
          try {
            const content = await fetchRaw(owner, repoName, candidate);
            return textResult(truncate(content, max));
          } catch {
            continue;
          }
        }

        return errorResult("No README found.");
      } catch (err: unknown) {
        return errorResult(err instanceof Error ? err.message : String(err));
      }
    }
  );

  // ─── gh_file ──────────────────────────────────────────────
  server.tool(
    "gh_file",
    "Get a specific file from GitHub via raw content",
    {
      repo: z.string().describe("GitHub repo"),
      path: z.string().describe("File path in repo"),
      maxLength: z.number().optional().describe("Max content length (default 10000)"),
    },
    async ({ repo, path, maxLength }) => {
      try {
        const { owner, repo: repoName } = parseRepoUrl(repo);
        const max = maxLength ?? 10000;
        const content = await fetchRaw(owner, repoName, path);
        return textResult(truncate(content, max));
      } catch (err: unknown) {
        return errorResult(err instanceof Error ? err.message : String(err));
      }
    }
  );

  // ─── gh_tree ──────────────────────────────────────────────
  server.tool(
    "gh_tree",
    "Directory tree via GitHub API with visual connectors",
    {
      repo: z.string().describe("GitHub repo"),
      path: z.string().optional().describe("Subdirectory path"),
      maxDepth: z.number().optional().describe("Max depth (default 3)"),
    },
    async ({ repo, path, maxDepth }) => {
      try {
        const { owner, repo: repoName } = parseRepoUrl(repo);
        const depth = maxDepth ?? 3;
        const prefix = path ?? "";

        const res = await fetchGH(`/repos/${owner}/${repoName}/git/trees/HEAD?recursive=1`);
        const data = (await res.json()) as { tree: TreeEntry[]; truncated: boolean };

        const filtered = data.tree.filter((e) => {
          if (prefix && !e.path.startsWith(prefix + "/") && e.path !== prefix) return false;
          const relPath = prefix ? e.path.slice(prefix.length + 1) : e.path;
          if (!relPath) return false;
          return relPath.split("/").length <= depth;
        });

        // Build tree with connectors
        const lines = buildTreeLines(filtered, prefix);
        const header = prefix ? `${owner}/${repoName}/${prefix}` : `${owner}/${repoName}`;

        return textResult(`${header}\n${lines.join("\n")}`);
      } catch (err: unknown) {
        return errorResult(err instanceof Error ? err.message : String(err));
      }
    }
  );

  // ─── gh_search ────────────────────────────────────────────
  server.tool(
    "gh_search",
    "Search code in a repo via GitHub Search API",
    {
      repo: z.string().describe("GitHub repo"),
      query: z.string().describe("Search query"),
      maxResults: z.number().optional().describe("Max results (default 10)"),
    },
    async ({ repo, query, maxResults }) => {
      try {
        const { owner, repo: repoName } = parseRepoUrl(repo);
        const max = maxResults ?? 10;

        const q = encodeURIComponent(`${query} repo:${owner}/${repoName}`);
        const res = await fetchGH(`/search/code?q=${q}&per_page=${max}`);
        const data = (await res.json()) as {
          total_count: number;
          items: Array<{
            name: string;
            path: string;
            html_url: string;
            text_matches?: Array<{ fragment: string }>;
          }>;
        };

        if (data.items.length === 0) {
          return textResult("No results found.");
        }

        const results = data.items
          .map((item) => {
            const fragments = item.text_matches
              ?.map((m) => `    ${m.fragment.trim()}`)
              .join("\n");
            return `${item.path}\n  ${item.html_url}${fragments ? "\n" + fragments : ""}`;
          })
          .join("\n\n");

        return textResult(
          `Found ${data.total_count} results (showing ${data.items.length}):\n\n${results}`
        );
      } catch (err: unknown) {
        return errorResult(err instanceof Error ? err.message : String(err));
      }
    }
  );
}

function formatSize(bytes: number): string {
  if (bytes < 1024) return `${bytes}B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)}KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)}MB`;
}

function buildTreeLines(entries: TreeEntry[], prefix: string): string[] {
  // Group by parent directory
  interface TreeNode {
    name: string;
    isDir: boolean;
    children: TreeNode[];
  }

  const root: TreeNode = { name: "", isDir: true, children: [] };

  for (const entry of entries) {
    const relPath = prefix ? entry.path.slice(prefix.length + 1) : entry.path;
    if (!relPath) continue;

    const parts = relPath.split("/");
    let current = root;

    for (let i = 0; i < parts.length; i++) {
      const part = parts[i]!;
      const isLast = i === parts.length - 1;
      let child = current.children.find((c) => c.name === part);

      if (!child) {
        child = {
          name: part,
          isDir: !isLast || entry.type === "tree",
          children: [],
        };
        current.children.push(child);
      }

      current = child;
    }
  }

  const lines: string[] = [];

  function render(node: TreeNode, indent: string, isLast: boolean): void {
    const connector = isLast ? "└── " : "├── ";
    const suffix = node.isDir ? "/" : "";
    lines.push(`${indent}${connector}${node.name}${suffix}`);

    const childIndent = indent + (isLast ? "    " : "│   ");
    node.children.sort((a, b) => {
      if (a.isDir !== b.isDir) return a.isDir ? -1 : 1;
      return a.name.localeCompare(b.name);
    });

    for (let i = 0; i < node.children.length; i++) {
      render(node.children[i]!, childIndent, i === node.children.length - 1);
    }
  }

  root.children.sort((a, b) => {
    if (a.isDir !== b.isDir) return a.isDir ? -1 : 1;
    return a.name.localeCompare(b.name);
  });

  for (let i = 0; i < root.children.length; i++) {
    render(root.children[i]!, "", i === root.children.length - 1);
  }

  return lines;
}
