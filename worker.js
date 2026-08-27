export default {
  async fetch(req, env) {
    const url = new URL(req.url)
    const branch = url.pathname.endsWith('/dev') ? 'dev' : 'main'

    const ext = url.pathname.startsWith('/install.ps1') ? 'ps1' : 'sh'
    if (url.pathname.startsWith('/install.' + ext) || (ext === 'sh' && (url.pathname === '/install' || url.pathname === '/install/'))) {
      const isDev = branch === 'dev'
      const relayUrl = isDev
        ? 'wss://runmote-relay.onrender.com/daemon'
        : 'wss://runmote-relay-u2zi.onrender.com/daemon'
      const token = isDev
        ? (env.ACP_DAEMON_TOKEN_DEV || '')
        : (env.ACP_DAEMON_TOKEN_MAIN || '')

      const gh = `https://raw.githubusercontent.com/Raza-learner/Runmote/${branch}/scripts/install.${ext}`
      const headers = { 'User-Agent': 'runmote-worker' }
      if (env.GITHUB_TOKEN) headers['Authorization'] = `Bearer ${env.GITHUB_TOKEN}`
      const resp = await fetch(gh, { headers })
      let text = await resp.text()
      // Inject relay config from Worker secrets (no hardcoded tokens in source code)
      text = text.replaceAll('__ACP_RELAY_URL__', relayUrl)
      text = text.replaceAll('__ACP_DAEMON_TOKEN__', token)
      return new Response(text, {
        headers: {
          'content-type': ext === 'ps1' ? 'text/powershell' : 'text/x-shellscript',
          'cache-control': 'public, max-age=60'
        }
      })
    }

    // Site: proxy apex (and all non-install) to Vercel — DNS stays on Worker
    // Default to www.runmote.dev (after DNS CNAME to Vercel) — falls back to vercel.app preview if needed
    const vercelOrigin = env.VERCEL_ORIGIN || 'https://www.runmote.dev'
    const target = new URL(url.pathname + url.search, vercelOrigin)
    try {
      const proxied = await fetch(new Request(target, {
        method: req.method,
        headers: req.headers,
        body: req.body,
        redirect: 'manual',
      }))
      // www not yet Valid → Vercel 525/404/308 → fallback to simple HTML until DNS is Valid
      if (proxied.status !== 200) {
        throw new Error(`proxy status ${proxied.status}`)
      }
      const h = new Headers(proxied.headers)
      h.set('x-runmote-proxy', 'vercel')
      if (!h.get('cache-control')) h.set('cache-control', 'public, max-age=60')
      return new Response(proxied.body, { status: proxied.status, headers: h })
    } catch (e) {
      // Fallback: minimal HTML until www DNS is Valid
      const html = `<!DOCTYPE html>
<h1>Runmote</h1>
<p>Site deploying to Vercel — check <a href="https://www.runmote.dev">www.runmote.dev</a> (DNS updating) or <a href="https://${new URL(vercelOrigin).host}">Vercel preview</a></p>
<p>Install: <code>curl -fsSL https://runmote.dev/install.sh | bash</code></p>
<p>Windows: <code>powershell -c "irm https://runmote.dev/install.ps1 | iex"</code></p>`
      return new Response(html, { headers: { 'content-type': 'text/html;charset=utf-8', 'x-runmote-proxy': 'fallback' } })
    }
  },

  // Keep Render free-tier relays awake (sleep after 15 min inactivity)
  async scheduled(event, env, ctx) {
    await fetch('https://runmote-relay-u2zi.onrender.com/health')
    await fetch('https://runmote-relay.onrender.com/health')
  }
}
