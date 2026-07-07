#!/usr/bin/env node

const { execSync, spawnSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');
const https = require('https');

const BRANCH = process.env.ACP_BRANCH || 'dev';
const RAW = `https://raw.githubusercontent.com/Raza-learner/Runmote/${BRANCH}`;
const BIN_DIR = path.join(os.homedir(), '.local', 'bin');

function detectOS() {
  const platform = os.platform();
  if (platform === 'linux') return 'linux';
  if (platform === 'darwin') return 'darwin';
  if (platform === 'win32') return 'windows';
  console.error(`Error: unsupported platform (${platform})`);
  process.exit(1);
}

const OS = detectOS();

function log(msg) {
  console.log(`  ${msg}`);
}

function status(msg) {
  console.log(msg);
}

function run(cmd, opts = {}) {
  const defaults = { stdio: 'inherit', ...opts };
  try {
    execSync(cmd, defaults);
    return true;
  } catch {
    return false;
  }
}

function runCapture(cmd) {
  try {
    return execSync(cmd, { stdio: 'pipe', encoding: 'utf-8' }).trim();
  } catch {
    return '';
  }
}

function commandExists(name) {
  if (OS === 'windows') {
    return runCapture(`where ${name} 2>nul`).length > 0;
  }
  return runCapture(`command -v ${name} 2>/dev/null`).length > 0;
}

function npmPackageInstalled(pkg) {
  if (OS === 'windows') {
    return runCapture(`npm list -g ${pkg} --depth=0 2>nul`).includes(pkg);
  }
  return runCapture(`npm list -g ${pkg} --depth=0 2>/dev/null`).includes(pkg);
}

function npmInstallGlobal(pkg) {
  log(`Installing ${pkg}...`);
  return run(`npm install -g ${pkg}`);
}

function npmUninstallGlobal(pkg) {
  if (npmPackageInstalled(pkg)) {
    log(`Removing ${pkg}...`);
    run(`npm uninstall -g ${pkg}`);
  } else {
    log(`${pkg} not installed — skipping`);
  }
}

function download(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      if (res.statusCode !== 200) {
        reject(new Error(`HTTP ${res.statusCode} ${url}`));
        return;
      }
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => resolve(data));
    }).on('error', reject);
  });
}

function installSymlink(binName) {
  if (!commandExists(binName)) return;
  try {
    fs.mkdirSync(BIN_DIR, { recursive: true });
    const src = runCapture(`command -v ${binName}`);
    if (src) {
      if (OS === 'windows') {
        const cmdPath = path.join(BIN_DIR, `${binName}.cmd`);
        const npmPath = path.join(os.homedir(), 'AppData', 'Roaming', 'npm', `${binName}.cmd`);
        if (fs.existsSync(npmPath)) {
          fs.writeFileSync(cmdPath, `@echo off\r\n"${npmPath}" %*\r\n`);
          log(`${binName}.cmd added to ${BIN_DIR}`);
        }
      } else {
        const linkPath = path.join(BIN_DIR, binName);
        try { fs.unlinkSync(linkPath); } catch {}
        fs.symlinkSync(src, linkPath);
        log(`${binName} linked to ${BIN_DIR}`);
      }
    }
  } catch {}
}

function removeSymlink(binName) {
  if (OS === 'windows') {
    const cmdPath = path.join(BIN_DIR, `${binName}.cmd`);
    try { fs.unlinkSync(cmdPath); log(`${binName}.cmd removed from ${BIN_DIR}`); } catch {}
  } else {
    const linkPath = path.join(BIN_DIR, binName);
    try { fs.unlinkSync(linkPath); log(`${binName} symlink removed`); } catch {}
  }
}

function hasNpm() {
  return commandExists('npm');
}

async function installDaemon() {
  status('\n  Installing Runmote Daemon...\n');

  if (OS === 'windows') {
    status('  Downloading Windows installer...');
    try {
      const ps1 = await download(`${RAW}/scripts/install.ps1`);
      const tmp = path.join(os.tmpdir(), `acp-install-${Date.now()}.ps1`);
      fs.writeFileSync(tmp, ps1, 'utf-8');
      const env = { ...process.env };
      if (!env.ACP_ENABLE_AUTOSTART) env.ACP_ENABLE_AUTOSTART = 'true';
      if (env.ACP_ENABLE_AGENTS === undefined) env.ACP_ENABLE_AGENTS = 'true';
      const result = spawnSync('powershell.exe', [
        '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', tmp
      ], { stdio: 'inherit', env });
      fs.unlinkSync(tmp);
      if (result.status !== 0) {
        status('  Daemon installation failed');
        process.exit(1);
      }
    } catch (err) {
      status(`  Download failed: ${err.message}`);
      process.exit(1);
    }
  } else {
    try {
      const bashScript = await download(`${RAW}/scripts/install.sh`);
      const result = spawnSync('bash', [], {
        stdio: 'pipe',
        input: bashScript,
        encoding: 'utf-8',
        env: { ...process.env, ACP_ENABLE_AUTOSTART: 'true' }
      });
      if (result.status !== 0) {
        status('  Daemon installation failed');
        process.exit(1);
      }
    } catch (err) {
      status(`  Download failed: ${err.message}`);
      process.exit(1);
    }
  }
}

