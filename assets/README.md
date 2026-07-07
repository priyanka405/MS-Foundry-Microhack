# assets/

Static assets for the GitHub Pages landing (`../index.html`) and the challenge docs.

| Path | Purpose |
| --- | --- |
| `css/style.css` | Fluent-inspired styling for the landing page. |
| `js/main.js` | Mobile nav toggle, active-section highlight, copy-to-clipboard. |
| `images/architecture-target.png` | Target architecture diagram used in `index.html` and `README.md`. |
| `images/customer-journey.png` | Customer journey diagram used in `index.html` and `README.md`. |
| `screenshots/` *(drop-in)* | Portal screenshots referenced from the challenge markdown files. Suggested filenames: `challenge-1-foundry-project.png`, `challenge-2-index-config.png`, etc. |

## Naming conventions

- Use kebab-case: `challenge-3-tool-registered.png`.
- Prefer PNG for portal screenshots and provided diagram images. Keep source diagrams optimized before committing.
- Keep images under 400 KB where possible; use `pngquant` / `svgo` before committing.

## Diagram assets

The repository now stores the landing-page diagram exports directly in `assets/images/customer-journey.png` and `assets/images/architecture-target.png`. Keep replacements at a web-friendly size and update the HTML/Markdown references together when swapping them.
