export default {
  async fetch(req) {
    const url = new URL(req.url)

    if (url.pathname.startsWith('/install')) {
      const branch = url.pathname.endsWith('/dev') ? 'dev' : 'main'
      const gh = `https://raw.githubusercontent.com/Raza-learner/Runmote/${branch}/scripts/install.sh`
      return Response.redirect(gh, 301)
    }

    const html = `<!DOCTYPE html>
<h1>Runmote</h1>
<p>Install: <code>curl -fsSL https://runmote.dev/install.sh | bash</code></p>
<p>Dev: <code>curl -fsSL https://runmote.dev/install.sh/dev | bash</code></p>
<hr>
<p>Daemon connects to your relay at <code>relay.runmote.dev</code></p>`
    return new Response(html, { headers: { 'content-type': 'text/html;charset=utf-8' } })
  },

  // Keep Render free-tier relays awake (sleep after 15 min inactivity)
  async scheduled(event, env, ctx) {
    await fetch('https://runmote-relay-u2zi.onrender.com/health')
    await fetch('https://runmote-relay.onrender.com/health')
  }
}
