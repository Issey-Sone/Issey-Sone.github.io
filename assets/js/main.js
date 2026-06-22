
const formulas = [
    ["$\\mathbb{P}(X\\geq\\mathbb{E}[X])>0$", "(Can't always underperform)"],
    ["$ \\displaystyle \\left\\| X \\right\\|_{\\infty}=\\lim_{p \\rightarrow\\infty}(\\mathbb E|X|^p)^{\\frac{1}{p}}$", "(Essential Supremum)"]
]



document.addEventListener("DOMContentLoaded", () => {
  const formula = document.querySelector(".name-label");
  const result = document.querySelector(".name-result");

  if (formula && result) {

    const pair = formulas[Math.floor(Math.random() * formulas.length)];

    formula.textContent = pair[0];
    result.textContent  = pair[1];
  }
  if (window.renderMathInElement) {
    renderMathInElement(document.querySelector(".name-block"), {
      delimiters: [
        { left: "$$", right: "$$", display: true },
        { left: "$",  right: "$",  display: false },
        { left: "\\[", right: "\\]", display: true },
        { left: "\\(", right: "\\)", display: false }
      ]
    });
  } else {
    console.warn("KaTeX auto-render not found.");
  }
});