export default {
  async fetch(req) {
    const url = new URL(req.url)

    // /install → dev branch
    // /install/main → main branch (when ready)
    if (url.pathname.startsWith('/install')) {
      const branch = url.pathname === '/install/main' ? 'main' : 'dev'
      const gh = `https://raw.githubusercontent.com/Raza-learner/Runmote/${branch}/scripts/install.sh`
      return Response.redirect(gh, 301)
    }

    // Root — basic landing page
    const html = `<!DOCTYPE html>
<h1>Runmote</h1>
<p>Install: <code>curl -sL runmote.dev/install | bash</code></p>
<p>Dev: <code>curl -sL runmote.dev/install/dev | bash</code></p>
<hr>
<p>Daemon connects to your relay at <code>relay.runmote.dev</code></p>`
    return new Response(html, { headers: { 'content-type': 'text/html;charset=utf-8' } })
  }
}
