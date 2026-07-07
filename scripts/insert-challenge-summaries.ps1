#requires -Version 5.1
<#
Inserts a standardized "Challenge summary" block near the top of each
challenge-N-*.md so every challenge shares the same schema:
  Objective / Agent capability / Tool integration / Azure services / Expected outcome
Idempotent: if the summary is already present, the file is left unchanged.
#>

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$challengeDir = Join-Path $root 'challenges'
$marker = '<!-- CHALLENGE-SUMMARY:v1 -->'

$summaries = @{
  '0' = @{
    objective   = 'Provision the Azure AI Foundry project, deploy the model, connect Azure AI Search, upload the contract corpus, and enable tracing.'
    capability  = 'Foundation only &mdash; no agent behavior yet. This challenge lays the runtime the Contract Lifecycle Management Agent will live on.'
    integration = 'None yet. Prepares the substrate for every tool that follows.'
    services    = 'Azure AI Foundry, Azure AI Foundry Models (gpt-4o / gpt-4o-mini), Azure AI Search, Azure Blob Storage, Application Insights.'
    outcome     = 'A working Foundry project with a deployed model, an indexed corpus, and end-to-end tracing enabled &mdash; ready for Challenge 1.'
  }
  '1' = @{
    objective   = 'Author the Contract Intake &amp; Drafting Agent: persona, instructions, refusal behavior, and the first grounded round-trip.'
    capability  = 'Contract intake &amp; drafting &mdash; the agent gathers the required inputs, drafts from approved templates, and refuses legal advice or self-approval.'
    integration = 'Agent runtime only (no external tools attached yet). Sets up the instruction slots that later tools plug into.'
    services    = 'Azure AI Foundry Agents, Azure AI Foundry Models (gpt-4o / gpt-4o-mini).'
    outcome     = 'The agent replies with the correct persona, gathers a full contract intake, refuses out-of-scope prompts, and always includes the standard disclaimer.'
  }
  '2' = @{
    objective   = 'Ground the agent on the enterprise contract corpus (templates, clauses, policies) with citations on every answer.'
    capability  = 'Contract search &amp; review &mdash; the agent retrieves from Azure AI Search and cites the exact document, clause, or paragraph.'
    integration = '**Contract Search Tool** (Azure AI Search) attached. Prepares the ground the Contract Repository (SharePoint) reads on top of.'
    services    = 'Azure AI Search (hybrid vector + semantic), Azure Blob Storage, Azure AI Foundry Models (embeddings).'
    outcome     = 'Every corpus answer includes a traceable citation. Fabricated content is refused and re-grounded.'
  }
  '3' = @{
    objective   = 'Attach the five canonical Contract Lifecycle Management tools to the agent and prove end-to-end orchestration.'
    capability  = 'Full CLM workflow &mdash; search, clause analysis, repository pull, approval routing, and status read/write in one conversation.'
    integration = '**Contract Search** (Azure AI Search) &middot; **Clause Analysis** (Azure AI Foundry Models) &middot; **Contract Repository** (SharePoint) &middot; **Approval Routing** (Power Automate) &middot; **Contract Status** (Dataverse / Azure SQL).'
    services    = 'Azure AI Search, Azure AI Foundry Models, SharePoint, Power Automate, Dataverse (or Azure SQL).'
    outcome     = 'The agent runs the scripted scenario in a single thread, routes approvals, updates status, and every tool call is visible in App Insights.'
  }
  '4' = @{
    objective   = 'Wrap every tool with Prompt Shields, Content Safety, PII detection, approved-template enforcement, and restricted-clause protection.'
    capability  = 'Safety-first CLM &mdash; the agent refuses restricted actions, redacts PII, and only edits approved templates.'
    integration = 'Guardrails sit between the user and all five tools. No unsafe fast path exists.'
    services    = 'Azure AI Content Safety, Prompt Shields, PII detection.'
    outcome     = 'All red-team prompts are refused; zero safety defects on the evaluation dataset.'
  }
  '5' = @{
    objective   = 'Trace every prompt, retrieval, tool call, and response into Application Insights, and query them with KQL.'
    capability  = 'Full audit trail &mdash; end-to-end tracing for every conversation, including latency, cost, and grounding signals.'
    integration = 'Tracing wraps all five agent tools (Contract Search, Clause Analysis, Contract Repository, Approval Routing, Contract Status).'
    services    = 'OpenTelemetry, Application Insights, Log Analytics.'
    outcome     = 'Reusable KQL queries return per-thread telemetry including tool-call accuracy, latency, and cost per session.'
  }
  '6' = @{
    objective   = 'Evaluate the agent on a 15-row dataset: groundedness, relevance, task adherence, safety, and tool-call accuracy.'
    capability  = 'Provable quality &mdash; the agent hits published thresholds before it can ship.'
    integration = 'Evaluators score every tool invocation (Contract Search, Clause Analysis, Contract Repository, Approval Routing, Contract Status).'
    services    = 'Azure AI Evaluation SDK, Azure AI Foundry evaluators.'
    outcome     = 'All gate metrics green; scorecard published; failing runs block the CI pipeline.'
  }
  '7' = @{
    objective   = 'Optimize across model, prompt, retrieval, and tool selection to hold or improve quality at lower cost and latency.'
    capability  = 'Same quality, cheaper and faster &mdash; a repeatable sweep the team can run every quarter.'
    integration = 'Tunes retrieval parameters and tool-selection heuristics without changing the five-tool contract.'
    services    = 'Azure AI Evaluation SDK, Azure AI Foundry Models.'
    outcome     = 'Cost per session reduced with quality maintained or improved. Before/after scorecards recorded.'
  }
  '8' = @{
    objective   = 'Publish the agent as a Web App with Easy Auth, a Teams app, or an authenticated API endpoint.'
    capability  = 'End-user access &mdash; pilot users complete real Contract Lifecycle Management tasks from a real channel.'
    integration = 'All five tools reachable via the shipped channel. A scheduled Azure Function is added *only* for the batch renewal-reminder job (a non-conversational workload the agent should not own).'
    services    = 'Azure App Service (Easy Auth), Microsoft Teams, Managed Identity, Azure Storage Queue + Azure Functions (for the renewal reminder batch only).'
    outcome     = 'A pilot user completes an end-to-end scenario from Teams or the Web App and every action is traced.'
  }
}

