#requires -Version 5.1
<#
Generates challenges/challenge-N-*.html from the sibling .md file plus a shared
HTML template. Each page embeds the markdown inline as <script type="text/markdown">
so it renders correctly whether opened via file:// or served over HTTP.
#>

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$challengeDir = Join-Path $root 'challenges'

$challenges = @(
  [pscustomobject]@{ n=0; slug='setup';                title='Setup';                                  lede='Create the Foundry project, deploy the model, connect Azure AI Search, enable tracing, and upload the corpus.'; mins='45 min';  chip='Setup' }
  [pscustomobject]@{ n=1; slug='build-agent';          title='Build the Contract Intake &amp; Drafting Agent'; lede='Write the persona and instructions, prove the first round-trip, and lock in the refusal behavior.';       mins='45 min';  chip='Build' }
  [pscustomobject]@{ n=2; slug='knowledge-grounding';  title='Knowledge Grounding';                    lede='Index NDAs, MSAs, policies, and the clause library into Azure AI Search. Add citations to every answer.';   mins='60 min';  chip='Ground' }
  [pscustomobject]@{ n=3; slug='tools-actions';        title='Tools &amp; Actions';                    lede='Attach the five canonical CLM tools: Contract Search (Azure AI Search), Clause Analysis (Foundry Models), Contract Repository (SharePoint), Approval Routing (Power Automate), and Contract Status (Dataverse / SQL).'; mins='75 min'; chip='Tools' }
  [pscustomobject]@{ n=4; slug='guardrails';           title='Guardrails';                             lede='Prompt Shields, PII detection, approved-template enforcement, and restricted-clause modification.';         mins='45 min';  chip='Protect' }
  [pscustomobject]@{ n=5; slug='observability';        title='Observability';                          lede='Trace every prompt &rarr; LLM &rarr; retrieval &rarr; tool &rarr; response into Application Insights, then write the KQL.'; mins='45 min'; chip='Observe' }
  [pscustomobject]@{ n=6; slug='evaluation';           title='Evaluation';                             lede='Score groundedness, relevance, task adherence, safety, and tool accuracy on a 15-row dataset. Turn the gate green.'; mins='60 min'; chip='Evaluate' }
  [pscustomobject]@{ n=7; slug='optimization';         title='Optimization';                           lede='Sweep model, prompt, retrieval, and tools. Show the before/after with a cost delta.';                       mins='45 min';  chip='Optimize' }
  [pscustomobject]@{ n=8; slug='publish';              title='Publish';                                lede='Ship as a Web App with Easy Auth, a Teams app, or an authenticated API endpoint.';                          mins='60 min';  chip='Ship' }
)

$total = $challenges.Count  # 9
for ($i=0; $i -lt $total; $i++) {
  $c = $challenges[$i]
  $mdName = "challenge-$($c.n)-$($c.slug).md"
  $htmlName = "challenge-$($c.n)-$($c.slug).html"
  $mdPath = Join-Path $challengeDir $mdName
  $htmlPath = Join-Path $challengeDir $htmlName

  if (-not (Test-Path $mdPath)) { Write-Warning "Missing $mdPath"; continue }
  $md = Get-Content -Raw -Path $mdPath

  $progress = [math]::Round((($c.n + 1) / $total) * 100)
  $svgName = "challenge-$($c.n)-$($c.slug).svg"

  # Prev / next
  if ($c.n -eq 0) {
    $prevHtml = '<span class="btn btn-ghost disabled" aria-disabled="true">&larr; Prev</span>'
  } else {
    $p = $challenges[$i-1]
    $prevHtml = "<a class=""btn btn-ghost"" href=""challenge-$($p.n)-$($p.slug).html"">&larr; Challenge $($p.n)</a>"
  }
  if ($c.n -eq ($total - 1)) {
    $nextHtml = '<a class="btn btn-primary" href="../index.html#challenges">Back to roadmap &rarr;</a>'
  } else {
    $q = $challenges[$i+1]
    $nextHtml = "<a class=""btn btn-primary"" href=""challenge-$($q.n)-$($q.slug).html"">Challenge $($q.n) &rarr;</a>"
  }

  $pageTitle = "Challenge $($c.n) &middot; $($c.title) &middot; Foundry MicroHack"

  $html = @"
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>$pageTitle</title>
<meta name="description" content="$($c.lede -replace '"','&quot;')">
<link rel="preconnect" href="https://cdn.jsdelivr.net" crossorigin>
<link rel="stylesheet" href="../assets/css/style.css">
<script>
  (function () {
    try {
      var t = localStorage.getItem('clm-theme');
      if (t === 'dark' || t === 'light') document.documentElement.setAttribute('data-theme', t);
      else if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
        document.documentElement.setAttribute('data-theme', 'dark');
      }
    } catch (e) {}
  })();
</script>
</head>
<body>

