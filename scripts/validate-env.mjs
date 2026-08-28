import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

function normalize(version) {
  return String(version).trim().replace(/^v/, "");
}

function fail(message) {
  console.error(`ENV CHECK FAILED: ${message}`);
  process.exit(1);
}

function repoRoot() {
  const scriptDir = path.dirname(fileURLToPath(import.meta.url));
  return path.resolve(scriptDir, "..");
}

function readRequiredNodeVersion(rootDir) {
  const nvmrcPath = path.join(rootDir, ".nvmrc");
  if (!fs.existsSync(nvmrcPath)) {
    fail("Missing .nvmrc in repository root.");
  }

  const version = normalize(fs.readFileSync(nvmrcPath, "utf8"));
  if (!version) {
    fail(".nvmrc exists but does not contain a version.");
  }

  return version;
}

function readRequiredNpmVersion(rootDir) {
  const packageJsonPath = path.join(rootDir, "package.json");
  if (!fs.existsSync(packageJsonPath)) {
    fail("Missing package.json in repository root.");
  }

  const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf8"));
  const packageManager = String(packageJson.packageManager || "").trim();
  if (!packageManager) {
    fail("package.json is missing packageManager.");
  }

  const match = /^npm@(\d+\.\d+\.\d+)(?:\+[^\s]+)?$/.exec(packageManager);
  if (!match) {
    fail(`Unsupported packageManager format: ${packageManager}. Expected npm@x.y.z.`);
  }

  return normalize(match[1]);
}

function resolveNpmCliInvocation() {
  const npmExecPath = process.env.npm_execpath;
  if (npmExecPath) {
    return { command: process.execPath, args: [npmExecPath, "--version"] };
  }

  return {
    command: path.join(path.dirname(process.execPath), "npm"),
    args: ["--version"],
  };
}

function detectNpmVersion() {
  const userAgent = process.env.npm_config_user_agent;
  const npmMatch = userAgent ? /npm\/(\d+\.\d+\.\d+)/.exec(userAgent) : null;
  if (npmMatch?.[1]) {
    return normalize(npmMatch[1]);
  }

  const { command, args } = resolveNpmCliInvocation();
  try {
    return normalize(execFileSync(command, args, { encoding: "utf8" }));
  } catch {
    return "";
  }
}

function main() {
  const rootDir = repoRoot();
  const requiredNodeVersion = readRequiredNodeVersion(rootDir);
  const requiredNpmVersion = readRequiredNpmVersion(rootDir);

  const nodeVersion = normalize(process.version);
  const npmVersion = detectNpmVersion();

  if (nodeVersion !== requiredNodeVersion) {
    fail(`Node.js ${requiredNodeVersion} is required, found ${nodeVersion}.`);
  }

  if (!npmVersion) {
    fail("Unable to detect npm version. Run via 'npm run env:check' or ensure npm is on PATH.");
  }

  if (npmVersion !== requiredNpmVersion) {
    fail(`npm ${requiredNpmVersion} is required, found ${npmVersion}.`);
  }

  console.log(`ENV CHECK OK: node ${nodeVersion}, npm ${npmVersion}`);
}

main();