Get-ChildItem -Path $challengeDir -Filter 'challenge-*-*.md' | Sort-Object Name | ForEach-Object {
  $file = $_.FullName
  $name = $_.Name
  if ($name -notmatch '^challenge-(\d+)-') { return }
  $n = $matches[1]
  $s = $summaries[$n]
  if (-not $s) { Write-Warning "No summary defined for $name"; return }

  $content = Get-Content -Raw -Path $file
  if ($content -match [regex]::Escape($marker)) {
    Write-Host "skip $name (already has summary)"
    return
  }

  $block = @"
$marker
## Challenge summary

| Field | Value |
| --- | --- |
| **Objective** | $($s.objective) |
| **Agent capability** | $($s.capability) |
| **Tool integration** | $($s.integration) |
| **Azure services used** | $($s.services) |
| **Expected outcome** | $($s.outcome) |

---

"@

  # Insert after the first "---" separator line (which every challenge has after
  # the H1 + duration line).
  $pattern = "(?m)^---\r?\n\r?\n"
  $updated = [regex]::Replace($content, $pattern, { param($m) $m.Value + $block }, [System.Text.RegularExpressions.RegexOptions]::None, [timespan]::FromSeconds(2))
  # Only replace the FIRST match:
  $rx = New-Object System.Text.RegularExpressions.Regex $pattern, 'Multiline'
  $updated = $rx.Replace($content, ($rx.Match($content).Value + $block), 1)

  Set-Content -Path $file -Value $updated -Encoding UTF8
  Write-Host "wrote summary into $name"
}
