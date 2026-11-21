# Performance Optimization Ledger & Guardrails

This document tracks performance baselines, optimization experiments, and guidelines to prevent regressions across `smart_translator_test`.

---

## Optimization Attempt Ledger

| Idea / Optimization | Target Area | Baseline $\rightarrow$ Result | Verdict | Why / Measurement |
| :--- | :--- | :--- | :---: | :--- |
| **Replace N+1 loop in `FolderCubit.loadFolders` with single join query** | SQLite / Storage | $1 + N$ queries + $N$ full JSON decodings $\rightarrow$ **1 single SQL query with count, 0 JSON decodes** | **KEPT** | Single SQL `LEFT OUTER JOIN` + `COUNT(term_id)` executes atomically. Replaced iterative deserialization. |
| **Add index on `TermFolders(folder_id)`** | Database Indexing | Full table scan on `WHERE folder_id = ?` $\rightarrow$ **Index seek lookup** | **KEPT** | Composite primary key `(term_id, folder_id)` could not index queries filtering on `folder_id` alone. |
| **Limit dashboard `getAllTerms()` to `getRecentTerms(limit: 5)` and scalar `getWordOfTheDay()`** | UI / Dashboard | $O(N)$ full table load and JSON decode on UI thread $\rightarrow$ **$O(1)$ constant time ($\le 6$ terms max)** | **KEPT** | Dashboard now loads in constant time regardless of whether user has 10 or 10,000 saved terms. |
| **In-memory token caching in `SecureStorageService`** | Network / Platform Channels | ~10–40ms KeyStore disk/crypto latency per request $\rightarrow$ **0ms (instant in-memory hit)** | **KEPT** | `AuthInterceptor.onRequest` reads cached token without blocking on platform channel operations. |
| **Debounce real-time search in `SyncedVocabularyPage`** | UI / Main Thread | Unthrottled `setState` on every keystroke $\rightarrow$ **250ms debounced filter** | **KEPT** | Eliminates frame drops and unnecessary full-list linear traversals while typing. |
| **Defer unauthenticated `getProfile()` in `main.dart`** | Startup Pipeline | Eager network request on unauthenticated launch $\rightarrow$ **Deferred to `MainShell` post-auth** | **KEPT** | Removes bandwidth contention at startup; avoids 401 unauthenticated errors on fresh installs. |

---

## Performance Guardrails & Budgets

To keep the application fast, responsive, and light on system resources, adhere to these guidelines:

1. **Database Queries:**
   - Always query with `limit` and `orderBy` on list views. Never use `getAllTerms()` to populate small dashboard cards or preview lists.
   - For counts, use SQL `COUNT(*)` via `getTermsCount()` or `addColumns([column.count()])` instead of loading rows and checking `.length`.
   - Maintain indexes on foreign keys in junction tables (`idx_term_folders_folder_id`).

2. **Network & Platform Channels:**
   - Prefer in-memory caching for frequently read configuration/tokens instead of calling `FlutterSecureStorage` on every network request.
   - Do not trigger eager network calls in `main.dart` before `AuthBloc` confirms user session.

3. **UI & State Management:**
   - Debounce search fields (`Timer(Duration(milliseconds: 250), ...)`).
   - Use `buildWhen` on `BlocBuilder` to avoid full-tree rebuilds when unrelated state properties change.
