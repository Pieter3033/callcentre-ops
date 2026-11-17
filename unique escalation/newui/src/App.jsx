import { startTransition, useDeferredValue, useEffect, useState } from "react";
import writeXlsxFile from "write-excel-file/browser";

function formatDateTimeLocal(date) {
  const offset = date.getTimezoneOffset();
  const localDate = new Date(date.getTime() - offset * 60000);
  return localDate.toISOString().slice(0, 16);
}

function getDefaultStart() {
  const date = new Date();
  date.setDate(date.getDate() - 7);
  date.setSeconds(0, 0);
  return formatDateTimeLocal(date);
}

function getDefaultEnd() {
  const date = new Date();
  date.setSeconds(0, 0);
  return formatDateTimeLocal(date);
}

function formatDisplayDate(value) {
  if (!value) return "-";

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "-";

  return new Intl.DateTimeFormat("en-ZA", {
    year: "numeric",
    month: "short",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit"
  }).format(date);
}

function formatNumber(value) {
  return new Intl.NumberFormat("en-ZA").format(value);
}

function getApiBaseUrl() {
  if (import.meta.env.VITE_API_BASE_URL) {
    return import.meta.env.VITE_API_BASE_URL.replace(/\/$/, "");
  }

  return new URL("./api", window.location.href).toString().replace(/\/$/, "");
}

function buildUrl(path, params = {}) {
  const url = new URL(`${getApiBaseUrl()}/${path}`, window.location.href);

  Object.entries(params).forEach(([key, value]) => {
    if (value === undefined || value === null || value === "") return;
    url.searchParams.set(key, value);
  });

  return url.toString();
}

function buildOperatorSummary(selectedOperators) {
  if (selectedOperators.length === 0) return "All operators";
  if (selectedOperators.length === 1) return selectedOperators[0];
  return `${selectedOperators.length} operators selected`;
}

function buildWorkbook(rows, eventTotals, filters) {
  const header = (value) => ({ value, fontWeight: "bold" });

  return [
    {
      name: "Operator Stats",
      data: [
        [header("Operator"), header("Event"), header("Total Logs"), header("First Log"), header("Last Log")],
        ...rows.map((row) => [
          { value: row.cc_operator },
          { value: row.event },
          { value: row.total_logs, type: Number.isFinite(Number(row.total_logs)) ? Number : String },
          { value: row.first_log_at },
          { value: row.last_log_at }
        ])
      ]
    },
    {
      name: "Event Summary",
      data: [
        [header("Event"), header("Total Logs")],
        ...eventTotals.map((row) => [
          { value: row.event },
          { value: row.total_logs, type: Number.isFinite(Number(row.total_logs)) ? Number : String }
        ])
      ]
    },
    {
      name: "Filters",
      data: [
        [header("Filter"), header("Value")],
        [{ value: "Start" }, { value: filters.start }],
        [{ value: "End" }, { value: filters.end }],
        [
          { value: "Operators" },
          { value: filters.operators.length > 0 ? filters.operators.join(", ") : "All operators" }
        ],
        [{ value: "Exported At" }, { value: new Date().toISOString() }]
      ]
    }
  ];
}

