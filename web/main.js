/* ============================================================
   FANCYBASH — Main JavaScript
   ============================================================ */

// ─── Navbar scroll effect ──────────────────────────────────
const navbar = document.getElementById('navbar');
const onScroll = () => {
  navbar.classList.toggle('scrolled', window.scrollY > 20);
};
window.addEventListener('scroll', onScroll, { passive: true });
onScroll();

// ─── Mobile nav toggle ────────────────────────────────────
const navToggle = document.getElementById('nav-toggle');
const navMobile = document.getElementById('nav-links-mobile');

function openNav() {
  navMobile.classList.add('is-open');
  navToggle.classList.add('is-open');
  navToggle.setAttribute('aria-expanded', 'true');
  navMobile.setAttribute('aria-hidden', 'false');
}

function closeNav() {
  navMobile.classList.remove('is-open');
  navToggle.classList.remove('is-open');
  navToggle.setAttribute('aria-expanded', 'false');
  navMobile.setAttribute('aria-hidden', 'true');
}

navToggle?.addEventListener('click', (e) => {
  e.stopPropagation();
  navMobile.classList.contains('is-open') ? closeNav() : openNav();
});

// Close on outside click
document.addEventListener('click', (e) => {
  if (navMobile.classList.contains('is-open') &&
      !navMobile.contains(e.target) &&
      !navToggle.contains(e.target)) {
    closeNav();
  }
});

// Close when a nav link is tapped
navMobile?.querySelectorAll('a').forEach(link => {
  link.addEventListener('click', closeNav);
});

// Close when resizing back to desktop width
window.addEventListener('resize', () => {
  if (window.innerWidth > 768) closeNav();
}, { passive: true });

// ─── Install tab switching ────────────────────────────────
const tabBtns = document.querySelectorAll('.tab-btn');
const tabPanels = document.querySelectorAll('.tab-panel');

tabBtns.forEach(btn => {
  btn.addEventListener('click', () => {
    const targetTab = btn.dataset.tab;

    tabBtns.forEach(b => {
      b.classList.remove('active');
      b.setAttribute('aria-selected', 'false');
    });
    tabPanels.forEach(p => {
      p.classList.remove('active');
      p.hidden = true;
    });

    btn.classList.add('active');
    btn.setAttribute('aria-selected', 'true');

    const panel = document.getElementById(`tab-${targetTab}`);
    if (panel) {
      panel.classList.add('active');
      panel.hidden = false;
    }
  });
});

// ─── Uninstall tab switching ────────────────────────────────
const utabBtns = document.querySelectorAll('.utab-btn');
const utabPanels = document.querySelectorAll('.utab-panel');

utabBtns.forEach(btn => {
  btn.addEventListener('click', () => {
    const targetTab = btn.dataset.utab;

    utabBtns.forEach(b => {
      b.classList.remove('active');
      b.setAttribute('aria-selected', 'false');
    });
    utabPanels.forEach(p => {
      p.classList.remove('active');
      p.hidden = true;
    });

    btn.classList.add('active');
    btn.setAttribute('aria-selected', 'true');

    const panel = document.getElementById(`utab-${targetTab}`);
    if (panel) {
      panel.classList.add('active');
      panel.hidden = false;
    }
  });
});

// ─── Command category tabs ────────────────────────────────
const cmdCatBtns = document.querySelectorAll('.cmd-cat-btn');
const cmdPanels = document.querySelectorAll('.cmd-panel');

cmdCatBtns.forEach(btn => {
  btn.addEventListener('click', () => {
    const cat = btn.dataset.cat;

    cmdCatBtns.forEach(b => {
      b.classList.remove('active');
      b.setAttribute('aria-selected', 'false');
    });
    cmdPanels.forEach(p => {
      p.classList.remove('active');
      p.hidden = true;
    });

    btn.classList.add('active');
    btn.setAttribute('aria-selected', 'true');

    const panel = document.querySelector(`.cmd-panel[data-panel="${cat}"]`);
    if (panel) {
      panel.classList.add('active');
      panel.hidden = false;
    }
  });
});

