document.addEventListener("DOMContentLoaded", () => {
  const searchContainer = document.querySelector(".nav-search");
  const toggleBtn = document.querySelector(".search-toggle");
  const input = document.querySelector(".search-input");
  if (!searchContainer || !toggleBtn || !input) return;

  const isBlogPage = !!document.querySelector(".post-list");

  function openSearch() {
    searchContainer.classList.add("open");
    input.focus();
  }

  function closeSearch() {
    searchContainer.classList.remove("open");
    input.value = "";
    if (isBlogPage) filterPosts("");
  }

  toggleBtn.addEventListener("click", () => {
    searchContainer.classList.contains("open") ? closeSearch() : openSearch();
  });

  input.addEventListener("keydown", (e) => {
    if (e.key === "Escape") closeSearch();
    if (e.key === "Enter" && !isBlogPage) {
      const q = input.value.trim();
      if (q) window.location.href = `/blog.html?q=${encodeURIComponent(q)}`;
    }
  });

  if (isBlogPage) {
    input.addEventListener("input", () => filterPosts(input.value));

    // Pre-fill from URL param (e.g. redirected from homepage)
    const q = new URLSearchParams(location.search).get("q");
    if (q) { openSearch(); input.value = q; filterPosts(q); }
  }
});

function filterPosts(query) {
  const items = document.querySelectorAll(".post-item");
  const countEl = document.getElementById("visible-count");
  const noPostsEl = document.getElementById("no-posts");
  const activeTag = document.querySelector(".filter-btn.active")?.dataset.tag ?? "all";
  const q = query.trim().toLowerCase();

  let visible = 0;
  items.forEach((item) => {
    const tags = item.dataset.tags ? item.dataset.tags.split(" ") : [];
    const tagMatch = activeTag === "all" || tags.includes(activeTag);
    const text = item.textContent.toLowerCase();
    const textMatch = !q || text.includes(q);
    const show = tagMatch && textMatch;
    item.classList.toggle("hidden", !show);
    if (show) visible++;
  });

  if (countEl) countEl.textContent = visible;
  if (noPostsEl) noPostsEl.style.display = visible === 0 ? "block" : "none";
}