export default function App() {
  const [start, setStart] = useState(getDefaultStart);
  const [end, setEnd] = useState(getDefaultEnd);
  const [operators, setOperators] = useState([]);
  const [selectedOperators, setSelectedOperators] = useState([]);
  const [operatorSearch, setOperatorSearch] = useState("");
  const [pickerOpen, setPickerOpen] = useState(false);
  const [rows, setRows] = useState([]);
  const [eventTotals, setEventTotals] = useState([]);
  const [loading, setLoading] = useState(false);
  const [loadingOperators, setLoadingOperators] = useState(true);
  const [error, setError] = useState("");

  const deferredSearch = useDeferredValue(operatorSearch.trim().toLowerCase());
  const operatorOptions = operators
    .filter((operator) => operator.toLowerCase().includes(deferredSearch))
    .map((operator) => ({
      operator,
      selected: selectedOperators.includes(operator)
    }));

  const totalLogs = rows.reduce((sum, row) => sum + Number(row.total_logs || 0), 0);
  const totalOperators = new Set(rows.map((row) => row.cc_operator)).size;
  const topEvent = eventTotals[0] || null;

  async function loadOperators() {
    setLoadingOperators(true);
    setError("");

    try {
      const response = await fetch(buildUrl("operators.sql"));
      const payload = await response.json();

      if (!response.ok) {
        throw new Error(payload.error || "Failed to load operators.");
      }

      startTransition(() => {
        setOperators(payload.operators || []);
      });
    } catch (loadError) {
      setError(loadError.message);
    } finally {
      setLoadingOperators(false);
    }
  }

  async function loadStats(nextFilters) {
    if (!nextFilters.start || !nextFilters.end) {
      setError("Choose both a start and end date.");
      return;
    }

    if (new Date(nextFilters.start) > new Date(nextFilters.end)) {
      setError("The start date must be earlier than the end date.");
      return;
    }

    setLoading(true);
    setError("");

    try {
      const response = await fetch(
        buildUrl("stats.sql", {
          start: nextFilters.start,
          end: nextFilters.end,
          operators: nextFilters.operators.join(",")
        })
      );
      const payload = await response.json();

      if (!response.ok) {
        throw new Error(payload.error || "Failed to load statistics.");
      }

      startTransition(() => {
        setRows(payload.rows || []);
        setEventTotals(payload.eventTotals || []);
      });
    } catch (loadError) {
      startTransition(() => {
        setRows([]);
        setEventTotals([]);
      });
      setError(loadError.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadOperators();
  }, []);

  useEffect(() => {
    loadStats({ start, end, operators: selectedOperators });
  }, []);

  useEffect(() => {
    function handleDocumentClick(event) {
      if (event.target.closest(".picker")) return;
      setPickerOpen(false);
    }

    document.addEventListener("click", handleDocumentClick);
    return () => document.removeEventListener("click", handleDocumentClick);
  }, []);

  function toggleOperator(operator) {
    setSelectedOperators((current) =>
      current.includes(operator)
        ? current.filter((item) => item !== operator)
        : [...current, operator].sort((a, b) => a.localeCompare(b))
    );
  }

  function resetFilters() {
    const nextStart = getDefaultStart();
    const nextEnd = getDefaultEnd();
    setStart(nextStart);
    setEnd(nextEnd);
    setSelectedOperators([]);
    setOperatorSearch("");
    setPickerOpen(false);
    loadStats({ start: nextStart, end: nextEnd, operators: [] });
  }

  async function exportToExcel() {
    const sheets = buildWorkbook(rows, eventTotals, {
      start,
      end,
      operators: selectedOperators
    });

    const timestamp = new Date().toISOString().slice(0, 19).replace(/[:T]/g, "-");
    await writeXlsxFile(
      sheets.map((sheet) => sheet.data),
      {
        fileName: `cc-operator-stats-${timestamp}.xlsx`,
        sheets: sheets.map((sheet) => sheet.name)
      }
    );
  }

  return (
    <div className="page-shell">
      <header className="hero panel">
        <div className="hero-copy">
          <h1>Operator Performance Monitor</h1>
          <p className="hero-text">
            Review total logs per operator per event across any selected date and time range. Export the filtered result set directly to Excel.
          </p>
        </div>

        <div className="hero-band">
          <div className="hero-stat">
            <span>Source</span>
            <strong>Infinity Quick Logs</strong>
          </div>
        </div>
      </header>

      <main className="dashboard">
        <section className="panel filters-panel reveal">
          <div className="section-head">
            <div>
              <h2>Filters</h2>
              <p>Apply a precise date-time range and narrow results to one or many operators.</p>
            </div>
            <div className="section-badge">{loading ? "Refreshing" : "Ready"}</div>
          </div>

          <div className="filters-grid">
            <label className="field">
              <span>Start</span>
              <input type="datetime-local" value={start} onChange={(event) => setStart(event.target.value)} />
            </label>

            <label className="field">
              <span>End</span>
              <input type="datetime-local" value={end} onChange={(event) => setEnd(event.target.value)} />
            </label>

            <div className="field">
              <span>Operators</span>
              <div className="picker">
                <button className="picker-toggle" type="button" onClick={() => setPickerOpen((current) => !current)}>
                  {loadingOperators ? "Loading operators..." : buildOperatorSummary(selectedOperators)}
                </button>

                {pickerOpen ? (
                  <div className="picker-panel">
                    <input
                      type="search"
                      placeholder="Search operator"
                      value={operatorSearch}
                      onChange={(event) => setOperatorSearch(event.target.value)}
                    />

                    <div className="picker-actions">
                      <button className="text-button" type="button" onClick={() => setSelectedOperators(operators)}>
                        Select all
                      </button>
                      <button className="text-button" type="button" onClick={() => setSelectedOperators([])}>
                        Clear
                      </button>
                    </div>

                    <div className="operator-list">
                      {operatorOptions.length === 0 ? (
                        <div className="empty-mini">No operators match this search.</div>
                      ) : (
                        operatorOptions.map(({ operator, selected }) => (
                          <label className="operator-item" key={operator}>
                            <input
                              type="checkbox"
                              checked={selected}
                              onChange={() => toggleOperator(operator)}
                            />
                            <span>{operator}</span>
                          </label>
                        ))
                      )}
                    </div>
                  </div>
                ) : null}
              </div>
            </div>
          </div>

          <div className="action-row">
            <button className="btn primary" type="button" onClick={() => loadStats({ start, end, operators: selectedOperators })} disabled={loading}>
              Apply Filters
            </button>
            <button className="btn secondary" type="button" onClick={resetFilters} disabled={loading}>
              Reset
            </button>
            <button className="btn accent" type="button" onClick={exportToExcel} disabled={loading || rows.length === 0}>
              Export Excel
            </button>
          </div>

          {error ? <div className="error-banner">{error}</div> : null}
        </section>

        <section className="metrics-grid reveal delay-1">
          <article className="panel metric-card">
            <span>Total Logs</span>
            <strong>{formatNumber(totalLogs)}</strong>
          </article>
          <article className="panel metric-card">
            <span>Operators</span>
            <strong>{formatNumber(totalOperators)}</strong>
          </article>
          <article className="panel metric-card">
            <span>Events</span>
            <strong>{formatNumber(eventTotals.length)}</strong>
          </article>
          <article className="panel metric-card">
            <span>Top Event</span>
            <strong className="metric-long">{topEvent ? `${topEvent.event} (${formatNumber(topEvent.total_logs)})` : "None"}</strong>
          </article>
        </section>

        <section className="content-grid reveal delay-2">
          <article className="panel event-panel">
            <div className="section-head">
              <div>
                <h2>Event Mix</h2>
                <p>Event totals in the current filter range.</p>
              </div>
            </div>

            <div className="event-list">
              {eventTotals.length === 0 ? (
                <div className="empty-state">No events found for the selected range.</div>
              ) : (
                eventTotals.map((item) => {
                  const width = totalLogs === 0 ? 0 : (item.total_logs / totalLogs) * 100;
                  return (
                    <article className="event-item" key={item.event}>
                      <div className="event-item-head">
                        <span>{item.event}</span>
                        <strong>{formatNumber(item.total_logs)}</strong>
                      </div>
                      <div className="event-bar">
                        <div className="event-bar-fill" style={{ width: `${width}%` }} />
                      </div>
                    </article>
                  );
                })
              )}
            </div>
          </article>

          <article className="panel table-panel">
            <div className="section-head">
              <div>
                <h2>Operator Totals</h2>
                <p>{rows.length} operator-event rows in the current dataset.</p>
              </div>
            </div>

            <div className="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>Operator</th>
                    <th>Event</th>
                    <th>Total Logs</th>
                    <th>First Log</th>
                    <th>Last Log</th>
                  </tr>
                </thead>
                <tbody>
                  {rows.length === 0 ? (
                    <tr>
                      <td className="empty-state" colSpan="5">
                        No logs found for the current filters.
                      </td>
                    </tr>
                  ) : (
                    rows.map((row) => (
                      <tr key={`${row.cc_operator}-${row.event}`}>
                        <td>{row.cc_operator}</td>
                        <td>{row.event}</td>
                        <td>{formatNumber(row.total_logs)}</td>
                        <td>{formatDisplayDate(row.first_log_at)}</td>
                        <td>{formatDisplayDate(row.last_log_at)}</td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </article>
        </section>
      </main>
    </div>
  );
}
