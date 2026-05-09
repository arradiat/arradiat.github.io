# Singular Bayesian Neural Networks Slides

Open locally from the repository root:

```bash
cd /Users/princessemame/Documents/Playground
python3 -m http.server 8080
```

Then visit:

```text
http://localhost:8080/projects/singular-bnn/slides/
```

Export to PDF with Reveal.js print mode:

1. Open `http://localhost:8080/projects/singular-bnn/slides/?print-pdf`.
2. In Chrome or Edge, choose Print.
3. Set destination to Save as PDF.
4. Use landscape orientation.
5. Enable background graphics.
6. Set margins to none.
7. Save the PDF for ICML upload.

The deck vendors the Reveal.js runtime in `vendor/reveal/`, so it can be opened and exported without a CDN dependency.