<!-- ================= NAV ================= -->
<header class="site-nav">
  <div class="wrap nav-inner">
    <a class="brand" href="../index.html#top" aria-label="Home">
      <span class="brand-mark" aria-hidden="true">
        <svg viewBox="0 0 24 24" width="22" height="22" role="img" aria-label="Foundry mark">
          <rect x="2"  y="2"  width="9" height="9" fill="#F25022"/>
          <rect x="13" y="2"  width="9" height="9" fill="#7FBA00"/>
          <rect x="2"  y="13" width="9" height="9" fill="#00A4EF"/>
          <rect x="13" y="13" width="9" height="9" fill="#FFB900"/>
        </svg>
      </span>
      <span class="brand-text">Foundry <strong>MicroHack</strong></span>
    </a>
    <nav class="nav-links" aria-label="Primary">
      <ul>
        <li><a href="../index.html#overview">Overview</a></li>
        <li><a href="../index.html#architecture">Architecture</a></li>
        <li><a href="../index.html#challenges">Challenges</a></li>
        <li><a href="../index.html#services">Azure services</a></li>
        <li><a href="../index.html#paths">Paths</a></li>
        <li><a href="../index.html#resources">Resources</a></li>
        <li><a href="../index.html#start">Start</a></li>
        <li><a href="https://github.com/priyanka405/MS-Foundry-Microhack" target="_blank" rel="noopener" class="cta-mini">GitHub &#8599;</a></li>
      </ul>
    </nav>
    <div class="nav-controls">
      <button id="themeToggle" class="icon-btn" aria-label="Toggle theme" title="Toggle theme">
        <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><path fill="currentColor" d="M12 3a9 9 0 1 0 9 9c0-.46-.04-.92-.1-1.36A7 7 0 0 1 12 3z"/></svg>
      </button>
      <button id="navToggle" class="icon-btn nav-toggle" aria-label="Menu" aria-expanded="false">
        <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><path fill="currentColor" d="M3 6h18v2H3zm0 5h18v2H3zm0 5h18v2H3z"/></svg>
      </button>
    </div>
  </div>
</header>

<!-- ================= HERO ================= -->
<section class="challenge-hero">
  <div class="wrap">
    <nav class="breadcrumb" aria-label="Breadcrumb">
      <a href="../index.html">Home</a><span class="sep">/</span>
      <a href="../index.html#challenges">Challenges</a><span class="sep">/</span>
      <span class="current">Challenge $($c.n)</span>
    </nav>
    <span class="eyebrow">CHALLENGE $($c.n) &middot; $($c.mins.ToUpper())</span>
    <h1>$($c.title)</h1>
    <p class="lede">$($c.lede)</p>
    <div class="badge">$($c.chip)</div>
    <div class="progress" aria-label="Progress through the MicroHack">
      <div class="progress-track"><div class="progress-fill" style="width: $progress%"></div></div>
      <span class="progress-label">Step $($c.n + 1) of $total &middot; $progress% complete</span>
    </div>
    <div class="arch-frame" style="margin-top: 1.75rem;">
      <img src="../assets/images/$svgName" alt="Diagram for Challenge $($c.n): $($c.title)" loading="lazy">
    </div>
  </div>
</section>

<!-- ================= BODY ================= -->
<section class="challenge-body">
  <div class="wrap">
    <article id="md-content">
      <div class="markdown-loading">Rendering challenge&hellip;</div>
    </article>

    <nav class="challenge-nav" aria-label="Challenge navigation">
      $prevHtml
      <a class="btn btn-ghost" href="../index.html#challenges">Back to roadmap</a>
      $nextHtml
    </nav>
  </div>
</section>

<!-- ================= FOOTER ================= -->
<footer class="site-foot">
  <div class="wrap foot-inner">
    <div>
      <strong>Contract Lifecycle Management with Microsoft Foundry</strong>
      <span>&middot; A Foundry MicroHack</span>
    </div>
    <nav aria-label="Footer">
      <a href="../README.md">README</a>
      <a href="../index.html#challenges">Challenges</a>
      <a href="https://github.com/priyanka405/MS-Foundry-Microhack" target="_blank" rel="noopener">GitHub</a>
      <a href="#top">Back to top &uarr;</a>
    </nav>
  </div>
</footer>

<!-- Raw markdown embedded so the page renders without a server. -->
<script type="text/markdown" id="md-source">
__MARKDOWN__
</script>

<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/qrcode@1.5.3/build/qrcode.min.js"></script>
<script src="../assets/js/main.js" defer></script>
<script>
  (function () {
    function render() {
      var src = document.getElementById('md-source');
      var out = document.getElementById('md-content');
      if (!src || !out) return;
      var md = src.textContent || '';
      if (typeof window.marked === 'undefined') {
        out.innerHTML = '<div class="markdown-error">Markdown renderer failed to load. Open the <a href="$mdName">raw markdown</a>.</div>';
        return;
      }
      try {
        window.marked.setOptions({ gfm: true, breaks: false });
        out.innerHTML = window.marked.parse(md);
      } catch (e) {
        out.innerHTML = '<div class="markdown-error">Could not render markdown. Open the <a href="$mdName">raw file</a>.</div>';
      }
    }
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', render);
    } else { render(); }
  })();
</script>
</body>
</html>
"@

  # Splice the raw markdown in verbatim using the .NET string.Replace (no regex),
  # so any $1, `n, or other tokens inside the markdown are preserved literally.
  $html = $html.Replace('__MARKDOWN__', $md)

  Set-Content -Path $htmlPath -Value $html -Encoding UTF8
  Write-Host "wrote $htmlName ($progress%)"
}
