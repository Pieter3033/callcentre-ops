SET cc_encoded_registration = sqlpage.url_encode($reg_no);
SET cc_encoded_event = sqlpage.url_encode($event);
SET cc_encoded_case = sqlpage.url_encode($seqno);
SET cc_signin_destination = (SELECT N'/CC_Escalation/main.sql?reg_no=' + COALESCE($cc_encoded_registration,N'')
 + N'&event=' + COALESCE($cc_encoded_event,N'')
 + CASE WHEN NULLIF($seqno,N'') IS NULL THEN N'' ELSE N'&seqno=' + $cc_encoded_case END
 + CASE WHEN $quick_log=N'1' THEN N'&quick_log=1' ELSE N'' END
 + CASE WHEN $completed=N'1' THEN N'&completed=1' ELSE N'' END);
SELECT 'redirect' AS component,N'/signin.sql?returnTo=' + sqlpage.url_encode($cc_signin_destination) AS link
WHERE NOT EXISTS(SELECT 1 FROM ApplicationDb3.dbo.Current_session s JOIN ApplicationDb3.dbo.User_info u ON LOWER(LTRIM(RTRIM(u.Username)))=LOWER(LTRIM(RTRIM(s.Username))) WHERE s.session_id=sqlpage.cookie('session') AND TRY_CONVERT(int,u.Usertype) IN(7,8,14));
SELECT 'shell-empty' AS component;

