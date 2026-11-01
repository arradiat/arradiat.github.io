(() => {
  const button = document.getElementById('copy-bibtex');
  const status = document.getElementById('copy-status');
  const citation = document.getElementById('bibtex');
  button.addEventListener('click', async () => {
    try {
      await navigator.clipboard.writeText(citation.textContent);
      button.textContent = 'Copied';
      status.textContent = 'Citation copied to clipboard.';
    } catch {
      const selection = window.getSelection();
      const range = document.createRange();
      range.selectNodeContents(citation);
      selection.removeAllRanges();
      selection.addRange(range);
      status.textContent = 'Citation selected. Use your keyboard shortcut to copy.';
    }
  });
})();
