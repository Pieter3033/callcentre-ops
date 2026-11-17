(function (global) {
  const endpoint = "/CC_Escalation/unique%20escalation/zoho_link_options.sql";
  let cachedPromise = null;

  function parseSqlPagePayload(text) {
    let payload = null;
    try {
      payload = JSON.parse(text);
    } catch {
      return null;
    }

    if (payload && payload.contents) {
      try {
        payload = JSON.parse(payload.contents);
      } catch {}
    }
    return payload;
  }

  function normalizeOptions(rows) {
    const optionMap = new Map();
    rows.forEach((opt) => {
      if (!opt || !opt.id || !opt.label) return;
      if (!optionMap.has(opt.id)) {
        optionMap.set(opt.id, opt.label);
      }
    });
    return Array.from(optionMap.entries()).map(([id, label]) => ({
      id,
      label,
    }));
  }

  function loadZohoAccountOptions(forceRefresh) {
    if (cachedPromise && !forceRefresh) {
      return cachedPromise;
    }

    cachedPromise = fetch(endpoint)
      .then((r) => r.text())
      .then((text) => {
        const payload = parseSqlPagePayload(text);
        if (!payload) return [];

        let rows = payload.Rows;
        if (typeof rows === "string") {
          try {
            rows = JSON.parse(rows);
          } catch {
            rows = [];
          }
        }
        if (!Array.isArray(rows)) return [];

        return normalizeOptions(rows);
      })
      .catch(() => []);

    return cachedPromise;
  }

  global.loadZohoAccountOptions = loadZohoAccountOptions;
})(window);
