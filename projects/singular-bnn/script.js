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

  fullCount.textContent =
    fullParams.toLocaleString();

  lowCount.textContent =
    lowParams.toLocaleString();

  const ratio =
    (fullParams / lowParams).toFixed(1);

  savingText.textContent =
    `${ratio}× fewer parameters for a ${M} × ${N} layer.`;

  const percent =
    Math.min(
      100,
      (lowParams / fullParams) * 100
    );

  lowBar.style.width = `${percent}%`;
}

rankSlider.addEventListener(
  "input",
  updateSlider
);

updateSlider();

const copyButton =
  document.getElementById("copy-bibtex");

copyButton.addEventListener(
  "click",
  () => {

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

  }
);
