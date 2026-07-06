# assets/

Static assets for the GitHub Pages landing (`../index.html`) and the challenge docs.

| Path | Purpose |
| --- | --- |
| `css/style.css` | Fluent-inspired styling for the landing page. |
| `js/main.js` | Mobile nav toggle, active-section highlight, copy-to-clipboard. |
| `architecture.png` *(drop-in)* | Rendered end-to-end architecture used in the hero of `index.html`. Falls back to a Mermaid text block if missing. |
| `screenshots/` *(drop-in)* | Portal screenshots referenced from the challenge markdown files. Suggested filenames: `challenge-1-foundry-project.png`, `challenge-2-index-config.png`, etc. |

## Naming conventions

- Use kebab-case: `challenge-3-tool-registered.png`.
- Prefer PNG for portal screenshots (crisp text) and SVG for diagrams.
- Keep images under 400 KB where possible; use `pngquant` / `svgo` before committing.

## Rendering the architecture diagram

The canonical source of the architecture diagram is the Mermaid block in `README.md` and in `challenges/challenge-7-final-solution.md`. To render:

```powershell
# Requires mermaid-cli
npx -p @mermaid-js/mermaid-cli mmdc -i architecture.mmd -o architecture.png -w 1600
```

Export the Mermaid block into `architecture.mmd`, then run the command above and commit both files.
