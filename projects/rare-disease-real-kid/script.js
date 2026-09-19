const nav = document.querySelector('.site-nav');
const revealItems = document.querySelectorAll('.reveal');
const sections = document.querySelectorAll('main section[id]');
const navLinks = document.querySelectorAll('.nav-links a');
const chart = document.querySelector('.bar-chart');
const modelToggle = document.querySelector('[data-toggle-models]');
const modelGrid = document.querySelector('#model-grid');

const updateNav = () => {
  nav.classList.toggle('scrolled', window.scrollY > 12);

  let current = '';
  sections.forEach((section) => {
    if (window.scrollY >= section.offsetTop - 150) current = section.id;
  });
  navLinks.forEach((link) => {
    link.classList.toggle('active', link.getAttribute('href') === `#${current}`);
  });
};

window.addEventListener('scroll', updateNav, { passive: true });
updateNav();

if ('IntersectionObserver' in window) {
  const revealObserver = new IntersectionObserver((entries, observer) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return;
      entry.target.classList.add('is-visible');
      observer.unobserve(entry.target);
    });
  }, { threshold: 0.13, rootMargin: '0px 0px -35px' });

  revealItems.forEach((item) => revealObserver.observe(item));

  if (chart) {
    const chartObserver = new IntersectionObserver((entries, observer) => {
      if (!entries[0].isIntersecting) return;
      chart.classList.add('is-visible');
      observer.disconnect();
    }, { threshold: 0.35 });
    chartObserver.observe(chart);
  }
} else {
  revealItems.forEach((item) => item.classList.add('is-visible'));
  chart?.classList.add('is-visible');
}

modelToggle?.addEventListener('click', () => {
  const opening = modelToggle.getAttribute('aria-expanded') !== 'true';
  modelToggle.setAttribute('aria-expanded', String(opening));
  modelGrid.hidden = !opening;
  modelToggle.childNodes[0].textContent = opening ? 'Hide model details ' : 'Meet all nine models ';
});

document.querySelector('[data-back-top]')?.addEventListener('click', (event) => {
  event.preventDefault();
  window.scrollTo({ top: 0, behavior: 'smooth' });
});
