document.addEventListener("DOMContentLoaded", () => {
  const buttons = document.querySelectorAll(".filter-btn");
  const items = document.querySelectorAll(".post-item");
  const countEl = document.getElementById("visible-count");
  const noPostsEl = document.getElementById("no-posts");

  function applyFilter(tag) {
    let visible = 0;
    items.forEach((item) => {
      const tags = item.dataset.tags ? item.dataset.tags.split(" ") : [];
      const show = tag === "all" || tags.includes(tag);
      item.classList.toggle("hidden", !show);
      if (show) visible++;
    });
    if (countEl) countEl.textContent = visible;
    if (noPostsEl) noPostsEl.style.display = visible === 0 ? "block" : "none";
  }

  buttons.forEach((btn) => {
    btn.addEventListener("click", () => {
      buttons.forEach((b) => b.classList.toggle("active", b === btn));
      applyFilter(btn.dataset.tag);
    });
  });
});
