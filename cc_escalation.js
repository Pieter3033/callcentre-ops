const api = {
  detail: "api_main_detail.sql",
  quickLogOptions: "api_quick_log_options.sql",
  quickLogSubmit: "quick_log_submit.sql",
  quickLogStatus: "api_quick_log_status.sql",
  openQuickLogsCount: "/internaltickets/api_open_quick_logs_count.sql"
};

const params = new URLSearchParams(window.location.search);
const regNo = params.get("reg_no") || "";
const eventName = params.get("event") || "";
const completedQuickLogView = params.get("completed") === "1";
let seqno = params.get("seqno") || "";
let quickLogRowCounter = 0;
let quickLogDraftLoaded = false;
let quickLogDraftDirty = false;
let quickLogReturnFocus = null;
let draggedQuickLogRow = null;
let quickLogDragPoint = null;
let quickLogDragFrame = null;
let quickLogDragTime = null;
let quickLogSubmitting = false;
let quickLogSubmissionId = null;
let quickLogAttemptFingerprint = null;
let quickLogRestoredDraftKey = null;
let quickLogBaseSnapshot = null;
const quickLogDraftSnapshots = new Map();
let quickLogDraftRestoreError = null;
let quickLogStatusTimer = null;
let quickLogStatusAttempts = 0;
let quickLogNavCountRequest = 0;

const state = {
  quickLogOptions: null,
  pageData: null
};

const quickLogSeatStorageKey = () => `cc-escalation-quick-log-seat:${[regNo, eventName, seqno || "new"].map((value) => String(value || "").trim()).join("|")}`;

const elements = {
  quickLogNavCount: document.querySelector("#ccOpenLogsCount"),
  title: document.querySelector("#pageTitle"),
  registrationValue: document.querySelector("#registrationValue"),
  fleetDescriptionValue: document.querySelector("#fleetDescriptionValue"),
  openZoho: document.querySelector("#openZohoLink"),
  openInfodash: document.querySelector("#openInfodashLink"),
  openQuickLog: document.querySelector("#openQuickLogButton"),
  vehicleInfoToggle: document.querySelector("#vehicleInfoToggle"),
  vehicleInfoPanel: document.querySelector("#vehicleInfoPanel"),
  vehicleInfoDismiss: document.querySelector("#vehicleInfoDismiss"),
  vehicleInfoCopy: document.querySelector("#vehicleInfoCopy"),
  vehicleInfoCopyIndicator: document.querySelector("#vehicleInfoCopyIndicator"),
  vehicleInfoCopyStatus: document.querySelector("#vehicleInfoCopyStatus"),
  vehicleInfoValue: document.querySelector("#vehicleInfoValue"),
  summary: document.querySelector("#summaryGrid"),
  summaryFacts: document.querySelector("#summaryFacts"),
  authSection: document.querySelector("#authSection"),
  eventNote: document.querySelector("#eventNote"),
  eventNoteCount: document.querySelector("#eventNoteCount"),
  eventNoteLabel: document.querySelector("#eventNoteLabel"),
  authNotes: document.querySelector("#authNotes"),
  contactSections: document.querySelector("#contactSections"),
  notice: document.querySelector("#notice"),
  quickLogOverlay: document.querySelector("#quickLogOverlay"),
  quickLogDismiss: document.querySelector("#quickLogDismiss"),
  quickLogForm: document.querySelector("#quickLogForm"),
  quickLogOperator: document.querySelector("#quickLogOperator"),
  quickLogSeat: document.querySelector("#quickLogSeat"),
  quickLogRows: document.querySelector("#quickLogRows"),
  quickLogAddRow: document.querySelector("#quickLogAddRow"),
  quickLogSaveDraft: document.querySelector("#quickLogSaveDraft"),
  quickLogSubmit: document.querySelector("#quickLogSubmitButton"),
  quickLogSubmitNote: document.querySelector("#quickLogSubmitNote"),
  quickLogDraftStatus: document.querySelector("#quickLogDraftStatus"),
  quickLogEntryCount: document.querySelector("#quickLogEntryCount"),
  quickLogMessage: document.querySelector("#quickLogMessage"),
  quickLogContext: document.querySelector("#quickLogContext"),
  quickLogHistory: document.querySelector("#quickLogHistory"),
  quickLogHistoryCount: document.querySelector("#quickLogHistoryCount"),
  quickLogHistoryList: document.querySelector("#quickLogHistoryList")
};

function escapeHtml(value) {
  return String(value ?? "").replace(/[&<>"']/g, (char) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#039;"
  }[char]));
}

function valueIsBlank(value) {
  return value === null || value === undefined || String(value).trim() === "";
}

function linkifyText(value) {
  const escaped = escapeHtml(value || "");
  return escaped.replace(/https?:\/\/[^\s<>"']+/g, (url) => {
    const trailing = url.match(/[),.;!?]+$/)?.[0] || "";
    const href = trailing ? url.slice(0, -trailing.length) : url;
    return `<a href="${href}" target="_blank" rel="noopener noreferrer">${href}</a>${trailing}`;
  });
}

function phoneLink(value, contactName) {
  const text = String(value ?? "").trim();
  if (!/^[+()\d\s-]{7,}$/.test(text)) return escapeHtml(text || "-");
  return `
    <button class="contact-phone-button" type="button" data-phone="${escapeHtml(text)}" data-contact="${escapeHtml(contactName || "")}">
      ${escapeHtml(text)}
    </button>
  `;
}

function syncTheme() {
  let theme = "dark";
  try { theme = localStorage.getItem("srf-jobcard-theme") === "light" ? "light" : "dark"; } catch (_) { /* Use the default theme if storage is blocked. */ }
  document.documentElement.dataset.theme = theme;
}

function buildUrl(path) {
  const url = new URL(path, window.location.href);
  if (regNo) url.searchParams.set("reg_no", regNo);
  if (eventName) url.searchParams.set("event", eventName);
  if (seqno) url.searchParams.set("seqno", seqno);
  return url.toString();
}