SELECT 'html' AS component,
N'<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>CC Escalation</title>
    <link rel="icon" href="favicon.png">
    <link rel="stylesheet" href="cc_escalation.css?v=20261006-ready-v4">
    <link rel="stylesheet" href="/internaltickets/styles.css?v=20260908-ui-scale-80-v1">
    <link rel="stylesheet" href="cc_app_ui.css?v=20261006-app-v5">
    <script src="cc_app_ui.js?v=20261006-app-v2" defer></script>
    <script src="quick_log_policy.js?v=20261006-ready-v3" defer></script>
    <script src="/internaltickets/quick-log-drafts.js?v=20261007-open-v3" defer></script>
    <script src="cc_escalation.js?v=20261007-ready-v17" defer></script>
  </head>
  <body class="escalation-page">
    <div class="escalation-view">
      <aside class="escalation-sidebar app-sidebar sidebar">
        <div class="sidebar-mobile-bar">
          <div class="sidebar-brand">
            <img class="sidebar-logo" src="/SRF/newui/logowhite_3.png" alt="Application Electronics">
          </div>
          <button class="sidebar-collapse-button" id="ccSidebarToggle" type="button" aria-label="Collapse sidebar" title="Collapse sidebar" aria-expanded="true">
            <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 7h16M4 12h16M4 17h16"></path></svg>
          </button>
        </div>
        <nav class="sidebar-nav cc-sidebar-nav" aria-label="Escalations">
          <div class="nav-section-title"><span class="nav-section-label"><svg class="sidebar-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3v18M5 8h14M7 16h10"></path></svg><span>Escalations</span></span></div>
          <a class="nav-sublink" href="/internaltickets/escalations.html" title="Escalation View"><svg class="sidebar-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M4 5h16v14H4zM8 9h8M8 13h8"></path></svg><span>Escalation View</span></a>
          <a class="nav-sublink" id="ccOpenLogsNav" href="/internaltickets/quick_logs.html" title="Quick Log"><svg class="sidebar-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M21 15a4 4 0 0 1-4 4H8l-5 3V7a4 4 0 0 1 4-4h10a4 4 0 0 1 4 4Z"></path></svg><span class="nav-label"><span>Quick Log</span><strong class="nav-count" id="ccOpenLogsCount" data-nav-count="quicklog" hidden></strong></span></a>
          <a class="nav-sublink" id="ccCompletedLogsNav" href="/internaltickets/completed_quick_logs.html" title="Completed Logs"><svg class="sidebar-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="m9 12 2 2 4-4"></path><rect x="4" y="3" width="16" height="18" rx="2"></rect></svg><span>Completed Logs</span></a>
        </nav>
        <div class="cc-case-context">
        <span class="cc-case-label">Case details</span>
        <h1 id="pageTitle">Loading...</h1>
        <div class="identity-facts" aria-label="Vehicle identity">
          <div class="side-fact">
            <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 6h18v12H3z"></path><path d="M7 10h3"></path><path d="M14 10h3"></path><path d="M7 14h10"></path></svg>
            <span>Registration</span>
            <strong id="registrationValue">Loading...</strong>
          </div>
          <div class="side-fact">
            <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 7h16v10H4z"></path><path d="M7 11h10"></path><path d="M7 14h6"></path></svg>
            <span>Fleet Description</span>
            <strong id="fleetDescriptionValue">Loading...</strong>
          </div>
        </div>
        <div class="side-facts" id="summaryGrid" aria-label="Escalation summary">
          <div class="vehicle-info-wrap">
            <button class="side-fact side-fact-action vehicle-info-toggle" id="vehicleInfoToggle" type="button" aria-expanded="false" aria-controls="vehicleInfoPanel">
              <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 8h11v8H4z"></path><path d="M15 11h3l2 2v3h-5z"></path><circle cx="7" cy="18" r="2"></circle><circle cx="17" cy="18" r="2"></circle></svg>
              <span>Vehicle info</span>
              <strong id="vehicleInfoValue">Loading...</strong>
            </button>
            <button class="vehicle-info-copy-indicator" id="vehicleInfoCopyIndicator" type="button" aria-label="Copy vehicle info" title="Copy vehicle info">
              <svg class="copy-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M8 8h10v10H8z"></path><path d="M6 16H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
              <svg class="check-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M20 6 9 17l-5-5"></path></svg>
            </button>
            <span class="vehicle-info-copy-status" id="vehicleInfoCopyStatus" hidden>Copied</span>
            <div class="vehicle-info-panel" id="vehicleInfoPanel" hidden>
              <div class="vehicle-info-panel-head">
                <strong>Vehicle info</strong>
                <button class="vehicle-info-dismiss" id="vehicleInfoDismiss" type="button" aria-label="Dismiss vehicle info">×</button>
              </div>
              <div class="vehicle-info-panel-body" id="vehicleInfoBody">
                <div class="vehicle-info-line"><span>Fleet</span><strong data-vehicle-field="fleetNo">N/A</strong></div>
                <div class="vehicle-info-line"><span>Make</span><strong data-vehicle-field="make">N/A</strong></div>
                <div class="vehicle-info-line"><span>Model</span><strong data-vehicle-field="model">N/A</strong></div>
                <div class="vehicle-info-line"><span>Colour</span><strong data-vehicle-field="colour">N/A</strong></div>
                <div class="vehicle-info-line"><span>VIN</span><strong data-vehicle-field="vin">N/A</strong></div>
                <div class="vehicle-info-line"><span>Engine</span><strong data-vehicle-field="engine">N/A</strong></div>
              </div>
              <button class="vehicle-info-copy" id="vehicleInfoCopy" type="button">Copy vehicle info</button>
            </div>
          </div>
          <div class="side-facts-stack" id="summaryFacts" aria-label="Escalation details">
            <div class="side-fact"><span>Loading</span><strong>Please wait...</strong></div>
          </div>
        </div>
        <div class="external-actions">
          <button class="external-button quick-log-button" id="openQuickLogButton" type="button">
            <span class="external-button-logo quick-log-button-icon" aria-hidden="true">
              <svg viewBox="0 0 24 24"><path d="M12 5v14"></path><path d="M5 12h14"></path></svg>
            </span>
            <span>Quick Log</span>
          </button>
          <a class="external-button" id="openZohoLink" href="#" target="_blank" rel="noopener noreferrer" hidden>
            <img class="external-button-logo" src="https://example.invalid/configure-endpoint" alt="" aria-hidden="true">
            <span>Open Zoho</span>
          </a>
          <a class="external-button external-button-secondary" id="openInfodashLink" href="#" target="_blank" rel="noopener noreferrer" hidden>
            <span class="external-button-logo external-button-logo--infodash" aria-hidden="true">
              <svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect></svg>
            </span>
            <span>Open Infodash</span>
          </a>
        </div>
        </div>
        <div class="cc-sidebar-footer">
          <div class="sidebar-toggle-row">
            <span class="sidebar-toggle-label">Theme</span>
            <label class="theme-switch" aria-label="Switch color theme">
              <input class="theme-switch__checkbox" id="ccThemeToggle" type="checkbox" role="switch" aria-label="Switch to light mode">
              <span class="theme-switch__container" aria-hidden="true"><span class="theme-switch__clouds"></span><span class="theme-switch__stars-container"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 144 55" fill="none"><path fill="currentColor" fill-rule="evenodd" clip-rule="evenodd" d="M135.8 3c-.8.9-1.7 1.3-2.8 1.4 1.1.1 2 .5 2.8 DATABASE_SERVER 1.2 1.8 1.2 2.9 0-.8.2-1.5.5-2.1.4-.7.9-1.2 1.5-1.6.6-.4 1.3-.6 2-.6-1.1-.1-2-.5-2.8-1.4-.8-.8-1.2-1.8-1.2-3 0 1.2-.4 2.2-1.2 3Z"/></svg></span><span class="theme-switch__circle-container"><span class="theme-switch__sun-moon-container"><span class="theme-switch__moon"><span class="theme-switch__spot"></span><span class="theme-switch__spot"></span><span class="theme-switch__spot"></span></span></span></span></span>
            </label>
          </div>
          <strong>Make it happen - perfectly!</strong>
        </div>
      </aside>

      <main class="escalation-main">
        <header class="cc-page-header"><h2>Escalation List</h2><div class="cc-header-actions"><a class="cc-back-link" href="/internaltickets/quick_logs.html">Quick Logs <span aria-hidden="true">↗</span></a><button class="filter-button compact" id="ccHeaderQuickLog" type="button">Quick Log</button></div></header>

        <div class="panel error" id="notice" hidden></div>

        <section class="detail-section" id="authSection">
          <div class="section-header">
            <span class="section-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M8 3h5l4 4v14H8a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z"></path><path d="M13 3v5h5"></path><path d="M9 13h6"></path><path d="M9 17h4"></path></svg></span>
            <span class="section-title">
              <strong>Authorization Notes</strong>
              <small>Important context before contacting the escalation list.</small>
            </span>
          </div>
          <div class="section-body" id="authNotes">Loading authorization notes...</div>
        </section>

        <section class="detail-section">
          <div class="section-header">
            <span class="section-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="m12 4 9 16H3L12 4Z"></path><path d="M12 9v4"></path><path d="M12 17h.01"></path></svg></span>
            <span class="section-title">
              <strong>Event Notes</strong>
              <small id="eventNoteLabel">Notes for specific alert types.</small>
            </span>
            <span class="section-count" id="eventNoteCount">0</span>
          </div>
          <div class="section-body" id="eventNote">Loading event notes...</div>
        </section>

        <div class="section-stack" id="contactSections"></div>
      </main>
    </div>

    <div class="quick-log-overlay" id="quickLogOverlay" hidden>
      <section class="quick-log-modal" role="dialog" aria-modal="true" aria-labelledby="quickLogTitle">
        <div class="quick-log-head">
          <div>
            <span class="quick-log-eyebrow">Communication log</span>
            <h3 id="quickLogTitle">Quick Log</h3>
            <p id="quickLogContext">Add one or more communication entries for this case.</p>
          </div>
          <button class="quick-log-dismiss" id="quickLogDismiss" type="button" aria-label="Dismiss quick log">&times;</button>
        </div>

        <form class="quick-log-form" id="quickLogForm" novalidate>
          <div class="quick-log-draft-banner">
            <strong id="quickLogDraftStatus" role="status">Draft · not saved</strong>
          </div>
          <div class="quick-log-message" id="quickLogMessage" hidden></div>
          <div class="quick-log-grid">
            <label>
              <span>Operator</span>
              <input id="quickLogOperator" name="operator" type="text" readonly value="Loading...">
            </label>
            <label>
              <span>Seat</span>
              <select id="quickLogSeat" name="seat" required>
                <option value="">Loading seats...</option>
              </select>
            </label>
          </div>

          <section class="quick-log-history" id="quickLogHistory" hidden>
            <div class="quick-log-history-head">
              <div>
                <strong>Communication Log</strong>
                <p></p>
              </div>
              <span class="quick-log-history-count" id="quickLogHistoryCount">0</span>
            </div>
            <div class="quick-log-history-list" id="quickLogHistoryList"></div>
          </section>

          <section class="quick-log-editor">
            <div class="quick-log-editor-head">
              <div><strong>Communication Log <span id="quickLogEntryCount">1</span></strong></div>
              <button class="quick-log-add" id="quickLogAddRow" type="button">+ Add communication</button>
            </div>
            <div class="quick-log-table-wrap">
              <table class="quick-log-table" aria-label="Communication entries">
                <thead>
                  <tr>
                    <th class="quick-log-action-column" scope="col">Order</th>
                    <th scope="col">Date and time</th>
                    <th scope="col">Communication type</th>
                    <th scope="col">Contact person</th>
                    <th scope="col">Contact number</th>
                    <th scope="col">Email address</th>
                    <th scope="col">Communication notes</th>
                  </tr>
                </thead>
                <tbody class="quick-log-rows" id="quickLogRows"></tbody>
              </table>
            </div>
          </section>

          <div class="quick-log-footer">
            <p class="quick-log-submit-note" id="quickLogSubmitNote">Checking submission availability...</p>
            <div class="quick-log-actions">
              <button class="quick-log-add" id="quickLogSaveDraft" type="button">Save draft</button>
              <button class="quick-log-submit" id="quickLogSubmitButton" type="submit" disabled aria-describedby="quickLogSubmitNote">Close &amp; submit</button>
            </div>
          </div>
        </form>
      </section>
    </div>
  </body>
</html>' AS html;
