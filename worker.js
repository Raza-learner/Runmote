export default {
  async fetch(req) {
    const url = new URL(req.url)
    const branch = url.pathname.endsWith('/dev') ? 'dev' : 'main'

    if (url.pathname.startsWith('/install.sh') || url.pathname === '/install' || url.pathname === '/install/') {
      const gh = `https://raw.githubusercontent.com/Raza-learner/Runmote/${branch}/scripts/install.sh`
      return Response.redirect(gh, 301)
    }

    if (url.pathname.startsWith('/install.ps1')) {
      const gh = `https://raw.githubusercontent.com/Raza-learner/Runmote/${branch}/scripts/install.ps1`
      return Response.redirect(gh, 301)
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