function localDateTimeValue(date = new Date()) {
  const pad = (value) => String(value).padStart(2, "0");
  return [
    date.getFullYear(),
    pad(date.getMonth() + 1),
    pad(date.getDate())
  ].join("-") + `T${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

function sqlDateTimeValue(value) {
  if (valueIsBlank(value)) return "";
  const text = String(value).replace("T", " ");
  return text.length === 16 ? text + ":00" : text;
}

function copyText(text) {
  if (navigator.clipboard?.writeText) {
    return navigator.clipboard.writeText(text).catch(() => {
      const textarea = document.createElement("textarea");
      textarea.value = text;
      textarea.setAttribute("readonly", "true");
      textarea.style.position = "fixed";
      textarea.style.opacity = "0";
      document.body.appendChild(textarea);
      textarea.select();
      document.execCommand("copy");
      textarea.remove();
    });
  }

  const textarea = document.createElement("textarea");
  textarea.value = text;
  textarea.setAttribute("readonly", "true");
  textarea.style.position = "fixed";
  textarea.style.opacity = "0";
  document.body.appendChild(textarea);
  textarea.select();
  document.execCommand("copy");
  textarea.remove();
  return Promise.resolve();
}

function contactRows(record, prefix) {
  return Array.from({ length: 5 }, (_, index) => {
    const slot = index + 1;
    return {
      slot,
      name: record?.[`${prefix}_name_${slot}`],
      number: record?.[`${prefix}_no_${slot}`],
      altNumber: record?.[`${prefix}_alt_no_${slot}`],
      notes: record?.[`${prefix}_notes_${slot}`]
    };
  }).filter((contact) => [contact.name, contact.number, contact.altNumber, contact.notes].some((value) => !valueIsBlank(value)));
}

function escalationContacts(data) {
  const record = data.uniqueEscalation || data.escalation || {};
  const profile = data.uniqueEscalation ? null : data.clientEscalation || null;
  return {
    record,
    profile,
    day: profile ? profile.dayContacts : contactRows(record, "d_c"),
    night: contactRows(record, "n_c"),
    weekend: contactRows(record, "we_c")
  };
}

function clientInstructions(profile) {
  if (!profile) return "";
  return `<section class="detail-section" aria-label="CLIENT escalation instructions">
    <div class="section-header">
      <span class="section-icon">${iconSvg("document")}</span>
      <span class="section-title"><strong>${escapeHtml(profile.title)}</strong><small>Escalation instructions</small></span>
    </div>
    <div class="section-body"><div class="note-card">${linkifyText(profile.instructions).replace(/\n/g, "<br>")}</div></div>
  </section>`;
}

function iconSvg(name) {
  const icons = {
    truck: '<path d="M3 7h11v8H3z"></path><path d="M14 10h4l3 3v2h-7z"></path><circle cx="7" cy="18" r="2"></circle><circle cx="17" cy="18" r="2"></circle>',
    document: '<path d="M8 3h5l4 4v14H8a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z"></path><path d="M13 3v5h5"></path><path d="M9 13h6"></path><path d="M9 17h4"></path>',
    lock: '<rect x="5" y="10" width="14" height="10" rx="2"></rect><path d="M8 10V7a4 4 0 0 1 8 0v3"></path>',
    person: '<circle cx="12" cy="7" r="4"></circle><path d="M4 21a8 8 0 0 1 16 0"></path>',
    phone: '<path d="M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.5 19.5 0 0 1-6-6A19.8 19.8 0 0 1 2.1 4.2 2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1.9.3 1.8.6 2.6a2 2 0 0 1-.5 2.1L8 9.6a16 16 0 0 0 6.4 6.4l1.2-1.2a2 2 0 0 1 2.1-.5c.8.3 1.7.5 2.6.6a2 2 0 0 1 1.7 2Z"></path>',
    moon: '<path d="M20 14.2A7.5 7.5 0 0 1 9.8 4a8 8 0 1 0 10.2 10.2Z"></path>',
    calendar: '<path d="M8 2v4"></path><path d="M16 2v4"></path><rect x="4" y="5" width="16" height="15" rx="2"></rect><path d="M4 10h16"></path>',
    users: '<path d="M16 19c0-2.2-1.8-4-4-4H7c-2.2 0-4 1.8-4 4"></path><circle cx="9.5" cy="8" r="3"></circle><path d="M21 19c0-1.9-1.3-3.4-3.1-3.9"></path><path d="M16.5 5.2a3 3 0 0 1 0 5.6"></path>',
    infodash: '<rect x="4" y="4" width="6" height="6" rx="0"></rect><rect x="14" y="4" width="6" height="6" rx="0"></rect><rect x="4" y="14" width="6" height="6" rx="0"></rect><rect x="14" y="14" width="6" height="6" rx="0"></rect>'
  };
  return `<svg viewBox="0 0 24 24" aria-hidden="true">${icons[name] || icons.document}</svg>`;
}

function sideFact(icon, label, value) {
  return `
    <div class="side-fact">
      ${iconSvg(icon)}
      <span>${escapeHtml(label)}</span>
      <strong>${escapeHtml(value || "N/A")}</strong>
    </div>
  `;
}

function emptyState(message) {
  return `
    <div class="section-empty">
      <span>${iconSvg("users")}</span>
      <p>${escapeHtml(message)}</p>
    </div>
  `;
}

function initials(name, fallback) {
  const text = String(name || fallback || "").trim();
  const value = text
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase() || "")
    .join("");
  return value || String(fallback || "?");
}

function contactSection(title, subtitle, contacts) {
  const sectionIcon = title.includes("Night") ? "moon" : title.includes("Weekend") ? "calendar" : "users";
  return `
    <section class="detail-section">
      <div class="section-header">
        <span class="section-icon">${iconSvg(sectionIcon)}</span>
        <span class="section-title">
          <strong>${escapeHtml(title)}</strong>
          <small>${escapeHtml(subtitle)}</small>
        </span>
        <span class="section-count">${contacts.length}</span>
      </div>
      <div class="section-body">
      ${contacts.length ? `
        <div class="contact-grid">
          ${contacts.map((contact) => `
            <article class="contact-card">
              <span class="rank">${escapeHtml(initials(contact.name, contact.slot))}</span>
              <div class="contact-content">
                <h4>${escapeHtml(contact.name || `Contact ${contact.slot}`)}</h4>
                ${!valueIsBlank(contact.number) ? `<span class="contact-type">Primary</span>` : ""}
                <div class="contact-lines">
                  ${!valueIsBlank(contact.number) ? `<p>${iconSvg("phone")}${phoneLink(contact.number, contact.name || `Contact ${contact.slot}`)}</p>` : ""}
                  ${!valueIsBlank(contact.altNumber) ? `<p>${iconSvg("phone")}${phoneLink(contact.altNumber, contact.name || `Contact ${contact.slot}`)}</p>` : ""}
                  ${!valueIsBlank(contact.notes) ? `<p class="contact-note">${linkifyText(contact.notes)}</p>` : ""}
                </div>
              </div>
            </article>
          `).join("")}
        </div>
      ` : emptyState("No contacts captured for this escalation window.")}
      </div>
    </section>
  `;
}

function normalizeText(value) {
  return valueIsBlank(value) ? "N/A" : String(value).trim();
}

function vehicleInfoTemplate(info) {
  return [
    `Registration: ${normalizeText(info.registration)}`,
    `Fleet: ${normalizeText(info.fleetNo)}`,
    `Make: ${normalizeText(info.make)}`,
    `Model: ${normalizeText(info.model)}`,
    `Colour: ${normalizeText(info.colour)}`,
    `VIN: ${normalizeText(info.vin)}`,
    `Engine: ${normalizeText(info.engine)}`
  ].join("\n");
}

function setVehicleInfoFields(info) {
  const values = {
    fleetNo: normalizeText(info.fleetNo),
    make: normalizeText(info.make),
    model: normalizeText(info.model),
    colour: normalizeText(info.colour),
    vin: normalizeText(info.vin),
    engine: normalizeText(info.engine)
  };

  elements.vehicleInfoValue.textContent = values.fleetNo;
  elements.vehicleInfoPanel?.querySelectorAll("[data-vehicle-field]").forEach((node) => {
    const key = node.getAttribute("data-vehicle-field");
    node.textContent = values[key] || "N/A";
  });

  return values;
}

function detailFact(icon, label, value) {
  return `
    <div class="side-fact">
      ${iconSvg(icon)}
      <span>${escapeHtml(label)}</span>
      <strong>${escapeHtml(normalizeText(value))}</strong>
    </div>
  `;
}

function openVehicleInfo() {
  if (!elements.vehicleInfoPanel) return;
  elements.vehicleInfoPanel.hidden = false;
  elements.vehicleInfoToggle?.setAttribute("aria-expanded", "true");
}

function closeVehicleInfo() {
  if (!elements.vehicleInfoPanel) return;
  elements.vehicleInfoPanel.hidden = true;
  elements.vehicleInfoToggle?.setAttribute("aria-expanded", "false");
}

function currentVehicleInfo() {
  return {
    registration: elements.registrationValue?.textContent,
    fleetNo: elements.vehicleInfoPanel?.querySelector('[data-vehicle-field="fleetNo"]')?.textContent,
    make: elements.vehicleInfoPanel?.querySelector('[data-vehicle-field="make"]')?.textContent,
    model: elements.vehicleInfoPanel?.querySelector('[data-vehicle-field="model"]')?.textContent,
    colour: elements.vehicleInfoPanel?.querySelector('[data-vehicle-field="colour"]')?.textContent,
    vin: elements.vehicleInfoPanel?.querySelector('[data-vehicle-field="vin"]')?.textContent,
    engine: elements.vehicleInfoPanel?.querySelector('[data-vehicle-field="engine"]')?.textContent
  };
}

function setVehicleInfoCopied(copied) {
  elements.vehicleInfoCopyIndicator?.classList.toggle("is-copied", copied);
  if (elements.vehicleInfoCopyStatus) {
    elements.vehicleInfoCopyStatus.hidden = !copied;
  }
  if (elements.vehicleInfoCopyIndicator) {
    elements.vehicleInfoCopyIndicator.setAttribute("aria-label", copied ? "Vehicle info copied" : "Copy vehicle info");
    elements.vehicleInfoCopyIndicator.title = copied ? "Vehicle info copied" : "Copy vehicle info";
  }
  window.clearTimeout(setVehicleInfoCopied.resetTimer);
  if (copied) {
    setVehicleInfoCopied.resetTimer = window.setTimeout(() => setVehicleInfoCopied(false), 1800);
  }
}

async function copyVehicleInfo() {
  try {
    await copyText(vehicleInfoTemplate(currentVehicleInfo()));
    setVehicleInfoCopied(true);
  } catch (error) {
    elements.notice.hidden = false;
    elements.notice.textContent = error.message || "Vehicle info could not be copied.";
  }
}

async function requestJson(url) {
  const response = await fetch(url, { headers: { Accept: "application/json" } });
  const text = await response.text();
  if (!text.trim().startsWith("{") && !text.trim().startsWith("[")) {
    throw new Error("The service could not complete the request. Your draft has been preserved.");
  }
  const data = text ? JSON.parse(text) : null;
  if (!response.ok) throw new Error(data?.message || `Request failed with HTTP ${response.status}`);
  return data;
}

async function loadOpenQuickLogCount() {
  const target = elements.quickLogNavCount;
  if (!target) return;
  const request = ++quickLogNavCountRequest;
  try {
    const data = await requestJson(api.openQuickLogsCount);
    if (request !== quickLogNavCountRequest) return;
    if (data?.authorized !== true) {
      target.hidden = true;
      return;
    }
    const count = Number(data.totalOpenCount);
    if (!Number.isInteger(count) || count < 0) throw new Error("Invalid open log count.");
    let newDraftCount = 0;
    try {
      window.QuickLogDrafts.migrate(sessionStorage, localStorage, data.operator);
      newDraftCount = window.QuickLogDrafts.collect(localStorage, data.operator).filter(draft => !draft.caseId).length;
    } catch (_) { /* Browser storage may be unavailable; retain the server count. */ }
    target.textContent = String(count + newDraftCount);
    target.hidden = false;
  } catch (_) { /* Keep the last known count instead of showing a false zero. */ }
}

async function postFormJson(url, formData) {
  const response = await fetch(url, {
    method: "POST",
    body: formData,
    headers: { Accept: "application/json" },
    signal: AbortSignal.timeout(45000)
  });
  const text = await response.text();
  if (!text.trim().startsWith("{") && !text.trim().startsWith("[")) {
    const validationCode = text.match(/\bCC_(?:AUTH|REQUEST_ID|CONTEXT|CASE|SEAT|ROWS|VALIDATION|RECONCILE|STALE|LIMIT|SAVE_COUNT):/);
    if (validationCode) {
      const error = new Error(validationCode[0] === "CC_STALE:" ? "This open log changed after you opened it. Your draft has been kept; review the current log before submitting." : validationCode[0] === "CC_RECONCILE:" ? "This historical or previously pushed log needs an administrator to reconcile it before submitting. Your draft has been kept." : "No entries were saved. Check the case, seat and communication entries, then try again. " + validationCode[0].slice(0, -1));
      error.confirmedNotSaved = true;
      throw error;
    }
    throw new Error("The request could not be confirmed. Your draft has been preserved; retrying will reuse the same request.");
  }
  const data = text ? JSON.parse(text) : null;
  if (!response.ok || data?.success === false) {
    const error = new Error(data?.message || `Request failed with HTTP ${response.status}`);
    error.confirmedNotSaved = data?.success === false && ["invalid_request", "backend_unavailable", "unauthorized"].includes(data.status);
    throw error;
  }
  return data;
}

function showQuickLogMessage(message, type = "info") {
  if (!elements.quickLogMessage) return;
  elements.quickLogMessage.hidden = false;
  elements.quickLogMessage.textContent = message;
  elements.quickLogMessage.dataset.type = type;
}

function clearQuickLogMessage() {
  if (!elements.quickLogMessage) return;
  elements.quickLogMessage.hidden = true;
  elements.quickLogMessage.textContent = "";
  delete elements.quickLogMessage.dataset.type;
}

function confirmedQuickLogMessage(message, log) {
  const ob = String(log?.zohoOb || "").trim();
  return ob ? `${message} Zoho OB: ${ob}` : message;
}

function normalizeQuickLogComment(comment = {}, fallback = {}) {
  return {
    commId: comment.commId ?? comment.comm_id ?? null,
    caseId: comment.caseId ?? comment.case_id ?? fallback.caseId ?? seqno ?? null,
    commType: comment.commType ?? comment.comm_type ?? "",
    contactName: comment.contactName ?? comment.contact_name ?? "",
    contactNo: comment.contactNo ?? comment.contact_no ?? "",
    emailAddress: comment.emailAddress ?? comment.email_address ?? "",
    comments: comment.comments ?? comment.comment ?? "",
    ccOperator: comment.ccOperator ?? comment.cc_operator ?? fallback.ccOperator ?? elements.quickLogOperator?.value ?? "Unknown operator",
    datetimeComm: comment.datetimeComm ?? comment.datetime_comm ?? fallback.datetimeComm ?? localDateTimeValue(),
    zohoPushed: comment.zohoPushed ?? comment.zoho_pushed ?? 0,
    zohoPushedDatetime: comment.zohoPushedDatetime ?? comment.zoho_pushed_datetime ?? ""
  };
}

function quickLogCommentHtml(comment) {
  const statusLabel = Number(comment.zohoPushed) === 1 ? "Zoho pushed" : "Saved · sync not confirmed";
  const statusState = Number(comment.zohoPushed) === 1 ? "pushed" : "pending";
  return `
    <tr>
      <td><span class="quick-log-history-status" data-state="${statusState}">${escapeHtml(statusLabel)}</span></td>
      <td>${escapeHtml(comment.commType || "Communication")}</td>
      <td>${escapeHtml(comment.datetimeComm || "-")}</td>
      <td>${escapeHtml(comment.ccOperator || "Unknown operator")}</td>
      <td>${escapeHtml(comment.contactName || "-")}</td>
      <td>${escapeHtml(comment.contactNo || "-")}</td>
      <td>${escapeHtml(comment.emailAddress || "-")}</td>
      <td class="quick-log-history-note">${escapeHtml(comment.comments || "-")}</td>
    </tr>
  `;
}

function renderQuickLogHistory(comments = []) {
  const initial = state.pageData?.quickLogCase?.initialCommunication;
  const history = comments.length ? comments : quickLogIsClosed() && initial ? [initial] : [];
  const normalized = history.map((comment) => normalizeQuickLogComment(comment));
  if (!elements.quickLogHistory || !elements.quickLogHistoryList || !elements.quickLogHistoryCount) return;
  elements.quickLogHistory.hidden = !quickLogIsClosed() || normalized.length === 0;
  elements.quickLogHistoryCount.textContent = String(normalized.length);
  elements.quickLogHistoryList.innerHTML = normalized.length
    ? `<table class="quick-log-history-table"><thead><tr><th>Status</th><th>Type</th><th>Date and time</th><th>Agent</th><th>Contact</th><th>Number</th><th>Email</th><th>Notes</th></tr></thead><tbody>${normalized.map((comment) => quickLogCommentHtml(comment)).join("")}</tbody></table>`
    : "";
}

function quickLogIsClosed() {
  return completedQuickLogView || state.pageData?.quickLogCase?.closed === true || state.pageData?.quickLogCase?.completed === true;
}

function existingQuickLogRows() {
  const comments = state.pageData?.quickLogComments || [];
  const initial = state.pageData?.quickLogCase?.initialCommunication;
  return (comments.length ? comments : initial ? [initial] : []).map(normalizeQuickLogComment);
}

function showClosedQuickLog() {
  document.querySelector("#quickLogTitle").textContent = "Completed Log";
  for (const selector of [".quick-log-draft-banner", ".quick-log-grid", ".quick-log-editor", ".quick-log-footer"]) document.querySelector(selector).hidden = true;
  renderQuickLogHistory(state.pageData?.quickLogComments || []);
}

function commTypeOptions(selectedValue = "") {
  const options = (state.quickLogOptions?.commTypes || []).filter((option) => {
    const value = String(option?.value ?? "").trim();
    const label = String(option?.label ?? "").trim();
    return value !== "..." && label !== "...";
  });
  return [
    '<option value="">Select comm type</option>',
    ...options.map((option) => {
      const value = option.value || option.label || "";
      const selected = String(value).toLowerCase() === String(selectedValue).toLowerCase() ? " selected" : "";
      return `<option value="${escapeHtml(value)}"${selected}>${escapeHtml(option.label || value)}</option>`;
    })
  ].join("");
}

function callMadeCommType() {
  const options = state.quickLogOptions?.commTypes || [];
  const match = options.find((option) => String(option.label || option.value || "").trim().toLowerCase() === "call made");
  return match?.value || match?.label || "Call Made";
}

function populateQuickLogOptions() {
  const enabled = state.quickLogOptions?.authorized === true && state.quickLogOptions?.submissionEnabled === true;
  if (elements.quickLogSubmit) elements.quickLogSubmit.disabled = !enabled || quickLogSubmitting;
  if (elements.quickLogSubmitNote) elements.quickLogSubmitNote.textContent = enabled
    ? ""
    : state.quickLogOptions?.message || "Submission is temporarily unavailable. You can still save a draft.";
  if (elements.quickLogOperator) {
    elements.quickLogOperator.value = state.quickLogOptions?.operator?.name || "Unknown operator";
  }

  if (elements.quickLogSeat) {
    const seats = (state.quickLogOptions?.seats || []).filter((seat) => {
      const value = String(seat?.value ?? "").trim();
      const label = String(seat?.label ?? "").trim();
      return value !== "..." && label !== "..." && label !== "Select seat...";
    });
    let savedSeat = elements.quickLogSeat.value || "";
    try { savedSeat ||= sessionStorage.getItem(quickLogSeatStorageKey()) || ""; } catch (_) { /* Draft saving reports storage failures. */ }
    elements.quickLogSeat.innerHTML = [
      '<option value="">Select seat...</option>',
      ...seats.map((seat) => `<option value="${escapeHtml(seat.value ?? "")}">${escapeHtml(seat.label)}</option>`)
    ].join("");
    if (savedSeat && seats.some((seat) => String(seat.value ?? "") === savedSeat)) {
      elements.quickLogSeat.value = savedSeat;
    }
  }

  elements.quickLogRows?.querySelectorAll("[data-field='comm_type']").forEach((select) => {
    const selected = select.value;
    select.innerHTML = commTypeOptions(selected);
  });
}

async function ensureQuickLogOptions() {
  if (state.quickLogOptions) return state.quickLogOptions;
  const options = await requestJson(buildUrl(api.quickLogOptions));
  if (options?.authorized !== true) throw new Error("Sign in with an authorized CC operator account.");
  state.quickLogOptions = options || {};
  populateQuickLogOptions();
  return state.quickLogOptions;
}

function quickLogRowTemplate(row) {
  const id = ++quickLogRowCounter;
  const commType = row.commType || "";
  const contactName = row.contactName || "";
  const contactNo = row.contactNo || "";
  const emailAddress = row.emailAddress || "";
  const datetimeComm = String(row.datetimeComm ?? localDateTimeValue()).replace(" ", "T");
  const comments = row.comments || "";

  return `
    <tr class="quick-log-row" data-row-id="${id}"${row.commId == null ? "" : ` data-comm-id="${escapeHtml(row.commId)}"`}>
      <td>
        <div class="quick-log-row-tools">
          <button class="quick-log-drag-handle" type="button" draggable="true" data-drag-row aria-label="Drag to reorder communication" title="Drag to reorder">
            <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="8" cy="7" r="1"></circle><circle cx="16" cy="7" r="1"></circle><circle cx="8" cy="12" r="1"></circle><circle cx="16" cy="12" r="1"></circle><circle cx="8" cy="17" r="1"></circle><circle cx="16" cy="17" r="1"></circle></svg>
          </button>
          <button class="quick-log-remove" type="button" data-remove-row="${id}" aria-label="Remove communication" title="Remove">×</button>
        </div>
      </td>
      <td>
        <div class="quick-log-datetime-control">
          <input aria-label="Date and time" data-field="datetime_comm" type="datetime-local" step="1" value="${escapeHtml(datetimeComm)}" required>
          <button type="button" data-open-datetime-picker aria-label="Open date and time picker" title="Open date and time picker">
            <svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="4" width="18" height="17" rx="2"></rect><path d="M16 2v4M8 2v4M3 10h18"></path></svg>
          </button>
        </div>
      </td>
      <td><select aria-label="Communication type" data-field="comm_type" required>${commTypeOptions(commType)}</select></td>
      <td><input aria-label="Contact person" data-field="contact_name" type="text" maxlength="200" value="${escapeHtml(contactName)}" placeholder="Contact person"></td>
      <td><div class="quick-log-phone-field"><input aria-label="Contact number" aria-describedby="quickLogPhoneError-${id}" data-field="contact_no" type="tel" inputmode="tel" autocomplete="tel" spellcheck="false" value="${escapeHtml(contactNo)}" placeholder="0821234567" title="One local or international phone number"><small class="quick-log-phone-error" id="quickLogPhoneError-${id}" role="status" aria-live="polite" hidden></small></div></td>
      <td><input aria-label="Email address" data-field="email_address" type="email" maxlength="200" value="${escapeHtml(emailAddress)}" placeholder="Email address"></td>
      <td><textarea aria-label="Communication notes" data-field="comments" maxlength="2000" placeholder="Communication notes" required>${escapeHtml(comments)}</textarea></td>
    </tr>
  `;
}

function addQuickLogRow(row = {}, restoring = false) {
  if (!elements.quickLogRows) return;
  if (!restoring && (quickLogSubmitting || quickLogAttemptFingerprint)) return;
  if (!restoring && elements.quickLogRows.querySelectorAll(".quick-log-row").length + quickLogExistingCount() >= QuickLogPolicy.limits.rows) {
    showQuickLogMessage("This case already has 100 communication entries. All existing entries have been kept.", "error");
    return;
  }
  elements.quickLogRows.insertAdjacentHTML("beforeend", quickLogRowTemplate(row));
  const addedRow = elements.quickLogRows.lastElementChild;
  syncQuickLogEntryOrder();
  return addedRow;
}

function clearQuickLogPhoneError(input) {
  if (!input) return;
  input.setCustomValidity("");
  input.removeAttribute("aria-invalid");
  const error = input.closest(".quick-log-phone-field")?.querySelector(".quick-log-phone-error");
  if (error) { error.hidden = true; error.textContent = ""; }
}

function validateQuickLogPhone(input, normalize = false) {
  if (!input) return true;
  const error = input.closest(".quick-log-phone-field")?.querySelector(".quick-log-phone-error");
  try {
    const phone = QuickLogPolicy.normalizePhone(input.value);
    clearQuickLogPhoneError(input);
    if (normalize && phone !== input.value && !quickLogAttemptFingerprint) {
      input.value = phone;
      markQuickLogDraftDirty();
    }
    return true;
  } catch (problem) {
    input.setCustomValidity(problem.message);
    input.setAttribute("aria-invalid", "true");
    if (error) { error.textContent = problem.message; error.hidden = false; }
    return false;
  }
}

function validateQuickLogPhones() {
  const inputs = [...elements.quickLogRows.querySelectorAll("[data-field='contact_no']")];
  let firstInvalid;
  inputs.forEach((input) => {
    if (!validateQuickLogPhone(input) && !firstInvalid) firstInvalid = input;
  });
  if (firstInvalid) {
    firstInvalid.focus();
    return false;
  }
  inputs.forEach((input) => validateQuickLogPhone(input, true));
  return true;
}

function quickLogExistingCount() {
  // Existing open-log entries are already part of the complete editable row set.
  return 0;
}

function syncQuickLogEntryOrder() {
  const rows = [...elements.quickLogRows.querySelectorAll(".quick-log-row")];
  elements.quickLogEntryCount.textContent = String(rows.length);
  rows.forEach((row, index) => {
    const rowNumber = index + 1;
    row.setAttribute("aria-label", `Communication ${rowNumber}`);
    row.querySelector("[data-drag-row]").setAttribute("aria-label", `Drag to reorder communication ${rowNumber}`);
    row.querySelector("[data-remove-row]").setAttribute("aria-label", `Remove communication ${rowNumber}`);
  });
}

function markQuickLogDraftDirty() {
  if (quickLogSubmitting || quickLogAttemptFingerprint) return;
  quickLogSubmissionId = null;
  quickLogDraftDirty = true;
  elements.quickLogDraftStatus.textContent = "Draft · unsaved changes";
  elements.quickLogDraftStatus.dataset.state = "unsaved";
}

function quickLogDraftKey() {
  return `cc-escalation-draft:v1:${JSON.stringify([regNo, eventName, seqno || "new", state.quickLogOptions?.operator?.username || "unknown"])}`;
}

function draftCommunicationRows() {
  return [...elements.quickLogRows.querySelectorAll(".quick-log-row")].map((row) => {
    const value = (field) => row.querySelector(`[data-field='${field}']`).value;
    return { commId: row.dataset?.commId == null ? null : Number(row.dataset.commId), commType: value("comm_type"), datetimeComm: value("datetime_comm"), contactName: value("contact_name"), contactNo: value("contact_no"), emailAddress: value("email_address"), comments: value("comments") };
  });
}

function saveQuickLogDraft() {
  try {
    if (quickLogIsClosed() && !quickLogAttemptFingerprint) throw new Error("Completed logs are read-only.");
    if (!state.quickLogOptions?.operator?.name) throw new Error("Load operator details before saving a draft.");
    if (quickLogDraftRestoreError) throw new Error(quickLogDraftRestoreError);
    if (!validateQuickLogPhones()) throw new Error("Correct the highlighted contact numbers before saving.");
    const draft = { version: 1, editorVersion: 2, company: state.pageData?.vehicle?.company || state.pageData?.quickLogCase?.company || "", caseSnapshot: quickLogBaseSnapshot, submissionId: quickLogSubmissionId, attemptFingerprint: quickLogAttemptFingerprint, savedAt: new Date().toISOString(), seat: elements.quickLogSeat.value, rows: draftCommunicationRows() };
    const key = quickLogDraftKey();
    const raw = JSON.stringify(draft);
    if (quickLogRestoredDraftKey && quickLogRestoredDraftKey !== key && localStorage.getItem(quickLogRestoredDraftKey) !== quickLogDraftSnapshots.get(quickLogRestoredDraftKey)) throw new Error("This draft changed in another tab. Open it from Quick Logs before saving.");
    window.QuickLogDrafts.write(localStorage, key, raw, quickLogDraftSnapshots.get(key) ?? null);
    quickLogDraftSnapshots.set(key, raw);
    quickLogDraftDirty = false;
    elements.quickLogDraftStatus.textContent = `Draft saved · ${new Date(draft.savedAt).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}`;
    elements.quickLogDraftStatus.dataset.state = "saved";
    if (quickLogAttemptFingerprint) showQuickLogMessage("The request and retry key are saved in this browser. Retry these same entries to confirm the result.", "success");
    else clearQuickLogMessage();
    void loadOpenQuickLogCount();
    return true;
  } catch (error) {
    elements.quickLogDraftStatus.dataset.state = "unsaved";
    showQuickLogMessage(`Draft could not be saved. ${error.message}`, "error");
    return false;
  }
}

function restoreQuickLogDraft() {
  try {
    quickLogDraftRestoreError = null;
    const legacyKey = `cc-escalation-draft:v1:${JSON.stringify([regNo, eventName, seqno || "new", state.quickLogOptions?.operator?.name || "unknown"])}`;
    const conflicts = window.QuickLogDrafts.migrate(sessionStorage, localStorage, state.quickLogOptions.operator);
    if (conflicts.includes(quickLogDraftKey()) || conflicts.includes(legacyKey)) throw new Error("This tab has a different older draft. It has been kept; open the shared draft from Quick Logs in another tab.");
    quickLogDraftSnapshots.set(quickLogDraftKey(), localStorage.getItem(quickLogDraftKey()));
    quickLogDraftSnapshots.set(legacyKey, localStorage.getItem(legacyKey));
    const key = localStorage.getItem(quickLogDraftKey()) ? quickLogDraftKey() : legacyKey;
    const raw = localStorage.getItem(key);
    if (!raw) return;
    const draft = JSON.parse(raw);
    if (draft.version !== 1 || !Array.isArray(draft.rows) || !draft.rows.length || draft.rows.some((row) => !row || typeof row !== "object")) throw new Error("The stored draft is not valid.");
    if (draft.attemptFingerprint && draft.editorVersion !== 2) throw new Error("An older submission is awaiting confirmation. This draft has been kept; ask an administrator to reconcile that request before editing.");
    if (draft.editorVersion === 2 && seqno && !draft.attemptFingerprint && draft.caseSnapshot !== quickLogBaseSnapshot) throw new Error("This open log changed after the draft was saved. Your browser draft has been kept; reopen the current log before submitting.");
    elements.quickLogRows.innerHTML = "";
    quickLogRowCounter = 0;
    const rows = draft.editorVersion === 2 ? draft.rows : [...existingQuickLogRows(), ...draft.rows];
    rows.forEach((row) => addQuickLogRow(row, true));
    if (draft.editorVersion === 2) quickLogBaseSnapshot = draft.caseSnapshot || null;
    quickLogRestoredDraftKey = key;
    quickLogSubmissionId = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(draft.submissionId || "") ? draft.submissionId : null;
    quickLogAttemptFingerprint = quickLogSubmissionId && typeof draft.attemptFingerprint === "string" ? draft.attemptFingerprint : null;
    elements.quickLogSeat.value = draft.seat || "";
    elements.quickLogDraftStatus.textContent = "Draft restored";
    elements.quickLogDraftStatus.dataset.state = "saved";
    quickLogDraftDirty = false;
    setQuickLogControls();
    if (quickLogAttemptFingerprint) showQuickLogMessage("A previous submission is awaiting confirmation. Retry these same entries before editing them.");
  } catch (error) {
    quickLogDraftRestoreError = error.message;
    showQuickLogMessage(`Draft could not be restored. ${error.message}`, "error");
  }
}

function resetQuickLogRows(row = {}) {
  quickLogRowCounter = 0;
  if (elements.quickLogRows) elements.quickLogRows.innerHTML = "";
  return addQuickLogRow(row, true);
}

async function openQuickLog(prefill = {}) {
  if (quickLogSubmitting) return;
  clearQuickLogMessage();
  quickLogReturnFocus = document.activeElement;
  elements.quickLogOverlay.hidden = false;
  document.body.classList.add("quick-log-open");

  if (elements.quickLogContext) {
    elements.quickLogContext.textContent = `${normalizeText(regNo)} - ${normalizeText(eventName)}`;
  }

  if (completedQuickLogView) {
    document.querySelector("#quickLogTitle").textContent = "Completed Log";
    document.querySelector(".quick-log-history-head p").textContent = "";
    for (const selector of [".quick-log-draft-banner", ".quick-log-grid", ".quick-log-editor", ".quick-log-footer"]) document.querySelector(selector).hidden = true;
    try {
      const data = await requestJson("/internaltickets/api_completed_quick_logs.sql?" + new URLSearchParams({case_id:seqno}));
      const log = data.authorized === true && data.logs?.find(log => String(log.caseId) === seqno && String(log.regNo).trim().toLowerCase() === regNo.trim().toLowerCase() && log.eventName === eventName);
      if (!log) throw new Error("This completed log could not be found for your operator account.");
      renderQuickLogHistory(log.communicationLog || []);
      showQuickLogMessage(log.syncState === "Complete" ? confirmedQuickLogMessage("Log completed · confirmed in Zoho.", log) : "Log submitted · Zoho confirmation: " + (log.syncState || "Unconfirmed"), log.syncState === "Complete" ? "success" : "info");
    } catch (error) { showQuickLogMessage(error.message, "error"); }
    return;
  }

  try {
    await ensureQuickLogOptions();
  } catch (error) {
    showQuickLogMessage(error.message || "Could not load log options.", "error");
  }

  renderQuickLogHistory(state.pageData?.quickLogComments || []);
  if (!quickLogDraftLoaded) {
    quickLogBaseSnapshot = state.pageData?.quickLogCase?.snapshot || null;
    const existingRows = existingQuickLogRows();
    if (existingRows.length) {
      elements.quickLogRows.innerHTML = "";
      quickLogRowCounter = 0;
      existingRows.forEach((row) => addQuickLogRow(row, true));
      const savedSeat = state.pageData?.quickLogCase?.seat;
      const seat = state.quickLogOptions?.seats?.find((option) => String(option.label) === String(savedSeat));
      if (seat) elements.quickLogSeat.value = String(seat.value);
    } else resetQuickLogRows();
    if (state.quickLogOptions?.operator?.name) {
      restoreQuickLogDraft();
      quickLogDraftLoaded = true;
    }
  }
  if (quickLogIsClosed() && !quickLogAttemptFingerprint) {
    showClosedQuickLog();
    quickLogStatusAttempts = 0;
    void loadOpenQuickLogCount();
    await refreshQuickLogStatus();
    return;
  }
  let commentsInput = elements.quickLogRows?.querySelector("[data-field='comments']");
  if (prefill.contactNo && !quickLogAttemptFingerprint) {
    const rows = draftCommunicationRows();
    const contact = { contactName: prefill.contactName || "", contactNo: prefill.contactNo, commType: callMadeCommType(), datetimeComm: localDateTimeValue() };
    const addedRow = rows.length === 1 && !rows[0].commType && !rows[0].comments && !rows[0].contactName && !rows[0].contactNo && !rows[0].emailAddress
      ? resetQuickLogRows(contact)
      : addQuickLogRow(contact);
    commentsInput = addedRow?.querySelector("[data-field='comments']");
    if (addedRow) markQuickLogDraftDirty();
  }

  commentsInput?.focus();
  // Open logs remain editable drafts; Zoho status is polled only after submission.
}

function closeQuickLog() {
  if (quickLogSubmitting) return;
  finishQuickLogDrag();
  elements.quickLogOverlay.hidden = true;
  document.body.classList.remove("quick-log-open");
  quickLogReturnFocus?.focus();
}

function reorderQuickLogAtPoint(point) {
  const rows = [...elements.quickLogRows.querySelectorAll(".quick-log-row")].filter((row) => row !== draggedQuickLogRow);
  const nextRow = rows.find((row) => {
    const bounds = row.getBoundingClientRect();
    return point.y < bounds.top + bounds.height / 2;
  });
  if (nextRow) {
    if (draggedQuickLogRow.nextElementSibling !== nextRow) nextRow.before(draggedQuickLogRow);
  } else if (rows.length && rows[rows.length - 1].nextElementSibling !== draggedQuickLogRow) {
    rows[rows.length - 1].after(draggedQuickLogRow);
  }
}

function scrollQuickLogDrag(time) {
  quickLogDragFrame = null;
  if (!draggedQuickLogRow || !quickLogDragPoint || elements.quickLogOverlay.hidden) return;
  const table = elements.quickLogRows.closest(".quick-log-table-wrap");
  const bounds = table.getBoundingClientRect();
  const formBounds = elements.quickLogForm.getBoundingClientRect();
  const top = Math.max(bounds.top, formBounds.top, 0);
  const bottom = Math.min(bounds.bottom, formBounds.bottom, window.innerHeight);
  const point = quickLogDragPoint;
  const elapsed = quickLogDragTime === null ? 16 : Math.min(32, time - quickLogDragTime);
  quickLogDragTime = time;
  // Keep scrolling while the pointer is held still at a visible table edge.
  if (point.x >= bounds.left && point.x <= bounds.right && point.y >= top - 24 && point.y <= bottom + 24 && bottom > top) {
    const edge = Math.min(48, (bottom - top) / 3);
    const speed = point.y < top + edge ? -Math.min(1, (top + edge - point.y) / edge)
      : point.y > bottom - edge ? Math.min(1, (point.y - bottom + edge) / edge) : 0;
    const previous = table.scrollTop;
    table.scrollTop += speed * 600 * elapsed / 1000;
    // On short screens the form can clip the table; reveal its remaining rows too.
    if (speed && table.scrollTop === previous && (speed > 0 ? bounds.bottom > bottom : bounds.top < top)) {
      elements.quickLogForm.scrollTop += speed * 600 * elapsed / 1000;
    }
    reorderQuickLogAtPoint(point);
  }
  quickLogDragFrame = window.requestAnimationFrame(scrollQuickLogDrag);
}

function finishQuickLogDrag() {
  if (quickLogDragFrame !== null) window.cancelAnimationFrame(quickLogDragFrame);
  quickLogDragFrame = null;
  quickLogDragPoint = null;
  quickLogDragTime = null;
  if (!draggedQuickLogRow) return;
  draggedQuickLogRow.classList.remove("is-dragging");
  draggedQuickLogRow.closest(".quick-log-table-wrap")?.classList.remove("is-reordering");
  draggedQuickLogRow = null;
  syncQuickLogEntryOrder();
  markQuickLogDraftDirty();
}

function collectQuickLogRows() {
  return [...elements.quickLogRows.querySelectorAll(".quick-log-row")].map((row) => ({
    comm_id: row.dataset?.commId == null ? null : Number(row.dataset.commId),
    comm_type: row.querySelector("[data-field='comm_type']")?.value || "",
    contact_name: row.querySelector("[data-field='contact_name']")?.value || "",
    contact_no: row.querySelector("[data-field='contact_no']")?.value || "",
    email_address: row.querySelector("[data-field='email_address']")?.value || "",
    datetime_comm: sqlDateTimeValue(row.querySelector("[data-field='datetime_comm']")?.value || ""),
    comments: row.querySelector("[data-field='comments']")?.value || ""
  })).filter((row) => !valueIsBlank(row.comm_type) || !valueIsBlank(row.contact_name) || !valueIsBlank(row.contact_no) || !valueIsBlank(row.email_address) || !valueIsBlank(row.comments));
}

function updateCaseId(newCaseId) {
  if (valueIsBlank(newCaseId)) return;
  seqno = String(newCaseId);
  const url = new URL(window.location.href);
  url.searchParams.set("seqno", seqno);
  window.history.replaceState({}, "", url.toString());
}

async function submitQuickLog(event) {
  event.preventDefault();
  if (quickLogIsClosed() && !quickLogAttemptFingerprint) return;
  if (quickLogSubmitting) return;
  const previousAttempt = quickLogAttemptFingerprint;
  quickLogSubmitting = true;
  let sent = false;
  try {
    await ensureQuickLogOptions();
    if (state.quickLogOptions?.submissionEnabled !== true) throw new Error("Submission is temporarily unavailable. Save your draft.");
    if (!validateQuickLogPhones()) throw new Error("Correct the highlighted contact numbers before closing and submitting.");
    if (!elements.quickLogForm.reportValidity()) return;
    const rows = QuickLogPolicy.validateRows(collectQuickLogRows(), quickLogAttemptFingerprint ? 0 : quickLogExistingCount());
    if (!elements.quickLogSeat.value) throw new Error("Select a seat.");
    if (!regNo || !eventName) throw new Error("Open the case with a registration and event before submitting.");
    if (seqno && !quickLogBaseSnapshot) throw new Error("Reload this open log before submitting so its original communications can be checked.");
    const fingerprint = JSON.stringify([seqno, regNo, eventName, elements.quickLogSeat.value, quickLogBaseSnapshot, rows]);
    if (quickLogAttemptFingerprint && quickLogAttemptFingerprint !== fingerprint) throw new Error("Retry the original entries first so the previous submission can be confirmed.");
    quickLogSubmissionId ||= crypto.randomUUID();
    // Persist the retry key before sending; do not rotate it for an unchanged retry.
    const oldDraftKey = quickLogDraftKey();
    quickLogAttemptFingerprint = fingerprint;
    if (!saveQuickLogDraft()) throw new Error("Enable browser storage before submitting so this request can be retried safely. No request was sent.");
    setQuickLogControls();
    const body = new FormData();
    body.set("submission_id", quickLogSubmissionId);
    body.set("csrf_token", state.quickLogOptions.csrfToken || "");
    body.set("case_id", seqno);
    body.set("reg_no", regNo);
    body.set("event", eventName);
    body.set("seat", elements.quickLogSeat.value);
    body.set("comments_json", JSON.stringify(rows));
    body.set("case_snapshot", quickLogBaseSnapshot || "");
    sent = true;
    const saved = await postFormJson(api.quickLogSubmit, body);
    if (saved?.success !== true || !Number.isInteger(saved.caseId) || saved.insertedComments !== rows.length || saved.submissionId?.toLowerCase() !== quickLogSubmissionId.toLowerCase()) {
      throw new Error("The service returned an unexpected confirmation. Keep this draft and retry the same request.");
    }
    try {
      window.QuickLogDrafts.removeIfUnchanged(localStorage, oldDraftKey, quickLogDraftSnapshots.get(oldDraftKey) ?? null);
      if (quickLogRestoredDraftKey) window.QuickLogDrafts.removeIfUnchanged(localStorage, quickLogRestoredDraftKey, quickLogDraftSnapshots.get(quickLogRestoredDraftKey) ?? null);
    } catch (_) { /* The stable request ID makes a stale draft safe to retry. */ }
    updateCaseId(saved.caseId);
    quickLogSubmissionId = null;
    quickLogAttemptFingerprint = null;
    quickLogRestoredDraftKey = null;
    quickLogDraftSnapshots.clear();
    quickLogDraftDirty = false;
    state.pageData ||= {};
    state.pageData.quickLogCase = { ...(state.pageData.quickLogCase || {}), closed: true };
    showClosedQuickLog();
    elements.quickLogDraftStatus.textContent = "All entries saved · case closed";
    elements.quickLogDraftStatus.dataset.state = "saved";
    showQuickLogMessage(saved.message, "success");
    quickLogStatusAttempts = 0;
    await refreshQuickLogStatus();
  } catch (error) {
    if ((!sent && !previousAttempt) || error.confirmedNotSaved) {
      quickLogAttemptFingerprint = null;
      quickLogSubmissionId = null;
      quickLogDraftDirty = true;
      if (sent) saveQuickLogDraft();
    }
    showQuickLogMessage(error.message || "The request could not be confirmed. Your draft has been preserved.", "error");
  } finally {
    quickLogSubmitting = false;
    populateQuickLogOptions();
    setQuickLogControls();
  }
}

function setQuickLogControls() {
  elements.quickLogForm?.querySelectorAll("input,select,textarea,button").forEach((control) => {
    control.disabled = quickLogSubmitting || Boolean(quickLogAttemptFingerprint) || quickLogIsClosed();
  });
  if (elements.quickLogOperator) elements.quickLogOperator.readOnly = true;
  if (elements.quickLogSubmit) {
    elements.quickLogSubmit.disabled = quickLogSubmitting || (quickLogIsClosed() && !quickLogAttemptFingerprint) || state.quickLogOptions?.submissionEnabled !== true;
    elements.quickLogSubmit.textContent = quickLogAttemptFingerprint ? "Confirm previous submission" : "Submit and close case";
  }
}

async function refreshQuickLogStatus() {
  clearTimeout(quickLogStatusTimer);
  if (!seqno) return;
  try {
    const status = await requestJson(buildUrl(api.quickLogStatus));
    if (status?.authorized === false) throw new Error("Sign in again to view Zoho confirmation.");
    if (status.status === "not_found") throw new Error("This case could not be found for the selected registration and event.");
    if (status.quickLogComments) {
      state.pageData ||= {};
      state.pageData.quickLogComments = status.quickLogComments;
      renderQuickLogHistory(status.quickLogComments);
    }
    if (status.syncState === "Unavailable") {
      showQuickLogMessage(status.syncMessage || "Zoho confirmation is not available for this workflow yet.");
    } else if (status.syncState === "Complete") {
      showQuickLogMessage(confirmedQuickLogMessage("All saved communication entries are confirmed in Zoho.", status), "success");
      quickLogStatusAttempts = 0;
    } else if (status.syncState === "Unconfirmed") {
      showQuickLogMessage(status.syncMessage || "This completed legacy log has no stored Zoho confirmation. Contact a CC administrator to verify it.");
      quickLogStatusAttempts = 0;
    } else if (["Failed", "Uncertain"].includes(status.syncState)) {
      showQuickLogMessage("The entries are saved, but Zoho needs attention. " + (status.syncMessage || "Contact a CC administrator."), "error");
    } else {
      quickLogStatusAttempts++;
      if (quickLogStatusAttempts < 20) quickLogStatusTimer = setTimeout(refreshQuickLogStatus, 15000);
      else showQuickLogMessage("All entries remain saved. Zoho confirmation is taking longer than expected; reopen this case to check it.");
    }
  } catch (error) {
    showQuickLogMessage("Could not refresh Zoho confirmation. " + error.message, "error");
  }
}

function render(data) {
  state.pageData = data;
  const vehicle = data.vehicle || {};
  const vehicleInfo = data.vehicleInfo || {};
  const contacts = escalationContacts(data);
  const escalation = contacts.record;
  const zoho = data.zoho || {};
  const dispatch = data.dispatch || {};
  const customerId = data.customerId || vehicle.customerId || "";

  elements.title.textContent = zoho.accountName || vehicle.company || regNo || "Escalation";
  elements.registrationValue.textContent = normalizeText(vehicle.regNo || regNo);
  elements.fleetDescriptionValue.textContent = normalizeText(vehicle.vehicleDescription);
  elements.eventNoteLabel.innerHTML = eventName
    ? `<span class="event-meta"><span class="event-pill">${escapeHtml(eventName)}</span>${!valueIsBlank(dispatch.team) ? `<span class="dispatch-pill">Dispatch Team: ${escapeHtml(dispatch.team)}</span>` : ""}</span>`
    : "Notes for specific alert types.";

  if (zoho.zohoId) {
    elements.openZoho.hidden = false;
    elements.openZoho.href = `https://example.invalid/configure-endpoint`;
  }

  if (customerId) {
    elements.openInfodash.hidden = false;
    elements.openInfodash.href = `https://example.invalid/configure-endpoint`;
  }

  const vehicleValues = setVehicleInfoFields(vehicleInfo);
  closeVehicleInfo();

  elements.summaryFacts.innerHTML = [
    detailFact("truck", "Fleet", vehicleValues.fleetNo),
    detailFact("lock", "Verification Password", escalation.verification_password),
    detailFact("person", "Authorised Person", escalation.auth_person)
  ].join("");

  elements.eventNote.innerHTML = valueIsBlank(escalation.event_note)
    ? emptyState("No event-specific notes captured.")
    : `<div class="note-card">${linkifyText(escalation.event_note)}</div>`;
  elements.eventNoteCount.textContent = valueIsBlank(escalation.event_note) ? "0" : "1";

  const authNotes = [
    !valueIsBlank(escalation.auth_notes) ? `<article class="note-card"><strong>Auth Notes</strong><br>${linkifyText(escalation.auth_notes)}</article>` : "",
    !valueIsBlank(escalation.group_notes) ? `<article class="note-card"><strong>Group Notes</strong><br>${linkifyText(escalation.group_notes)}</article>` : "",
    !valueIsBlank(escalation.gen_note) ? `<article class="note-card"><strong>General Note</strong><br>${linkifyText(escalation.gen_note)}</article>` : ""
  ].filter(Boolean).join("");

  if (authNotes) {
    elements.authSection.hidden = false;
    elements.authNotes.innerHTML = authNotes;
  } else {
    elements.authSection.hidden = true;
  }

  elements.contactSections.innerHTML = [
    clientInstructions(contacts.profile),
    contactSection("Day Contacts", contacts.profile ? "Office hours: Monday–Friday, 06:00–19:00." : "Contactsss during normal working hours.", contacts.day),
    contactSection("Night Contacts", "After-hours escalation contacts.", contacts.night),
    contactSection("Weekend Contacts", "Weekend and public holiday contacts.", contacts.weekend)
  ].join("");
}

