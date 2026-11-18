(() => {
  const root = document.documentElement;
  const themeToggle = document.getElementById('themeToggle');
  const themeIcon = document.getElementById('themeIcon');
  const mobileMenuBtn = document.getElementById('mobileMenuBtn');
  const navLinks = document.getElementById('navLinks');
  const toast = document.getElementById('toast');
  const yearEl = document.getElementById('currentYear');

  if (yearEl) {
    yearEl.textContent = new Date().getFullYear().toString();
  }

  // Theme persistence
  const savedTheme = localStorage.getItem('rd_portfolio_theme');
  if (savedTheme === 'light' || savedTheme === 'dark') {
    root.setAttribute('data-theme', savedTheme);
  }
  const syncThemeIcon = () => {
    const isLight = root.getAttribute('data-theme') === 'light';
    if (themeIcon) themeIcon.textContent = isLight ? '🌙' : '☀️';
  };
  syncThemeIcon();

  themeToggle?.addEventListener('click', () => {
    const next = root.getAttribute('data-theme') === 'light' ? 'dark' : 'light';
    root.setAttribute('data-theme', next);
    localStorage.setItem('rd_portfolio_theme', next);
    syncThemeIcon();
  });

  // Mobile menu toggle
  mobileMenuBtn?.addEventListener('click', () => {
    const isOpen = navLinks?.classList.toggle('open') ?? false;
    mobileMenuBtn.setAttribute('aria-expanded', String(isOpen));
  });

  navLinks?.querySelectorAll('a').forEach((link) => {
    link.addEventListener('click', () => {
      navLinks.classList.remove('open');
      mobileMenuBtn?.setAttribute('aria-expanded', 'false');
    });
  });

  // Skill category filter
  const filterBtns = document.querySelectorAll('.filter-btn');
  const skillCards = document.querySelectorAll('.skill-card');

  filterBtns.forEach((btn) => {
    btn.addEventListener('click', () => {
      const filter = btn.getAttribute('data-filter');
      filterBtns.forEach((b) => b.classList.remove('active'));
      btn.classList.add('active');

      skillCards.forEach((card) => {
        const category = card.getAttribute('data-category');
        const visible = filter === 'all' || category === filter;
        card.classList.toggle('hidden', !visible);
      });
    });
  });

  // Copy email / phone helper
  let toastTimer = null;
  const showToast = (msg) => {
    if (!toast) return;
    toast.textContent = msg;
    toast.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => toast.classList.remove('show'), 2200);
  };

  document.querySelectorAll('.copy-trigger').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const value = btn.getAttribute('data-copy');
      if (!value) return;
      try {
        await navigator.clipboard.writeText(value);
        showToast(`Copied: ${value}`);
      } catch {
        showToast(value);
      }
    });
  });

  // Scroll spy for active nav link
  const sections = document.querySelectorAll('main section[id]');
  const navAnchors = document.querySelectorAll('.nav-links a[href^="#"]');
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        const id = entry.target.getAttribute('id');
        navAnchors.forEach((a) => {
          a.classList.toggle('active', a.getAttribute('href') === `#${id}`);
        });
      });
    },
    { rootMargin: '-35% 0px -55% 0px' },
  );

  sections.forEach((sec) => observer.observe(sec));
})();
