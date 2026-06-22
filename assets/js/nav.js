document.addEventListener("DOMContentLoaded", () => {
  const toggleBtns = document.querySelectorAll(".search-toggle");
  if (!toggleBtns.length) return;

  document.body.insertAdjacentHTML("beforeend", `
    <div class="search-modal" id="search-modal">
      <div class="search-modal-inner">
        <div class="search-modal-header">
          <h2>Search</h2>
          <button class="search-close" aria-label="Close">&times;</button>
        </div>
        <input class="search-modal-input" type="text" placeholder="Search…" autocomplete="off" autocapitalize="off" spellcheck="false">
        <div class="search-results" id="search-results"></div>
      </div>
    </div>
  `);

  const modal = document.getElementById("search-modal");
  const input = modal.querySelector(".search-modal-input");
  const resultsEl = document.getElementById("search-results");
  const closeBtn = modal.querySelector(".search-close");

  let currentResults = [];
  let activeIndex = -1;

  function score(item, q) {
    const title = item.title.toLowerCase();
    const excerpt = (item.excerpt || "").toLowerCase();
    if (title.startsWith(q)) return 3;
    if (title.includes(q)) return 2;
    if (excerpt.includes(q)) return 1;
    return 0;
  }

  function search(query) {
    const q = query.trim().toLowerCase();
    if (!q) return [];
    return (window.SEARCH_INDEX || [])
      .map((item) => ({ item, s: score(item, q) }))
      .filter(({ s }) => s > 0)
      .sort((a, b) => b.s - a.s)
      .map(({ item }) => item)
      .slice(0, 8);
  }

  function escapeHtml(s) {
    return s.replace(/[&<>"']/g, (c) => ({
      "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;"
    }[c]));
  }

  function highlight(text, q) {
    const safe = escapeHtml(text);
    if (!q) return safe;
    const i = safe.toLowerCase().indexOf(q.toLowerCase());
    if (i === -1) return safe;
    return `${safe.slice(0, i)}<mark>${safe.slice(i, i + q.length)}</mark>${safe.slice(i + q.length)}`;
  }

  function render(query) {
    currentResults = search(query);
    activeIndex = -1;

    if (!query.trim()) {
      resultsEl.innerHTML = "";
      return;
    }
    if (!currentResults.length) {
      resultsEl.innerHTML = `<p class="search-empty">No results found.</p>`;
      return;
    }
    resultsEl.innerHTML = currentResults.map((item) => `
      <a class="search-result" href="${item.url}">
        <span class="search-result-title">${highlight(item.title, query)}</span><span class="search-result-type">${item.type}</span>
        <p class="search-result-excerpt">${highlight(item.excerpt || "", query)}</p>
      </a>
    `).join("");
  }

  function setActive(i) {
    const els = resultsEl.querySelectorAll(".search-result");
    els.forEach((el) => el.classList.remove("active"));
    if (i >= 0 && i < els.length) {
      els[i].classList.add("active");
      els[i].scrollIntoView({ block: "nearest" });
    }
    activeIndex = i;
  }

  function openModal() {
    modal.classList.add("open");
    document.body.classList.add("search-modal-active");
    input.value = "";
    resultsEl.innerHTML = "";
    input.focus();
  }

  function closeModal() {
    modal.classList.remove("open");
    document.body.classList.remove("search-modal-active");
  }

  toggleBtns.forEach((btn) => btn.addEventListener("click", openModal));
  closeBtn.addEventListener("click", closeModal);

  modal.addEventListener("click", (e) => {
    if (e.target === modal) closeModal();
  });

  input.addEventListener("input", () => render(input.value));

  input.addEventListener("keydown", (e) => {
    const count = currentResults.length;
    if (e.key === "Escape") {
      closeModal();
    } else if (e.key === "ArrowDown" && count) {
      e.preventDefault();
      setActive((activeIndex + 1) % count);
    } else if (e.key === "ArrowUp" && count) {
      e.preventDefault();
      setActive((activeIndex - 1 + count) % count);
    } else if (e.key === "Enter") {
      e.preventDefault();
      const target = currentResults[activeIndex >= 0 ? activeIndex : 0];
      if (target) window.location.href = target.url;
    }
  });
});
