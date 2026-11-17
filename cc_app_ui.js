// Presentation preferences only; submission, operator identity and draft storage remain in cc_escalation.js.
(function () {
  const shell = document.querySelector('.escalation-view');
  const sidebarButton = document.querySelector('#ccSidebarToggle');
  const themeToggle = document.querySelector('#ccThemeToggle');
  const compact = window.matchMedia('(max-width: 980px)');
  function setCollapsed(collapsed, remember = false) {
    shell.classList.toggle('cc-sidebar-collapsed', collapsed);
    sidebarButton.setAttribute('aria-expanded', String(!collapsed));
    sidebarButton.setAttribute('aria-label', collapsed ? 'Expand sidebar' : 'Collapse sidebar');
    sidebarButton.title = collapsed ? 'Expand sidebar' : 'Collapse sidebar';
    if (remember) try { localStorage.setItem('Application-sidebar-collapsed', collapsed ? '1' : '0'); } catch (_) { /* Preferences are optional. */ }
  }
  function syncThemeToggle() {
    const light = document.documentElement.dataset.theme === 'light';
    themeToggle.checked = !light;
    themeToggle.setAttribute('aria-label', light ? 'Switch to dark mode' : 'Switch to light mode');
    themeToggle.title = light ? 'Switch to dark mode' : 'Switch to light mode';
  }
  function setTheme(theme) {
    document.documentElement.dataset.theme = theme;
    try { localStorage.setItem('srf-jobcard-theme', theme); } catch (_) { /* Keep the chosen theme for this page. */ }
    syncThemeToggle();
  }
  let collapsed = compact.matches;
  let theme = 'dark';
  try { collapsed = compact.matches || localStorage.getItem('Application-sidebar-collapsed') === '1'; theme = localStorage.getItem('srf-jobcard-theme') === 'light' ? 'light' : 'dark'; } catch (_) { /* Defaults work without browser storage. */ }
  setCollapsed(collapsed); setTheme(theme);
  sidebarButton.addEventListener('click', () => setCollapsed(!shell.classList.contains('cc-sidebar-collapsed'), true));
  themeToggle.addEventListener('change', event => setTheme(event.target.checked ? 'dark' : 'light'));
  document.querySelector('#ccHeaderQuickLog').addEventListener('click', () => document.querySelector('#openQuickLogButton').click());
  compact.addEventListener('change', event => setCollapsed(event.matches));
  window.addEventListener('storage', event => {
    if (event.key === 'srf-jobcard-theme') setTheme(event.newValue === 'light' ? 'light' : 'dark');
  });
  const completed = new URLSearchParams(window.location.search).get('completed') === '1';
  const active = document.querySelector(completed ? '#ccCompletedLogsNav' : '#ccOpenLogsNav');
  active.classList.add('active', 'is-active'); active.setAttribute('aria-current', 'page');
}());
