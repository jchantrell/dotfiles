#!/usr/bin/env bun
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { registerLocalTools } from "./src/tools-local.ts";
import { registerGitHubTools } from "./src/tools-github.ts";

const server = new McpServer({
  name: "repo-tools",
  version: "1.0.0",
}, {
  capabilities: {
    tools: {},
  },
});

registerLocalTools(server);
registerGitHubTools(server);

const transport = new StdioServerTransport();
await server.connect(transport);