// ─── Copy buttons ─────────────────────────────────────────
document.querySelectorAll('.copy-btn').forEach(btn => {
  btn.addEventListener('click', async () => {
    const text = btn.dataset.copy;
    if (!text) return;

    try {
      await navigator.clipboard.writeText(text);
      const original = btn.innerHTML;
      btn.classList.add('copied');
      btn.innerHTML = `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg> Copied!`;

      setTimeout(() => {
        btn.innerHTML = original;
        btn.classList.remove('copied');
      }, 2000);
    } catch {
      // Fallback for older browsers
      const textarea = document.createElement('textarea');
      textarea.value = text;
      textarea.style.position = 'fixed';
      textarea.style.opacity = '0';
      document.body.appendChild(textarea);
      textarea.select();
      document.execCommand('copy');
      document.body.removeChild(textarea);
    }
  });
});

// ─── Terminal typewriter animation ────────────────────────
const typedEl = document.getElementById('typed-text');
const outputEl = document.getElementById('terminal-output');

const demos = [
  {
    cmd: 'gwip "feat: add auth middleware"',
    output: '<span style="color:#22c55e">✓</span> Staged all files<br><span style="color:#22c55e">✓</span> Committed: feat: add auth middleware<br><span style="color:#22d3ee">→</span> Pushed to main'
  },
  {
    cmd: 'uup',
    output: '<span style="color:#a855f7">⚡ Opening fzf maintenance menu...</span><br><span style="color:#64748b">0. ALL_MAINTENANCE_TASKS</span><br><span style="color:#64748b">1. Core_System_Update ...</span>'
  },
  {
    cmd: 'gen 32',
    output: '<span style="color:#f59e0b">🔑</span> <span style="color:#22d3ee">a7f3d9c2e8b14056...</span>'
  },
  {
    cmd: 'vite',
    output: '<span style="color:#a855f7">⚡ Setup Vite with Bun + Tailwind CSS v4</span><br><span style="color:#22c55e">✓</span> Project ready! Run <span style="color:#22d3ee">brd</span> to start.'
  },
  {
    cmd: 'uu',
    output: '<span style="color:#a855f7">📦 Scanning apt + snap + flatpak + AppImage...</span><br><span style="color:#64748b">TAB to multi-select, ENTER to remove</span>'
  }
];

let demoIdx = 0;
let charIdx = 0;
let isTyping = false;
let typingTimer = null;

function typeChar() {
  const demo = demos[demoIdx];
  if (charIdx < demo.cmd.length) {
    typedEl.textContent += demo.cmd[charIdx];
    charIdx++;
    const delay = 40 + Math.random() * 30;
    typingTimer = setTimeout(typeChar, delay);
  } else {
    // Show output after brief pause
    typingTimer = setTimeout(() => {
      outputEl.innerHTML = demo.output;
      // Clear and move to next demo
      typingTimer = setTimeout(nextDemo, 2500);
    }, 400);
  }
}

function nextDemo() {
  demoIdx = (demoIdx + 1) % demos.length;
  charIdx = 0;
  typedEl.textContent = '';
  outputEl.innerHTML = '';
  typingTimer = setTimeout(typeChar, 600);
}

// Start after a short delay
typingTimer = setTimeout(typeChar, 1200);

// ─── Counter animation ────────────────────────────────────
function animateCounter(el, target, duration = 1200) {
  const start = performance.now();
  const step = (now) => {
    const progress = Math.min((now - start) / duration, 1);
    const eased = 1 - Math.pow(1 - progress, 3);
    el.textContent = Math.round(eased * target);
    if (progress < 1) requestAnimationFrame(step);
  };
  requestAnimationFrame(step);
}

const counterEls = document.querySelectorAll('[data-target]');
const counterObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const el = entry.target;
      const target = parseInt(el.dataset.target, 10);
      animateCounter(el, target);
      counterObserver.unobserve(el);
    }
  });
}, { threshold: 0.5 });

counterEls.forEach(el => counterObserver.observe(el));

// ─── Fallback scroll reveal (for browsers without scroll-driven animations) ─
if (!CSS.supports('(animation-timeline: view()) and (animation-range: entry)')) {
  const revealEls = document.querySelectorAll('.feature-card, .pe-item, .step-item, .stat-item');

  const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry, i) => {
      if (entry.isIntersecting) {
        setTimeout(() => {
          entry.target.classList.add('visible');
        }, i * 80);
        revealObserver.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' });

  revealEls.forEach(el => revealObserver.observe(el));
}

// ─── Smooth anchor scroll with offset ────────────────────
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
  anchor.addEventListener('click', (e) => {
    const target = document.querySelector(anchor.getAttribute('href'));
    if (target) {
      e.preventDefault();
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  });
});
