import { $ } from "bun";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";

const CACHE_DIR = join(homedir(), ".claude", "mcp-servers", "repo-tools", ".cache");
const CACHE_TTL_MS = 5 * 60 * 1000; // 5 minutes

const lastFetchTimes = new Map<string, number>();

export interface RepoInfo {
  path: string;
  owner: string;
  repo: string;
  cached: boolean;
}

export function parseRepoUrl(input: string): { owner: string; repo: string } {
  // git@github.com:owner/repo.git
  const sshMatch = input.match(/git@github\.com:([^/]+)\/([^/.]+)(?:\.git)?$/);
  if (sshMatch) return { owner: sshMatch[1]!, repo: sshMatch[2]! };

  // https://github.com/owner/repo or github.com/owner/repo
  const httpMatch = input.match(
    /(?:https?:\/\/)?github\.com\/([^/]+)\/([^/.#?]+)/
  );
  if (httpMatch) return { owner: httpMatch[1]!, repo: httpMatch[2]! };

  // owner/repo
  const shortMatch = input.match(/^([^/\s]+)\/([^/\s]+)$/);
  if (shortMatch) return { owner: shortMatch[1]!, repo: shortMatch[2]! };

  throw new Error(
    `Cannot parse repo URL: "${input}". Expected owner/repo, github.com/owner/repo, https://github.com/owner/repo, or git@github.com:owner/repo`
  );
}

export async function ensureRepo(
  repoInput: string,
  forceRefresh = false
): Promise<RepoInfo> {
  const { owner, repo } = parseRepoUrl(repoInput);
  const repoPath = join(CACHE_DIR, owner, repo);
  const cacheKey = `${owner}/${repo}`;
  const lastFetch = lastFetchTimes.get(cacheKey) ?? 0;
  const isFresh = Date.now() - lastFetch < CACHE_TTL_MS;

  if (existsSync(join(repoPath, ".git"))) {
    if (!forceRefresh && isFresh) {
      return { path: repoPath, owner, repo, cached: true };
    }

    await $`git -C ${repoPath} fetch --all --prune`.quiet();
    await $`git -C ${repoPath} reset --hard origin/HEAD`.quiet();
    lastFetchTimes.set(cacheKey, Date.now());
    return { path: repoPath, owner, repo, cached: false };
  }

  await $`mkdir -p ${join(CACHE_DIR, owner)}`.quiet();
  await $`git clone --depth 100 https://github.com/${owner}/${repo}.git ${repoPath}`.quiet();
  lastFetchTimes.set(cacheKey, Date.now());
  return { path: repoPath, owner, repo, cached: false };
}

export function getRepoPath(repoInput: string): string {
  const { owner, repo } = parseRepoUrl(repoInput);
  return join(CACHE_DIR, owner, repo);
}

export function getCacheDir(): string {
  return CACHE_DIR;
}
