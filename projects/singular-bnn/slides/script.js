Reveal.initialize({
  hash: true,
  controls: true,
  progress: true,
  center: false,
  width: 1280,
  height: 720,
  margin: 0.045,
  transition: "fade",
  backgroundTransition: "fade",
  pdfSeparateFragments: false
});

const canvases = Array.from(document.querySelectorAll(".manifold-canvas"));
const contexts = canvases.map((canvas) => ({
  canvas,
  ctx: canvas.getContext("2d"),
  variant: canvas.dataset.variant || "manifold"
}));

function resizeCanvas(canvas) {
  const rect = canvas.getBoundingClientRect();
  const ratio = window.devicePixelRatio || 1;
  canvas.width = Math.max(1, Math.floor(rect.width * ratio));
  canvas.height = Math.max(1, Math.floor(rect.height * ratio));
  canvas.style.width = `${rect.width}px`;
  canvas.style.height = `${rect.height}px`;
  canvas.getContext("2d").setTransform(ratio, 0, 0, ratio, 0, 0);
}

function drawField({ canvas, ctx, variant }, time) {
  const w = canvas.clientWidth;
  const h = canvas.clientHeight;
  ctx.clearRect(0, 0, w, h);

  const cx = variant === "title" ? w * 0.73 : w * 0.58;
  const cy = variant === "closing" ? h * 0.48 : h * 0.5;
  const amp = variant === "manifold" ? 92 : 58;
  const rows = 42;
  const cols = 70;

  ctx.save();
  ctx.translate(cx, cy);
  ctx.rotate(-0.18);

  for (let j = 0; j < rows; j += 1) {
    ctx.beginPath();
    for (let i = 0; i < cols; i += 1) {
      const x = (i / (cols - 1) - 0.5) * w * 0.86;
      const yBase = (j / (rows - 1) - 0.5) * h * 0.58;
      const z = Math.sin(i * 0.25 + time * 0.0012) * Math.cos(j * 0.19 + time * 0.0008);
      const y = yBase + z * amp * Math.sin((i / cols) * Math.PI);
      if (i === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    }
    ctx.strokeStyle = `rgba(96, 230, 242, ${0.035 + (j / rows) * 0.07})`;
    ctx.lineWidth = 1;
    ctx.stroke();
  }

  const particleCount = variant === "manifold" ? 210 : 110;
  for (let k = 0; k < particleCount; k += 1) {
    const u = ((k * 37) % 1000) / 1000;
    const v = ((k * 73) % 1000) / 1000;
    const drift = time * 0.000045;
    const x = ((u + drift) % 1 - 0.5) * w * 0.82;
    const yBase = (v - 0.5) * h * 0.54;
    const z = Math.sin(u * 18 + time * 0.001) * Math.cos(v * 16 + time * 0.0014);
    const y = yBase + z * amp * 0.72 * Math.sin(u * Math.PI);
    ctx.beginPath();
    ctx.arc(x, y, variant === "manifold" ? 1.55 : 1.15, 0, Math.PI * 2);
    ctx.fillStyle = k % 5 === 0 ? "rgba(233,185,107,.48)" : "rgba(96,230,242,.42)";
    ctx.fill();
  }
  ctx.restore();
}

function render(time) {
  contexts.forEach((item) => {
    const slide = item.canvas.closest("section");
    if (!slide || slide.classList.contains("present")) drawField(item, time);
  });
  window.requestAnimationFrame(render);
}

function resizeAll() {
  canvases.forEach(resizeCanvas);
}

window.addEventListener("resize", resizeAll);
Reveal.on("slidechanged", resizeAll);
resizeAll();
window.requestAnimationFrame(render);
