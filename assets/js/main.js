/* Contract Lifecycle Management MicroHack — landing page interactions.
 *
 * - Mobile nav toggle
 * - Light/dark theme toggle (persisted in localStorage)
 * - Active-section highlight in the primary nav
 * - Mermaid initialization with theme-aware config
 * - Copy-to-clipboard buttons injected into <pre> blocks
 */

(function () {
  "use strict";

  const root = document.documentElement;
  const STORAGE_KEY = "clm-theme";

  // ----- Mobile nav toggle --------------------------------------------------
  const toggle = document.querySelector(".nav-toggle");
  const links = document.querySelector(".nav-links");
  if (toggle && links) {
    toggle.addEventListener("click", function () {
      const isOpen = links.classList.toggle("open");
      toggle.setAttribute("aria-expanded", String(isOpen));
    });
    links.addEventListener("click", function (e) {
      if (e.target.tagName === "A") links.classList.remove("open");
    });
  }

  // ----- Theme toggle -------------------------------------------------------
  // Supports .theme-toggle (landing page) and #themeToggle (challenge pages).
  const themeBtn = document.querySelector(".theme-toggle") || document.getElementById("themeToggle");
  function applyTheme(next) {
    root.setAttribute("data-theme", next);
    try { localStorage.setItem(STORAGE_KEY, next); } catch (_) {}
    initMermaid(next);
  }
  if (themeBtn) {
    themeBtn.addEventListener("click", function () {
      const current = root.getAttribute("data-theme") === "dark" ? "dark" : "light";
      applyTheme(current === "dark" ? "light" : "dark");
    });
  }

  // ----- Mermaid initialization --------------------------------------------
  function initMermaid(theme) {
    if (!window.mermaid) return;
    const isDark = theme === "dark";
    window.mermaid.initialize({
      startOnLoad: false,
      theme: isDark ? "dark" : "default",
      themeVariables: {
        primaryColor: isDark ? "#17203A" : "#F3F5FB",
        primaryTextColor: isDark ? "#F3F5FB" : "#201F1E",
        primaryBorderColor: "#0078D4",
        lineColor: isDark ? "#98A2B3" : "#6B6B6B",
        secondaryColor: isDark ? "#101828" : "#EEF1F6",
        tertiaryColor: isDark ? "#0B1220" : "#FFFFFF",
        fontFamily: "Segoe UI, sans-serif",
      },
      securityLevel: "loose",
    });
    // Re-render any inline mermaid blocks. We snapshot original source into
    // data-source once so we can restore it before each re-render.
    document.querySelectorAll(".mermaid").forEach((node, i) => {
      if (!node.dataset.source) node.dataset.source = node.textContent;
      node.removeAttribute("data-processed");
      node.innerHTML = node.dataset.source;
      node.id = node.id || `mmd-${i}`;
    });
    try { window.mermaid.run(); } catch (_) {}
  }
  // Expose for challenge pages that render markdown dynamically.
  window.initMermaid = initMermaid;

  if (window.mermaid) initMermaid(root.getAttribute("data-theme") || "light");
  else window.addEventListener("load", () => initMermaid(root.getAttribute("data-theme") || "light"));

  // ----- Active section highlight ------------------------------------------
  const navAnchors = Array.from(document.querySelectorAll(".nav-links a[href^='#']"));
  const sections = navAnchors
    .map(a => document.querySelector(a.getAttribute("href")))
    .filter(Boolean);

  if ("IntersectionObserver" in window && sections.length) {
    const byId = new Map(navAnchors.map(a => [a.getAttribute("href").slice(1), a]));
    const obs = new IntersectionObserver(
      (entries) => {
        entries.forEach(entry => {
          const link = byId.get(entry.target.id);
          if (!link) return;
          if (entry.isIntersecting) {
            navAnchors.forEach(a => a.classList.remove("is-active"));
            link.classList.add("is-active");
          }
        });
      },
      { rootMargin: "-45% 0px -50% 0px", threshold: 0 }
    );
    sections.forEach(s => obs.observe(s));
  }

  // ----- QR code renderer ---------------------------------------------------
  // Any element with [data-qr="<url>"] gets a QR canvas drawn into it.
  // Optional: data-qr-size="200" (default 180).
  function drawQrCodes() {
    const mounts = document.querySelectorAll("[data-qr]");
    if (!mounts.length) return true;
    if (typeof window.QRCode === "undefined") return false;
    mounts.forEach((mount) => {
      if (mount.dataset.qrRendered === "1") return;
      const url = mount.getAttribute("data-qr");
      const size = parseInt(mount.getAttribute("data-qr-size") || "180", 10);
      mount.innerHTML = "";
      const canvas = document.createElement("canvas");
      mount.appendChild(canvas);
      window.QRCode.toCanvas(canvas, url, {
        width: size,
        margin: 1,
        color: { dark: "#201F1E", light: "#FFFFFF" },
        errorCorrectionLevel: "M",
      }, (err) => {
        if (err) mount.textContent = "QR unavailable";
        else mount.dataset.qrRendered = "1";
      });
    });
    return true;
  }
  if (!drawQrCodes()) {
    // qrcode.min.js loads from CDN; retry after it lands.
    setTimeout(drawQrCodes, 400);
    setTimeout(drawQrCodes, 1500);
    window.addEventListener("load", drawQrCodes);
  }

  // ----- Copy-to-clipboard for <pre> ---------------------------------------
  function addCopyButtons(root) {
    (root || document).querySelectorAll("pre").forEach((pre) => {
      if (pre.querySelector(".copy-btn")) return;
      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = "copy-btn";
      btn.textContent = "Copy";
      btn.setAttribute("aria-label", "Copy code to clipboard");
      Object.assign(btn.style, {
        position: "absolute",
        top: "8px",
        right: "8px",
        padding: "4px 10px",
        fontSize: "0.75rem",
        border: "1px solid rgba(255,255,255,0.2)",
        borderRadius: "6px",
        background: "rgba(255,255,255,0.08)",
        color: "#E5E7EB",
        cursor: "pointer",
      });
      pre.style.position = "relative";
      pre.appendChild(btn);

      btn.addEventListener("click", async () => {
        const code = pre.querySelector("code")?.innerText ?? pre.innerText;
        try {
          await navigator.clipboard.writeText(code);
          btn.textContent = "Copied";
          setTimeout(() => (btn.textContent = "Copy"), 1400);
        } catch {
          btn.textContent = "Press Ctrl+C";
          setTimeout(() => (btn.textContent = "Copy"), 1800);
        }
      });
    });
  }
  // Expose for challenge pages that render markdown dynamically.
  window.addCopyButtons = addCopyButtons;
  addCopyButtons();
})();
