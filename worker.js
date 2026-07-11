export default {
  async fetch(req) {
    const url = new URL(req.url)
    const branch = url.pathname.endsWith('/dev') ? 'dev' : 'main'

    const ext = url.pathname.startsWith('/install.ps1') ? 'ps1' : 'sh'
    if (url.pathname.startsWith('/install.' + ext) || (ext === 'sh' && (url.pathname === '/install' || url.pathname === '/install/'))) {
      const gh = `https://raw.githubusercontent.com/Raza-learner/Runmote/${branch}/scripts/install.${ext}?_=${Date.now()}`
      const resp = await fetch(gh)
      const text = await resp.text()
      return new Response(text, {
        headers: {
          'content-type': ext === 'ps1' ? 'text/powershell' : 'text/x-shellscript',
          'cache-control': 'no-cache, no-store, must-revalidate'
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