async function init() {
  void loadOpenQuickLogCount();
  window.addEventListener("focus", () => { void loadOpenQuickLogCount(); });
  window.addEventListener("storage", event => {
    if (event.storageArea === localStorage && (event.key === null || event.key.startsWith(window.QuickLogDrafts.prefix))) {
      void loadOpenQuickLogCount();
    }
  });
  syncTheme();

  elements.vehicleInfoToggle?.addEventListener("click", () => {
    const isOpen = elements.vehicleInfoPanel && !elements.vehicleInfoPanel.hidden;
    if (isOpen) closeVehicleInfo();
    else openVehicleInfo();
  });

  elements.vehicleInfoDismiss?.addEventListener("click", () => closeVehicleInfo());
  elements.vehicleInfoCopy?.addEventListener("click", copyVehicleInfo);
  elements.vehicleInfoCopyIndicator?.addEventListener("click", async (event) => {
    event.stopPropagation();
    await copyVehicleInfo();
  });

elements.openQuickLog?.addEventListener("click", () => openQuickLog());
elements.quickLogSeat?.addEventListener("change", () => {
  try {
  if (valueIsBlank(elements.quickLogSeat?.value)) {
    sessionStorage.removeItem(quickLogSeatStorageKey());
    return;
  }
  sessionStorage.setItem(quickLogSeatStorageKey(), String(elements.quickLogSeat.value));
  } catch (_) { showQuickLogMessage("Browser storage is unavailable. Enable storage before submitting so your draft can be preserved.", "error"); }
});
elements.quickLogDismiss?.addEventListener("click", closeQuickLog);
  elements.quickLogAddRow?.addEventListener("click", () => {
    if (quickLogSubmitting || quickLogAttemptFingerprint) return;
    addQuickLogRow({ datetimeComm: localDateTimeValue() });
    markQuickLogDraftDirty();
    elements.quickLogRows.lastElementChild?.querySelector("select")?.focus();
  });
  elements.quickLogSaveDraft?.addEventListener("click", saveQuickLogDraft);
  elements.quickLogForm?.addEventListener("input", markQuickLogDraftDirty);
  elements.quickLogForm?.addEventListener("change", markQuickLogDraftDirty);
  elements.quickLogRows?.addEventListener("input", (event) => {
    if (event.target.matches("[data-field='contact_no']")) clearQuickLogPhoneError(event.target);
  });
  elements.quickLogForm?.addEventListener("submit", submitQuickLog);
  elements.quickLogRows?.addEventListener("click", (event) => {
    if (quickLogSubmitting || quickLogAttemptFingerprint) return;
    const pickerButton = event.target.closest("[data-open-datetime-picker]");
    if (pickerButton) {
      const input = pickerButton.closest(".quick-log-datetime-control")?.querySelector("input[type='datetime-local']");
      input?.focus();
      if (typeof input?.showPicker === "function") input.showPicker();
      return;
    }
    const removeButton = event.target.closest("[data-remove-row]");
    if (!removeButton) return;
    const row = removeButton.closest(".quick-log-row");
    markQuickLogDraftDirty();
    if (elements.quickLogRows.querySelectorAll(".quick-log-row").length === 1) {
      row.querySelectorAll("input, textarea").forEach((input) => {
        if (input.type !== "datetime-local") input.value = "";
      });
      row.querySelector("[data-field='comm_type']").value = "";
      row.querySelector("[data-field='datetime_comm']").value = localDateTimeValue();
      clearQuickLogPhoneError(row.querySelector("[data-field='contact_no']"));
      return;
    }
    row.remove();
    syncQuickLogEntryOrder();
  });

  elements.quickLogRows?.addEventListener("dragstart", (event) => {
    if (quickLogSubmitting || quickLogAttemptFingerprint) { event.preventDefault(); return; }
    const handle = event.target.closest("[data-drag-row]");
    if (!handle) {
      event.preventDefault();
      return;
    }
    draggedQuickLogRow = handle.closest(".quick-log-row");
    draggedQuickLogRow.classList.add("is-dragging");
    draggedQuickLogRow.closest(".quick-log-table-wrap").classList.add("is-reordering");
    event.dataTransfer.effectAllowed = "move";
    event.dataTransfer.setData("text/plain", draggedQuickLogRow.dataset.rowId || "communication");
  });

  document.addEventListener("dragover", (event) => {
    if (!draggedQuickLogRow) return;
    quickLogDragPoint = { x: event.clientX, y: event.clientY };
    if (event.target.closest(".quick-log-table-wrap")) {
      event.preventDefault();
      event.dataTransfer.dropEffect = "move";
      reorderQuickLogAtPoint(quickLogDragPoint);
    }
    if (quickLogDragFrame === null) quickLogDragFrame = window.requestAnimationFrame(scrollQuickLogDrag);
  });

  elements.quickLogRows?.addEventListener("drop", (event) => {
    if (!draggedQuickLogRow) return;
    event.preventDefault();
    finishQuickLogDrag();
  });

  document.addEventListener("drop", finishQuickLogDrag);
  document.addEventListener("dragend", finishQuickLogDrag);
  document.addEventListener("dragleave", (event) => {
    if (event.target === document.documentElement && event.relatedTarget === null) quickLogDragPoint = null;
  });
  window.addEventListener("blur", finishQuickLogDrag);

  window.addEventListener("beforeunload", (event) => {
    if (!quickLogDraftDirty && !quickLogSubmitting && !quickLogAttemptFingerprint) return;
    event.preventDefault();
    event.returnValue = "";
  });

  elements.contactSections?.addEventListener("click", (event) => {
    const phoneButton = event.target.closest(".contact-phone-button");
    if (!phoneButton) return;
    openQuickLog({
      contactName: phoneButton.dataset.contact || "",
      contactNo: phoneButton.dataset.phone || ""
    });
  });

  elements.quickLogOverlay?.addEventListener("click", (event) => {
    if (event.target === elements.quickLogOverlay) closeQuickLog();
  });

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && elements.quickLogOverlay && !elements.quickLogOverlay.hidden) {
      closeQuickLog();
    }
  });

  document.addEventListener("click", (event) => {
    if (!elements.vehicleInfoPanel || elements.vehicleInfoPanel.hidden) return;
    const target = event.target;
    if (elements.vehicleInfoPanel.contains(target) || elements.vehicleInfoToggle?.contains(target)) return;
    closeVehicleInfo();
  });

  try {
    const data = await requestJson(buildUrl(api.detail));
    render(data || {});
    if (!completedQuickLogView && data?.status !== "unauthorized") {
      try {
        await ensureQuickLogOptions();
        window.QuickLogDrafts.migrate(sessionStorage, localStorage, state.quickLogOptions.operator);
      } catch (error) { showQuickLogMessage(error.message || "Drafts could not be shared across tabs.", "error"); }
    }
    if (params.get("quick_log") === "1" && data?.status !== "unauthorized") await openQuickLog();
  } catch (error) {
    elements.notice.hidden = false;
    elements.notice.textContent = error.message;
  }
}

init();
