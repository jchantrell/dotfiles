import type { CallToolResult } from "@modelcontextprotocol/sdk/types.js";

const MAX_OUTPUT = 30_000;

export function truncate(text: string, limit = MAX_OUTPUT): string {
  if (text.length <= limit) return text;
  const suffix = `\n\n... [truncated at ${limit} chars, ${text.length} total]`;
  return text.slice(0, limit - suffix.length) + suffix;
}

export function textResult(text: string): CallToolResult {
  return { content: [{ type: "text", text: truncate(text) }] };
}

export function errorResult(message: string): CallToolResult {
  return { content: [{ type: "text", text: `Error: ${message}` }], isError: true };
}

export async function safeRun<T>(fn: () => Promise<T>): Promise<T | CallToolResult> {
  try {
    return await fn();
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    return errorResult(msg);
  }
}
