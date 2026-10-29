# Likely root causes — React / TypeScript frontend

## Effects and closures
- `useEffect` dependency array wrong → stale values, or an infinite loop (object/array/function recreated every render).
- Stale closure in handlers, intervals, subscriptions (reads old state) → use functional `setState` or a ref.
- Missing cleanup (listeners, intervals, sockets, AbortController) → leaks, updates after unmount.
- StrictMode runs effects twice in dev → a non-idempotent effect posts twice (double order/payment request).

## Data fetching
- Race: an older response overwrites a newer one (search, filters, tab switch) → `AbortController` or ignore stale results.
- React Query / SWR / RTK cache keys missing params, **tenant** or user → wrong data after switching store/account.
- No invalidation after a mutation → stale list; optimistic update not rolled back on error.
- Error and loading states unhandled → blank screen; no error boundary around routes.
- Double submit: button not disabled during the request; no idempotency key.

## State and rendering
- Missing or index `key` in lists → wrong row edited/deleted after reorder.
- State mutated in place (`push`, `sort`, nested object edit) → no re-render.
- Derived state copied into `useState` from props → never updates.
- Controlled/uncontrolled input switch (`value` undefined → defined).
- Heavy lists without virtualization; context value recreated every render → whole tree re-renders.

## Flaky tests
- `setTimeout`/`sleep` or `waitForTimeout` in tests → `await screen.findBy…`, `waitFor(() => …)`, Playwright web-first `expect(locator)`; fake timers (`vi.useFakeTimers`) for debounce/polling.
- Fake timers, mocked `fetch`/modules or MSW handlers not restored (`vi.restoreAllMocks`, `server.resetHandlers`) → the next test inherits them.
- Module-level store/singleton (Zustand, query client) shared between tests → create it per test.

## Forms and validation
- Client validation differs from server validation; server errors (ProblemDetails) not mapped to fields.
- Number inputs: Persian digits, thousand separators, empty string → `NaN`/0 sent to the API.

## Routing and auth
- Token in `localStorage` (XSS-exposed); refresh-token race → several parallel refreshes, logout loops.
- Protected route checks only "logged in", not role/tenant; 401 vs 403 handled the same → redirect loop.
- Deep link / refresh on a client route returns 404 (server fallback missing).

## Build and environment
- `import.meta.env` / `process.env` baked at build time → per-tenant config must come at runtime.
- Wrong tsconfig type-checked (Vite root `tsconfig.json` has `"files": []`).
- Generated API client stale after a backend DTO change.

## RTL and i18n
- `left/right` CSS instead of logical properties (`margin-inline-start`) → broken RTL; icons/arrows not mirrored.
- Dates shown in Gregorian or in UTC; `Intl` locale not `fa-IR`; numbers/currency formatted inconsistently.
