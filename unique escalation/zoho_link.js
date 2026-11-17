const statusEl = document.getElementById("status");
const rowsEl = document.getElementById("rows");
const filterInput = document.getElementById("filter");
const headerCells = document.querySelectorAll("thead th[data-key]");

let allRows = [];
let sortKey = "Company";
let sortDir = "asc";
let zohoOptions = [];
let activeRow = null;
let selectedZoho = null;

const modal = document.getElementById("modal");
const modalMeta = document.getElementById("modalMeta");
const zohoSearch = document.getElementById("zohoSearch");
const zohoOptionsEl = document.getElementById("zohoOptions");
const cancelBtn = document.getElementById("cancelBtn");
const saveBtn = document.getElementById("saveBtn");
const updateEndpoint = "/CC_Escalation/unique%20escalation/zoho_link_update.sql";
const selectPanel = document.getElementById("selectPanel");
const confirmPanel = document.getElementById("confirmPanel");
const confirmCompany = document.getElementById("confirmCompany");
const confirmFleet = document.getElementById("confirmFleet");
const confirmOld = document.getElementById("confirmOld");
const confirmNew = document.getElementById("confirmNew");
const backBtn = document.getElementById("backBtn");
const confirmBtn = document.getElementById("confirmBtn");
const toast = document.getElementById("toast");

function setStatus(text) {
  statusEl.textContent = text;
}

function showToast(message, type) {
  toast.textContent = message;
  toast.className = "toast" + (type ? " " + type : "");
  toast.style.display = "block";
  setTimeout(() => {
    toast.style.display = "none";
  }, 3500);
}

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

function normalize(value) {
  return (value || "").toString().toLowerCase();
}

function applyFilter(rows, term) {
  if (!term) return rows;
  const t = term.toLowerCase();
  return rows.filter((row) => {
    return (
      normalize(row.Company).includes(t) ||
      normalize(row.Fleet).includes(t) ||
      normalize(row.ZohoAccount).includes(t)
    );
  });
}

function applySort(rows) {
  const key = sortKey;
  const dir = sortDir === "asc" ? 1 : -1;
  return [...rows].sort((a, b) => {
    const av = normalize(a[key]);
    const bv = normalize(b[key]);
    if (av < bv) return -1 * dir;
    if (av > bv) return 1 * dir;
    return 0;
  });
}

function updateHeaderIndicators() {
  headerCells.forEach((th) => {
    th.classList.remove("sort-asc", "sort-desc");
    if (th.dataset.key === sortKey) {
      th.classList.add(sortDir === "asc" ? "sort-asc" : "sort-desc");
    }
  });
}

function renderRows(rows) {
  rowsEl.innerHTML = "";
  if (!rows || !rows.length) {
    setStatus("No data returned.");
    return;
  }
  setStatus("");
  rows.forEach((row) => {
    const tr = document.createElement("tr");

    const tdCompany = document.createElement("td");
    tdCompany.textContent = row.Company || "";
    tr.appendChild(tdCompany);

    const tdFleet = document.createElement("td");
    tdFleet.textContent = row.Fleet || "";
    tr.appendChild(tdFleet);

    const tdZoho = document.createElement("td");
    tdZoho.textContent = row.ZohoAccount || "N/A";
    tr.appendChild(tdZoho);

    const tdActions = document.createElement("td");
    const actions = document.createElement("div");
    actions.className = "actions";

    const viewLink = document.createElement("a");
    viewLink.className = "btn alt";
    viewLink.textContent = "View Escalation List";
    if (row.HasUniqueEscalation && row.UniqueEscalationId) {
      viewLink.href =
        "https://example.invalid/configure-endpoint" +
        row.UniqueEscalationId;
      viewLink.target = "_blank";
      viewLink.rel = "noopener noreferrer";
    } else if (row.ZohoId) {
      viewLink.href =
        "https://example.invalid/configure-endpoint" + row.ZohoId;
      viewLink.target = "_blank";
      viewLink.rel = "noopener noreferrer";
    } else {
      viewLink.classList.add("disabled");
      viewLink.href = "#";
      viewLink.title = "No Zoho ID";
    }
    actions.appendChild(viewLink);

    const editBtn = document.createElement("button");
    editBtn.className = "btn";
    editBtn.type = "button";
    editBtn.textContent = "Map Account";
    if (row.HasUniqueEscalation) {
      editBtn.classList.add("disabled");
      const badge = document.createElement("span");
      badge.className = "badge green";
      badge.textContent = "Unique Escalation";
      tdActions.appendChild(badge);
    } else {
      editBtn.addEventListener("click", () => {
        openModal(row);
      });
    }
    actions.appendChild(editBtn);

    tdActions.appendChild(actions);
    tr.appendChild(tdActions);

    rowsEl.appendChild(tr);
  });
}

function render() {
  const filtered = applyFilter(allRows, filterInput.value.trim());
  const sorted = applySort(filtered);
  renderRows(sorted);
}

