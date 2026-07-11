export default {
  async fetch(req, env) {
    const url = new URL(req.url)
    const branch = url.pathname.endsWith('/dev') ? 'dev' : 'main'

    // Relay config endpoint — returns URL + token so installers don't hardcode tokens
    if (url.pathname === '/config' || url.pathname === '/config/dev') {
      const isDev = url.pathname.endsWith('/dev') || branch === 'dev'
      const relayUrl = isDev
        ? 'wss://runmote-relay.onrender.com/daemon'
        : 'wss://runmote-relay-u2zi.onrender.com/daemon'
      const token = isDev
        ? (env.ACP_DAEMON_TOKEN_DEV || '')
        : (env.ACP_DAEMON_TOKEN_MAIN || '')
      const config = { relayUrl, token }
      return new Response(JSON.stringify(config), {
        headers: { 'content-type': 'application/json', 'cache-control': 'no-cache' }
      })
    }

    const ext = url.pathname.startsWith('/install.ps1') ? 'ps1' : 'sh'
    if (url.pathname.startsWith('/install.' + ext) || (ext === 'sh' && (url.pathname === '/install' || url.pathname === '/install/'))) {
      const gh = `https://api.github.com/repos/Raza-learner/Runmote/contents/scripts/install.${ext}?ref=${branch}`
      const resp = await fetch(gh, { headers: { 'Accept': 'application/vnd.github.raw', 'User-Agent': 'runmote-worker' } })
      const text = await resp.text()
      return new Response(text, {
        headers: {
          'content-type': ext === 'ps1' ? 'text/powershell' : 'text/x-shellscript',
          'cache-control': 'public, max-age=60'
        }
      })
    }

    const html = `<!DOCTYPE html>
<h1>Runmote</h1>
<p>Linux: <code>curl -fsSL https://runmote.dev/install.sh | bash</code></p>
<p>Linux (dev): <code>curl -fsSL https://runmote.dev/install.sh/dev | bash</code></p>
<p>Windows: <code>powershell -c "irm https://runmote.dev/install.ps1 | iex"</code></p>
<p>Windows (dev): <code>powershell -c "irm https://runmote.dev/install.ps1/dev | iex"</code></p>
<hr>
<p>Daemon connects to your relay at <code>runmote-relay.onrender.com</code></p>`
    return new Response(html, { headers: { 'content-type': 'text/html;charset=utf-8' } })
  },

  // Keep Render free-tier relays awake (sleep after 15 min inactivity)
  async scheduled(event, env, ctx) {
    await fetch('https://runmote-relay-u2zi.onrender.com/health')
    await fetch('https://runmote-relay.onrender.com/health')
  }
}