function installAgents() {
  status('\n  Installing Agent Adapters...\n');

  if (!hasNpm()) {
    log('npm not found. Install Node.js first: https://nodejs.org');
    return;
  }

  const checks = [
    { cli: 'codex',       pkg: '@agentclientprotocol/codex-acp' },
    { cli: 'claude',      pkg: '@agentclientprotocol/claude-agent-acp' },
    { cli: 'claude-code', pkg: '@agentclientprotocol/claude-agent-acp' },
  ];

  for (const { cli, pkg } of checks) {
    if (!commandExists(cli)) {
      log(`'${cli}' not found — skipping ${pkg}`);
      continue;
    }
    if (npmPackageInstalled(pkg)) {
      const ver = runCapture(`npm list -g ${pkg} --depth=0 2>/dev/null`).match(/@(\d+\.\d+\.\d+)/);
      log(`${pkg} v${ver ? ver[1] : '?'} already installed — skipping`);
    } else {
      log(`Found '${cli}' — installing ${pkg}...`);
      npmInstallGlobal(pkg);
    }
  }

  installSymlink('codex-acp');
  installSymlink('claude-agent-acp');
}

function removeAgents() {
  status('\n  Removing Agent Adapters...\n');

  npmUninstallGlobal('@agentclientprotocol/codex-acp');
  npmUninstallGlobal('@agentclientprotocol/claude-agent-acp');

  removeSymlink('codex-acp');
  removeSymlink('claude-agent-acp');
}

async function uninstall() {
  status('\n  Uninstalling Runmote...\n');

  removeAgents();

  if (OS === 'windows') {
    try {
      const ps1 = await download(`${RAW}/scripts/install.ps1`);
      const tmp = path.join(os.tmpdir(), `acp-remove-${Date.now()}.ps1`);
      fs.writeFileSync(tmp, ps1, 'utf-8');
      spawnSync('powershell.exe', [
        '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', tmp, '-Remove'
      ], { stdio: 'inherit' });
      fs.unlinkSync(tmp);
    } catch (err) {
      status(`  Download failed: ${err.message}`);
    }
  } else {
    if (commandExists('runmote')) {
      run('runmote uninstall');
    } else {
      status('  runmote not found — daemon may already be removed');
    }
  }
}

function getStatus() {
  status('\n  Runmote Installation Status');
  status('');

  for (const cli of ['codex', 'claude', 'claude-code']) {
    if (commandExists(cli)) {
      status(`  ${cli}: found (${runCapture(`command -v ${cli}`) || runCapture(`where ${cli}`)})`);
    } else {
      status(`  ${cli}: not found`);
    }
  }

  if (commandExists('runmote')) {
    status(`  runmote: found (${runCapture('command -v runmote')})`);
  } else {
    status('  runmote: not found');
  }

  status('');
  for (const pkg of ['@agentclientprotocol/codex-acp', '@agentclientprotocol/claude-agent-acp']) {
    const installed = npmPackageInstalled(pkg);
    if (installed) {
      const ver = runCapture(`npm list -g ${pkg} --depth=0`).match(/@(\d+\.\d+\.\d+)/);
      status(`  ${pkg}: installed (v${ver ? ver[1] : '?'})`);
    } else {
      status(`  ${pkg}: not installed`);
    }
  }
}

function help() {
  console.log(`
  Runmote Installer — universal cross-platform setup

  Usage:
    npx runmote                 Full install (daemon + agents)
    npx runmote daemon           Install daemon only
    npx runmote agents           Install agent adapters only
    npx runmote status           Show installation status
    npx runmote uninstall        Remove daemon + agents
    npx runmote --help           Show this help

  Environment variables:
    ACP_BRANCH              Git branch (default: dev)
    ACP_ENABLE_AUTOSTART    Enable auto-start (default: true)
    ACP_ENABLE_AGENTS       Enable agent setup (default: true)
    ACP_RELAY_URL           WebSocket URL of the relay server
    ACP_DAEMON_TOKEN        Auth token for daemon-relay authentication
    ACP_DAEMON_ID           Daemon identifier (default: hostname)

  Platform support:
    Linux   ✅  macOS   ✅  Windows   ✅
`);
}

async function main() {
  const cmd = process.argv[2] || 'install';

  switch (cmd) {
    case 'install':
    case '':
      await installDaemon();
      installAgents();
      status('\n  Installation complete!');
      break;
    case 'daemon':
      await installDaemon();
      break;
    case 'agents':
      installAgents();
      break;
    case 'status':
      getStatus();
      break;
    case 'uninstall':
      await uninstall();
      status('\n  Uninstall complete!');
      break;
    case '--help':
    case '-h':
    case 'help':
      help();
      break;
    default:
      console.error(`Unknown command: ${cmd}`);
      help();
      process.exit(1);
  }
}

main().catch((err) => {
  console.error(`Error: ${err.message}`);
  process.exit(1);
});