function openModal(row) {
  activeRow = row;
  selectedZoho = null;
  modalMeta.textContent =
    (row.Company || "") + " — " + (row.Fleet || "") + " (current: " + (row.ZohoAccount || "N/A") + ")";
  zohoSearch.value = "";
  renderZohoOptions("");
  saveBtn.disabled = true;
  confirmBtn.disabled = false;
  selectPanel.style.display = "block";
  confirmPanel.style.display = "none";
  modal.style.display = "flex";
  modal.setAttribute("aria-hidden", "false");
  zohoSearch.focus();

  if (typeof window.loadZohoAccountOptions === "function") {
    window.loadZohoAccountOptions().then((options) => {
      if (!Array.isArray(options) || !options.length) return;
      zohoOptions = options;
      renderZohoOptions(zohoSearch.value || "");
    });
  }
}

function closeModal() {
  modal.style.display = "none";
  modal.setAttribute("aria-hidden", "true");
}

function renderZohoOptions(term) {
  zohoOptionsEl.innerHTML = "";
  const t = term.toLowerCase();
  const filtered = zohoOptions.filter((opt) =>
    opt.label.toLowerCase().includes(t)
  );
  if (!filtered.length) {
    const empty = document.createElement("div");
    empty.className = "option";
    empty.textContent = "No matches";
    zohoOptionsEl.appendChild(empty);
    return;
  }
  filtered.forEach((opt) => {
    const div = document.createElement("div");
    div.className = "option";
    div.textContent = opt.label;
    div.addEventListener("click", () => {
      selectedZoho = opt;
      document.querySelectorAll(".option").forEach((el) => {
        el.classList.remove("active");
      });
      div.classList.add("active");
      saveBtn.disabled = false;
    });
    zohoOptionsEl.appendChild(div);
  });
}

zohoSearch.addEventListener("input", (e) => {
  renderZohoOptions(e.target.value);
});

cancelBtn.addEventListener("click", () => {
  closeModal();
});

modal.addEventListener("click", (e) => {
  if (e.target === modal) closeModal();
});

saveBtn.addEventListener("click", () => {
  if (!activeRow || !selectedZoho) return;
  confirmCompany.textContent = activeRow.Company || "";
  confirmFleet.textContent = activeRow.Fleet || "";
  confirmOld.textContent = activeRow.ZohoAccount || "N/A";
  confirmNew.textContent = selectedZoho.label || "";
  selectPanel.style.display = "none";
  confirmPanel.style.display = "block";
});

backBtn.addEventListener("click", () => {
  confirmPanel.style.display = "none";
  selectPanel.style.display = "block";
});

confirmBtn.addEventListener("click", () => {
  if (!activeRow || !selectedZoho) return;

  const body = new URLSearchParams();
  body.set("company", activeRow.Company || "");
  body.set("fleet_code", activeRow.Fleet || "");
  body.set("new_zoho_id", selectedZoho.id || "");

  confirmBtn.disabled = true;

  fetch(updateEndpoint, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: body.toString(),
  })
    .then((r) => r.text())
    .then(() => {
      activeRow.ZohoAccount = selectedZoho.label;
      activeRow.ZohoId = selectedZoho.id;
      closeModal();
      render();
      showToast("Update completed successfully.", "success");
    })
    .catch(() => {
      setStatus("Update failed.");
      confirmBtn.disabled = false;
    });
});

headerCells.forEach((th) => {
  th.addEventListener("click", () => {
    const key = th.dataset.key;
    if (sortKey === key) {
      sortDir = sortDir === "asc" ? "desc" : "asc";
    } else {
      sortKey = key;
      sortDir = "asc";
    }
    updateHeaderIndicators();
    render();
  });
});

filterInput.addEventListener("input", () => {
  render();
});

fetch("/CC_Escalation/unique%20escalation/zoho_link.sql")
  .then((r) => r.text())
  .then((companyText) => {
    const payload = parseSqlPagePayload(companyText);
    if (!payload) {
      setStatus("Unexpected response.");
      return;
    }

    allRows = payload && payload.Rows ? payload.Rows : [];

    const fallbackMap = new Map();
    allRows.forEach((row) => {
      if (row.ZohoId && row.ZohoAccount) {
        fallbackMap.set(row.ZohoId, row.ZohoAccount);
      }
    });
    zohoOptions = Array.from(fallbackMap.entries()).map(([id, label]) => ({
      id,
      label,
    }));

    if (typeof window.loadZohoAccountOptions === "function") {
      window.loadZohoAccountOptions().then((options) => {
        if (!Array.isArray(options) || !options.length) return;
        zohoOptions = options;
        if (modal.getAttribute("aria-hidden") === "false") {
          renderZohoOptions(zohoSearch.value || "");
        }
      });
    }

    updateHeaderIndicators();
    render();
  })
  .catch(() => {
    setStatus("Failed to load data.");
  });
