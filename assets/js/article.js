const KATEX_DELIMS = [
  { left: "$$", right: "$$", display: true },
  { left: "$",  right: "$",  display: false },
  { left: "\\[", right: "\\]", display: true },
  { left: "\\(", right: "\\)", display: false }
];

let headings = [];
let tocItems = [];
let contentEl;

function slugify(s) {
  return s.toLowerCase().trim().replace(/[^\w]+/g, "-").replace(/^-+|-+$/g, "");
}

// Pull math spans out before markdown parsing so marked doesn't mangle
// underscores / backslashes, then splice them back in afterwards.
function renderMarkdown(md) {
  const math = [];
  const stash = (m) => `@@MATH${math.push(m) - 1}@@`;
  md = md.replace(/\$\$([\s\S]+?)\$\$/g, stash);
  md = md.replace(/(?<!\\)\$([^$\n]+?)(?<!\\)\$/g, stash);

  let html = marked.parse(md);
  html = html.replace(/@@MATH(\d+)@@/g, (_, i) => math[+i]);
  return html;
}

// Bar geometry for the spotlight effect.
const BAR_MIN_W = 26;   // % width of the bar furthest from the active section
const BAR_MAX_W = 100;  // % width of the active section's bar
const BAR_MIN_O = 0.16; // opacity furthest away
const BAR_MAX_O = 1;    // opacity at the active section
const SPREAD = 1.15;    // how quickly bars taper off with distance

function buildToc() {
  headings = [...contentEl.querySelectorAll("h2")];
  const list = document.querySelector(".toc-list");
  list.innerHTML = "";
  tocItems = [];

  headings.forEach((h, i) => {
    if (!h.id) h.id = slugify(h.textContent) || `section-${i}`;

    const item = document.createElement("a");
    item.href = `#${h.id}`;
    item.className = "toc-item";
    item.title = h.textContent;
    item.innerHTML =
      `<span class="toc-track"><span class="toc-bar"></span></span>` +
      `<span class="toc-label">${h.textContent}</span>`;

    item.addEventListener("click", (e) => {
      e.preventDefault();
      h.scrollIntoView({ behavior: "smooth", block: "start" });
      history.replaceState(null, "", `#${h.id}`);
    });

    list.appendChild(item);
    tocItems.push(item);
  });
}

// A continuous reading position measured in "section units": an integer at a
// heading, fractional partway through a section. Drives the smooth morph.
function readingPosition() {
  const refLine = window.scrollY + window.innerHeight * 0.3;
  const docEnd = contentEl.getBoundingClientRect().bottom + window.scrollY;
  let pos = 0;

  for (let i = 0; i < headings.length; i++) {
    const start = headings[i].getBoundingClientRect().top + window.scrollY;
    const end = i + 1 < headings.length
      ? headings[i + 1].getBoundingClientRect().top + window.scrollY
      : docEnd;
    if (refLine >= start) {
      pos = i + Math.min(1, (refLine - start) / (end - start));
    }
  }
  return pos;
}

function updateProgress() {
  if (!headings.length) return;

  const pos = readingPosition();
  const nearest = Math.round(pos);

  tocItems.forEach((item, i) => {
    const d = Math.abs(i - pos);
    const t = Math.exp(-(d * d) / (2 * SPREAD * SPREAD));
    item.style.setProperty("--w", `${BAR_MIN_W + (BAR_MAX_W - BAR_MIN_W) * t}%`);
    item.style.setProperty("--o", BAR_MIN_O + (BAR_MAX_O - BAR_MIN_O) * t);
    item.classList.toggle("active", i === nearest);
  });
}

let ticking = false;
function onScroll() {
  if (ticking) return;
  ticking = true;
  requestAnimationFrame(() => {
    updateProgress();
    ticking = false;
  });
}

// Parse optional metadata block at the top of the file. Supports a leading
// HTML comment (<!-- key: value -->) — which GitHub Pages' Jekyll leaves alone
// so the raw .md stays fetchable — as well as the classic --- YAML block.
// Returns { meta: {key: value, ...}, body: markdownWithoutMeta }
function parseFrontmatter(raw) {
  const match =
    raw.match(/^<!--\r?\n([\s\S]*?)\r?\n-->\r?\n([\s\S]*)$/) ||
    raw.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n([\s\S]*)$/);
  if (!match) return { meta: {}, body: raw };
  const meta = {};
  for (const line of match[1].split(/\r?\n/)) {
    const [, k, v] = line.match(/^(\w+):\s*(.+)$/) ?? [];
    if (k) meta[k] = v.trim();
  }
  return { meta, body: match[2] };
}

function injectProjectActions(meta) {
  const h1 = contentEl.querySelector("h1");
  if (!h1) return;
  const keys = ["pdf", "code", "slides", "link"];
  const links = keys.filter(k => meta[k]).map(k =>
    `<a href="${meta[k]}">[${k}]</a>`
  );
  if (!links.length) return;
  const div = document.createElement("div");
  div.className = "project-actions";
  div.innerHTML = links.join("");
  h1.insertAdjacentElement("afterend", div);
}

async function loadArticle() {
  contentEl = document.getElementById("article-content");
  const params = new URLSearchParams(location.search);
  const isProject = params.has("project");
  const slug = params.get("project") ?? params.get("post");

  const back = document.querySelector(".back-link");
  if (isProject && back) {
    back.href = "/#projects";
    back.textContent = "← Projects";
  }

  if (isProject) {
    document.querySelector(".article-layout")?.classList.add("project-layout");
  }

  if (!slug || !/^[\w-]+$/.test(slug)) {
    contentEl.innerHTML = `<p class="loading">Article not found.</p>`;
    return;
  }

  try {
    const res = await fetch(`/${isProject ? "projects" : "posts"}/${slug}.md`);
    if (!res.ok) throw new Error(res.status);
    const raw = await res.text();
    const { meta, body } = parseFrontmatter(raw);

    contentEl.innerHTML = renderMarkdown(body);
    document.title = `${contentEl.querySelector("h1")?.textContent ?? "Article"} — Issey Sone`;

    if (isProject) injectProjectActions(meta);

    if (window.renderMathInElement) {
      renderMathInElement(contentEl, { delimiters: KATEX_DELIMS });
    }

    if (!isProject) {
      buildToc();
      updateProgress();
    }

    if (location.hash) {
      document.getElementById(location.hash.slice(1))?.scrollIntoView();
    }
  } catch (err) {
    contentEl.innerHTML = `<p class="loading">Could not load this article.</p>`;
  }
}

document.addEventListener("DOMContentLoaded", () => {
  loadArticle();
  window.addEventListener("scroll", onScroll, { passive: true });
  window.addEventListener("resize", onScroll, { passive: true });
});
