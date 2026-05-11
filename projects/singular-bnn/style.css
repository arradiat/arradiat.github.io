/* ═══════════════════════════════════════════════════════════════════════════
   Existing JS (unchanged from original)
═══════════════════════════════════════════════════════════════════════════ */
const rankSlider = document.getElementById("rank-slider");
const rankValue = document.getElementById("rank-value");
const fullCount = document.getElementById("full-count");
const lowCount = document.getElementById("low-count");
const lowBar = document.getElementById("low-bar");
const savingText = document.getElementById("saving-text");
const M = 256;
const N = 256;

function updateSlider() {
  const r = parseInt(rankSlider.value);
  rankValue.textContent = r;
  const fullParams = M * N;
  const lowParams = r * (M + N);
  fullCount.textContent = fullParams.toLocaleString();
  lowCount.textContent = lowParams.toLocaleString();
  const ratio = (fullParams / lowParams).toFixed(1);
  savingText.textContent = `${ratio}× fewer parameters for a ${M} × ${N} layer.`;
  const percent = Math.min(100, (lowParams / fullParams) * 100);
  lowBar.style.width = `${percent}%`;
}

rankSlider.addEventListener("input", updateSlider);
updateSlider();

const copyButton = document.getElementById("copy-bibtex");
copyButton.addEventListener("click", () => {
  const bibtex =
`@inproceedings{toure2026singular,
  title     = {Singular Bayesian Neural Networks},
  author    = {Toure, Mame Diarra and Stephens, David A.},
  booktitle = {International Conference on Machine Learning},
  year      = {2026}
}`;
  navigator.clipboard.writeText(bibtex);
  copyButton.textContent = "Copied!";
  setTimeout(() => {
    copyButton.textContent = "Copy BibTeX";
  }, 1500);
});


/* ═══════════════════════════════════════════════════════════════════════════
   New: scroll-triggered animations
   — only animates elements that have the .fade-up class (added in HTML)
   — table rows get staggered reveal when their table scrolls into view
═══════════════════════════════════════════════════════════════════════════ */

/* Generic fade-up for cards, formula-cards, etc. */
const fadeObserver = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("visible");
        fadeObserver.unobserve(entry.target);
      }
    });
  },
  { threshold: 0.12 }
);

document.querySelectorAll(".fade-up").forEach((el) => {
  fadeObserver.observe(el);
});

/* Table row stagger */
function animateTableRows(table) {
  const rows = Array.from(table.querySelectorAll("tbody tr"));
  const rowObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          rows.forEach((row, i) => {
            setTimeout(() => {
              row.classList.add("row-visible");
            }, i * 110);
          });
          rowObserver.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.2 }
  );
  // observe the first row as the trigger
  if (rows.length) rowObserver.observe(rows[0]);
}

document.querySelectorAll(".table-card table, .profiling-table").forEach(animateTableRows);
