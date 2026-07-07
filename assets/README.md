# assets/

Static assets for the GitHub Pages landing (`../index.html`) and the challenge docs.

| Path | Purpose |
| --- | --- |
| `css/style.css` | Fluent-inspired styling for the landing page. |
| `js/main.js` | Mobile nav toggle, active-section highlight, copy-to-clipboard. |
| `images/customer-journey.png` | Customer journey diagram used on the landing page and challenge headers (Ask &rarr; Ground &rarr; Compare &rarr; Draft &amp; Explain &rarr; Track &rarr; Hand off). |
| `images/architecture-target.png` | Target architecture diagram used on the landing page and challenge headers (User Layer, Agent Layer, Data Layer, Governance). |
| `screenshots/` *(drop-in)* | Portal screenshots referenced from the challenge markdown files. Suggested filenames: `challenge-1-foundry-project.png`, `challenge-2-index-config.png`, etc. |

## Naming conventions

- Use kebab-case: `challenge-3-tool-registered.png`.
- Prefer PNG for both screenshots and diagrams in this repository.
- Keep images under 400 KB where possible; use `pngquant` / `svgo` before committing.
