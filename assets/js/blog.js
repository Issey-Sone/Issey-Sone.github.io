document.addEventListener("DOMContentLoaded", () => {
  const buttons = document.querySelectorAll(".filter-btn");

  function setFilter(tag) {
    buttons.forEach(btn => btn.classList.toggle("active", btn.dataset.tag === tag));
    const q = document.querySelector(".search-input")?.value ?? "";
    filterPosts(q);
  }

  buttons.forEach(btn => {
    btn.addEventListener("click", () => setFilter(btn.dataset.tag));
  });
});
