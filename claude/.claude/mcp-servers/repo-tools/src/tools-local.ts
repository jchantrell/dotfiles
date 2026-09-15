import { $ } from "bun";
import { readdir, stat, readFile, rm } from "node:fs/promises";
import { join, extname } from "node:path";
import { existsSync } from "node:fs";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import { ensureRepo, getCacheDir, parseRepoUrl } from "./repo-cache.ts";
import { textResult, errorResult, safeRun } from "./helpers.ts";

export function registerLocalTools(server: McpServer): void {
  // ─── repo_clone ───────────────────────────────────────────
  server.tool(
    "repo_clone",
    "Clone or update a GitHub repo locally and return basic stats",
    {
      repo: z.string().describe("GitHub repo (owner/repo, URL, or git@ SSH)"),
      refresh: z.boolean().optional().describe("Force refresh even if cached"),
    },
    async ({ repo, refresh }) => {
      return (await safeRun(async () => {
        const info = await ensureRepo(repo, refresh ?? false);

        // Basic stats: file count + top extensions
        const result =
          await $`find ${info.path} -not -path '*/.git/*' -type f`.quiet();
        const files = result.stdout
          .toString()
          .trim()
          .split("\n")
          .filter(Boolean);

        const extCounts = new Map<string, number>();
        for (const f of files) {
          const ext = extname(f) || "(no ext)";
          extCounts.set(ext, (extCounts.get(ext) ?? 0) + 1);
        }

        const topExts = [...extCounts.entries()]
          .sort((a, b) => b[1] - a[1])
          .slice(0, 15)
          .map(([ext, count]) => `  ${ext}: ${count}`)
          .join("\n");

        return textResult(
          [
            `Repository: ${info.owner}/${info.repo}`,
            `Path: ${info.path}`,
            `Cached: ${info.cached}`,
            `Total files: ${files.length}`,
            `\nTop extensions:\n${topExts}`,
          ].join("\n")
        );
      })) as Awaited<ReturnType<typeof textResult>>;
    }
  );

  // ─── repo_structure ───────────────────────────────────────
  server.tool(
    "repo_structure",
    "Show directory tree of a cloned GitHub repo",
    {
      repo: z.string().describe("GitHub repo"),
      path: z.string().optional().describe("Subpath within the repo"),
      depth: z.number().optional().describe("Tree depth (default 4)"),
    },
    async ({ repo, path, depth }) => {
      return (await safeRun(async () => {
        const info = await ensureRepo(repo);
        const targetPath = path ? join(info.path, path) : info.path;
        const maxDepth = depth ?? 4;

        // Use eza --tree if available, fallback to find-based tree
        try {
          const result =
            await $`eza --tree --level=${maxDepth} --ignore-glob='.git|node_modules|dist|build|.next|__pycache__|.venv|target' ${targetPath}`.quiet();
          return textResult(result.stdout.toString());
        } catch {
          // Fallback: find-based listing
          const result =
            await $`find ${targetPath} -maxdepth ${maxDepth} -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/.next/*' -not -path '*/__pycache__/*' -not -path '*/.venv/*' -not -path '*/target/*' | sort`.quiet();
          return textResult(result.stdout.toString());
        }
      })) as Awaited<ReturnType<typeof textResult>>;
    }
  );

  // ─── repo_search ──────────────────────────────────────────
  server.tool(
    "repo_search",
    "Ripgrep search in a cloned repo",
    {
      repo: z.string().describe("GitHub repo"),
      pattern: z.string().describe("Search pattern (regex)"),
      fileGlob: z.string().optional().describe("File glob filter (e.g. '*.ts')"),
      context: z.number().optional().describe("Context lines (default 2)"),
      maxResults: z.number().optional().describe("Max results (default 50)"),
    },
    async ({ repo, pattern, fileGlob, context, maxResults }) => {
      return (await safeRun(async () => {
        const info = await ensureRepo(repo);
        const ctx = context ?? 2;
        const max = maxResults ?? 50;

        const args = [
          "--no-heading",
          "--line-number",
          "--color=never",
          `-C${ctx}`,
          `-m${max}`,
        ];
        if (fileGlob) args.push(`--glob=${fileGlob}`);
        args.push(pattern, info.path);

        const result = await $`rg ${args}`.quiet().nothrow();
        const output = result.stdout.toString().trim();
        if (!output) return textResult("No matches found.");
        return textResult(output);
      })) as Awaited<ReturnType<typeof textResult>>;
    }
  );

  // ─── repo_deps ────────────────────────────────────────────
  server.tool(
    "repo_deps",
    "Analyze dependencies of a cloned repo",
    {
      repo: z.string().describe("GitHub repo"),
    },
    async ({ repo }) => {
      return (await safeRun(async () => {
        const info = await ensureRepo(repo);
        const sections: string[] = [];

        // package.json
        const pkgPath = join(info.path, "package.json");
        if (existsSync(pkgPath)) {
          const pkg = JSON.parse(await readFile(pkgPath, "utf-8"));
          const formatDeps = (deps: Record<string, string> | undefined, label: string) => {
            if (!deps || Object.keys(deps).length === 0) return "";
            return `${label}:\n${Object.entries(deps)
              .map(([k, v]) => `  ${k}: ${v}`)
              .join("\n")}`;
          };
          sections.push(
            "## package.json",
            formatDeps(pkg.dependencies, "Dependencies"),
            formatDeps(pkg.devDependencies, "Dev Dependencies"),
            formatDeps(pkg.peerDependencies, "Peer Dependencies")
          );
        }

        // requirements.txt
        const reqPath = join(info.path, "requirements.txt");
        if (existsSync(reqPath)) {
          const content = await readFile(reqPath, "utf-8");
          sections.push(`## requirements.txt\n${content.trim()}`);
        }

        // pyproject.toml
        const pyPath = join(info.path, "pyproject.toml");
        if (existsSync(pyPath)) {
          const content = await readFile(pyPath, "utf-8");
          sections.push(`## pyproject.toml\n${content.trim()}`);
        }

        // go.mod
        const goPath = join(info.path, "go.mod");
        if (existsSync(goPath)) {
          const content = await readFile(goPath, "utf-8");
          sections.push(`## go.mod\n${content.trim()}`);
        }

        // Cargo.toml
        const cargoPath = join(info.path, "Cargo.toml");
        if (existsSync(cargoPath)) {
          const content = await readFile(cargoPath, "utf-8");
          sections.push(`## Cargo.toml\n${content.trim()}`);
        }

        if (sections.length === 0) {
          return textResult("No recognized dependency files found.");
        }

        return textResult(sections.filter(Boolean).join("\n\n"));
      })) as Awaited<ReturnType<typeof textResult>>;
    }
  );

  // ─── repo_hotspots ────────────────────────────────────────
  server.tool(
    "repo_hotspots",
    "Find code hotspots: churn, large files, TODOs, recent commits",
    {
      repo: z.string().describe("GitHub repo"),
    },
    async ({ repo }) => {
      return (await safeRun(async () => {
        const info = await ensureRepo(repo);
        const p = info.path;

        const [churn, largest, todos, recent] = await Promise.all([
          // Git churn: most changed files
          $`git -C ${p} log --format=format: --name-only --diff-filter=ACRM | sort | uniq -c | sort -rn | head -20`
            .quiet()
            .nothrow()
            .then((r) => r.stdout.toString().trim()),

          // Largest files
          $`find ${p} -not -path '*/.git/*' -not -path '*/node_modules/*' -type f -exec wc -c {} + | sort -rn | head -20`
            .quiet()
            .nothrow()
            .then((r) => r.stdout.toString().trim()),

          // TODO/FIXME counts
          $`rg --no-heading --count-matches 'TODO|FIXME|HACK|XXX' ${p} --glob='!.git/*' --glob='!node_modules/*'`
            .quiet()
            .nothrow()
            .then((r) =>
              r.stdout
                .toString()
                .trim()
                .split("\n")
                .filter(Boolean)
                .sort((a, b) => {
                  const countA = parseInt(a.split(":").pop() ?? "0");
                  const countB = parseInt(b.split(":").pop() ?? "0");
                  return countB - countA;
                })
                .slice(0, 20)
                .join("\n")
            ),

          // Recent commits
          $`git -C ${p} log --oneline -20`.quiet().nothrow().then((r) => r.stdout.toString().trim()),
        ]);

        return textResult(
          [
            "## Most Changed Files (git churn)",
            churn || "(none)",
            "",
            "## Largest Files",
            largest || "(none)",
            "",
            "## TODO/FIXME Hotspots",
            todos || "(none)",
            "",
            "## Recent Commits",
            recent || "(none)",
          ].join("\n")
        );
      })) as Awaited<ReturnType<typeof textResult>>;
    }
  );

  // ─── repo_stats ───────────────────────────────────────────
  server.tool(
    "repo_stats",
    "Lines of code statistics using tokei (or fallback)",
    {
      repo: z.string().describe("GitHub repo"),
    },
    async ({ repo }) => {
      return (await safeRun(async () => {
        const info = await ensureRepo(repo);

        // Try tokei first, then scc, then fallback
        for (const cmd of ["tokei", "scc"]) {
          try {
            const result = await $`${cmd} ${info.path}`.quiet();
            return textResult(result.stdout.toString());
          } catch {
            continue;
          }
        }

        // Fallback: basic line count by extension
        const result =
          await $`find ${info.path} -not -path '*/.git/*' -not -path '*/node_modules/*' -type f -name '*.ts' -o -name '*.js' -o -name '*.py' -o -name '*.go' -o -name '*.rs' -o -name '*.java' -o -name '*.c' -o -name '*.cpp' -o -name '*.rb' | xargs wc -l 2>/dev/null | sort -rn | head -30`
            .quiet()
            .nothrow();
        return textResult(
          "## Line Counts (fallback - install tokei for full stats)\n" +
            result.stdout.toString().trim()
        );
      })) as Awaited<ReturnType<typeof textResult>>;
    }
  );

  // ─── repo_secrets ─────────────────────────────────────────
  server.tool(
    "repo_secrets",
    "Scan for leaked secrets using gitleaks",
    {
      repo: z.string().describe("GitHub repo"),
    },
    async ({ repo }) => {
      return (await safeRun(async () => {
        const info = await ensureRepo(repo);

        try {
          const result =
            await $`gitleaks detect --source=${info.path} --no-banner --no-color -v`
              .quiet()
              .nothrow();
          const output = result.stdout.toString().trim();
          const stderr = result.stderr.toString().trim();

          if (result.exitCode === 0) {
            return textResult("No secrets detected.");
          }
          return textResult(output || stderr || "Scan complete (check exit code).");
        } catch {
          return errorResult(
            "gitleaks is not installed. Install it: https://github.com/gitleaks/gitleaks#installing"
          );
        }
      })) as Awaited<ReturnType<typeof textResult>>;
    }
  );

  // ─── repo_file ────────────────────────────────────────────
  server.tool(
    "repo_file",
    "Read a file from a cloned repo with optional line range",
    {
      repo: z.string().describe("GitHub repo"),
      path: z.string().describe("File path relative to repo root"),
      startLine: z.number().optional().describe("Start line (1-based)"),
      endLine: z.number().optional().describe("End line (1-based)"),
    },
    async ({ repo, path, startLine, endLine }) => {
      return (await safeRun(async () => {
        const info = await ensureRepo(repo);
        const filePath = join(info.path, path);

        if (!existsSync(filePath)) {
          return errorResult(`File not found: ${path}`);
        }

        const content = await readFile(filePath, "utf-8");
        const lines = content.split("\n");

        const start = (startLine ?? 1) - 1;
        const end = endLine ?? lines.length;
        const selected = lines.slice(start, end);

        const numbered = selected
          .map((line, i) => `${String(start + i + 1).padStart(5)} | ${line}`)
          .join("\n");

        return textResult(numbered);
      })) as Awaited<ReturnType<typeof textResult>>;
    }
  );

  // ─── repo_blame ───────────────────────────────────────────
  server.tool(
    "repo_blame",
    "Git blame for a file in a cloned repo",
    {
      repo: z.string().describe("GitHub repo"),
      path: z.string().describe("File path relative to repo root"),
      startLine: z.number().optional().describe("Start line"),
      endLine: z.number().optional().describe("End line"),
    },
    async ({ repo, path, startLine, endLine }) => {
      return (await safeRun(async () => {
        const info = await ensureRepo(repo);
        const args = ["blame", "--no-color"];

        if (startLine && endLine) {
          args.push(`-L${startLine},${endLine}`);
        } else if (startLine) {
          args.push(`-L${startLine},+50`);
        }

        args.push(path);

        const result = await $`git -C ${info.path} ${args}`.quiet().nothrow();
        const output = result.stdout.toString().trim();
        if (result.exitCode !== 0) {
          return errorResult(result.stderr.toString().trim() || "git blame failed");
        }
        return textResult(output);
      })) as Awaited<ReturnType<typeof textResult>>;
    }
  );

  // ─── repo_find ────────────────────────────────────────────
  server.tool(
    "repo_find",
    "Fast file finding with fd in a cloned repo",
    {
      repo: z.string().describe("GitHub repo"),
      pattern: z.string().describe("Search pattern"),
      type: z
        .enum(["f", "d", "l", "x"])
        .optional()
        .describe("Type: f=file, d=directory, l=symlink, x=executable"),
      extension: z.string().optional().describe("Filter by extension"),
    },
    async ({ repo, pattern, type, extension }) => {
      return (await safeRun(async () => {
        const info = await ensureRepo(repo);
        const args = [
          "--no-ignore-vcs",
          "--exclude=.git",
          "--exclude=node_modules",
          "--color=never",
        ];

        if (type) args.push(`--type=${type}`);
        if (extension) args.push(`--extension=${extension}`);
        args.push(pattern, info.path);

        const result = await $`fd ${args}`.quiet().nothrow();
        const output = result.stdout.toString().trim();
        if (!output) return textResult("No files found.");
        return textResult(output);
      })) as Awaited<ReturnType<typeof textResult>>;
    }
  );

  // ─── repo_exports ─────────────────────────────────────────
  server.tool(
    "repo_exports",
    "Map public API exports of a repo (JS/TS)",
    {
      repo: z.string().describe("GitHub repo"),
      entryPoint: z
        .string()
        .optional()
        .describe("Entry point file (e.g. 'src/index.ts')"),
    },
    async ({ repo, entryPoint }) => {
      return (await safeRun(async () => {
        const info = await ensureRepo(repo);

        // Find exports using rg
        const searchPaths = entryPoint
          ? [join(info.path, entryPoint)]
          : [info.path];

        const globArgs = entryPoint ? [] : ["--glob=*.{ts,tsx,js,jsx,mts,mjs}"];

        const [namedExports, defaultExports, reExports] = await Promise.all([
          // Named exports
          $`rg --no-heading --line-number --color=never ${globArgs} 'export (const|function|class|type|interface|enum|let|var) ' ${searchPaths}`
            .quiet()
            .nothrow()
            .then((r) => r.stdout.toString().trim()),

          // Default exports
          $`rg --no-heading --line-number --color=never ${globArgs} 'export default ' ${searchPaths}`
            .quiet()
            .nothrow()
            .then((r) => r.stdout.toString().trim()),

          // Re-exports
          $`rg --no-heading --line-number --color=never ${globArgs} "export .* from " ${searchPaths}`
            .quiet()
            .nothrow()
            .then((r) => r.stdout.toString().trim()),
        ]);

        return textResult(
          [
            "## Named Exports",
            namedExports || "(none)",
            "",
            "## Default Exports",
            defaultExports || "(none)",
            "",
            "## Re-exports",
            reExports || "(none)",
          ].join("\n")
        );
      })) as Awaited<ReturnType<typeof textResult>>;
    }
  );

  // ─── repo_cleanup ─────────────────────────────────────────
  server.tool(
    "repo_cleanup",
    "Remove cloned repo(s) from cache",
    {
      repo: z
        .string()
        .describe('Repo to remove, or "all" to clear entire cache'),
    },
    async ({ repo }) => {
      return (await safeRun(async () => {
        if (repo === "all") {
          const cacheDir = getCacheDir();
          if (existsSync(cacheDir)) {
            await rm(cacheDir, { recursive: true, force: true });
          }
          return textResult("Cleared entire repo cache.");
        }

        const { owner, repo: repoName } = parseRepoUrl(repo);
        const repoPath = join(getCacheDir(), owner, repoName);
        if (existsSync(repoPath)) {
          await rm(repoPath, { recursive: true, force: true });
          return textResult(`Removed ${owner}/${repoName} from cache.`);
        }
        return textResult(`${owner}/${repoName} not found in cache.`);
      })) as Awaited<ReturnType<typeof textResult>>;
    }
  );
}
