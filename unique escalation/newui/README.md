# CC Operator Performance Dashboard

This folder contains a React + Vite frontend and SQLPage-backed API endpoints for operator performance reporting.

## Implemented

- Date and time range filtering using `datetime_opened`
- Multi-operator picker
- Total logs per operator per event
- Event summary panel
- Excel export in the browser

## Frontend

- Source: `src/`
- Build output: `dist/`
- Dev server: `npm run dev`
- Production build: `npm run build`

If the frontend runs separately from SQLPage, set these values in `.env.local`:

```env
VITE_API_PROXY_TARGET=http://127.0.0.1:8080
VITE_API_PROXY_PREFIX=/CC_Escalation/unique%20escalation/newui
```

Or point directly to the backend:

```env
VITE_API_BASE_URL=http://127.0.0.1:8080/CC_Escalation/unique%20escalation/newui/api
```

## SQLPage Backend Endpoints

- `api/operators.sql`
- `api/stats.sql`

These endpoints return JSON for the frontend and rely on the existing SQLPage database connection.
