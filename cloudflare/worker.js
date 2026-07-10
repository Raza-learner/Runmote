export default {
  async fetch(req) {
    const url = new URL(req.url)

    // /install.sh or /install → main branch (stable)
    // /install.sh/dev or /install/dev → dev branch (testing)
    if (url.pathname.startsWith('/install')) {
      const branch = url.pathname.endsWith('/dev') ? 'dev' : 'main'
      const gh = `https://raw.githubusercontent.com/Raza-learner/Runmote/${branch}/scripts/install.sh`
      return Response.redirect(gh, 301)
    }

    // Root — landing page
    const html = `<!DOCTYPE html>
<h1>Runmote</h1>
<p>Install: <code>curl -fsSL https://runmote.dev/install.sh | bash</code></p>
<p>Dev: <code>curl -fsSL https://runmote.dev/install.sh/dev | bash</code></p>
<hr>
<p>Daemon connects to your relay at <code>relay.runmote.dev</code></p>`
    return new Response(html, { headers: { 'content-type': 'text/html;charset=utf-8' } })
  }
}
