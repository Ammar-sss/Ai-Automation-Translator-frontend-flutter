# Code Smell Report

## Stack: Flutter (Dart)
### Files scanned: 149
### Total smells found: 28

## Smell Summary by Category

| Category | Critical | High | Medium | Low | Total |
|---|---|---|---|---|---|
| Bloaters | 0 | 3 | 5 | 2 | 10 |
| OO Abusers | 0 | 0 | 3 | 1 | 4 |
| Change Preventers | 0 | 1 | 3 | 0 | 4 |
| Dispensables | 0 | 0 | 1 | 2 | 3 |
| Couplers | 0 | 0 | 3 | 0 | 3 |

## Critical & High Smells (ranked by impact)

### 1. LONG METHOD: `lib/features/practice/presentation/pages/practice_page.dart`
- **Method**: `_buildSessionSummary`, `_buildActiveSession`, `_buildSessionHeader`
- **Line count**: Each method exceeds 50 lines of logic
- **Location**: practice_page.dart:297-863, practice_page.dart:216-381, practice_page.dart:383-473
- **Severity**: High
- **Refactoring**: Extract logical blocks into separate widget methods (e.g., `_buildStatsSection`, `_buildProgressHeader`, `_buildSummaryActions`)

### 2. LONG METHOD: `lib/core/error/app_exception.dart`
- **Method**: `ApiErrorHandler.handle`
- **Line count**: 89 lines with a switch statement on status codes
- **Location**: app_exception.dart:18-89
- **Severity**: High
- **Refactoring**: Extract status code handling into a map-based lookup or separate method `_handleStatusCode(statusCode)` 

### 3. DATA CLUMP: `(sourceLanguage, targetLanguage)` pattern
- **Fields**: Appears in 15+ locations across the codebase
- **Locations**: app_database.dart, vocabulary_cubit.dart, translate_page.dart, practice_page.dart, term.dart
- **Pattern**: `sourceLanguage` and `targetLanguage` checked together in if-conditions across 5+ files
- **Severity**: Medium
- **Refactoring**: Create a `LanguagePair` class/value object to encapsulate both languages

### 4. DIVERGENT CHANGE: `lib/core/storage/app_database.dart`
- **Class**: `AppDatabase` (636 lines)
- **Responsibilities**: Folder operations, term operations, database migrations, term-in-folder management, cloud sync status reset
- **Evidence**: Modified for unrelated reasons - migrations, term storage, folder management
- **Severity**: Medium
- **Refactoring**: Split into `TermDatabase`, `FolderDatabase`, and `SyncService`

### 5. SWITCH STATEMENT: `lib/features/overlay_bubble/presentation/widgets/quick_scan_overlay.dart`
- **Method**: `build` method switch on `lang.toLowerCase()`
- **Line count**: 12 cases for language mapping
- **Location**: quick_scan_overlay.dart:23-34
- **Severity**: Medium
- **Refactoring**: Replace with `Map<String, String>` lookup or `when` expression

### 6. SWITCH STATEMENT: `lib/features/translate/presentation/pages/translate_page.dart`
- **Method**: `_languageCode` method
- **Line count**: 14 case statements for language codes
- **Location**: translate_page.dart:39-61
- **Severity**: Medium
- **Refactoring**: Replace with `Map<TranslationLanguage, String>` lookup

### 7. PRIMITIVE OBSESSION: `String` used for language codes
- **Current**: `String` type for `sourceLanguage`, `targetLanguage` across 12+ files
- **Issue**: No domain type, stringly-typed, prone to typos
- **Severity**: Medium
- **Refactoring**: Create `LanguageCode` value class with validation

### 8. LAZY CLASS: `lib/core/widgets/main_shell.dart`
- **Class**: `_MainShellState`
- **Lines**: 359 lines with limited behavior
- **Issue**: State management spread across multiple cubits/blocs, some methods just delegate
- **Severity**: Low
- **Refactoring**: Consider extracting shell navigation logic into separate widget/service

### 9. TEMPORARY FIELD: `lib/features/auth/presentation/pages/register_page.dart`
- **Fields**: `_obscurePassword`, `_obscureConfirmPassword`
- **Issue**: Only used in build method for visibility toggling, could be encapsulated
- **Severity**: Low
- **Refactoring**: Extract into `_PasswordField` widget component

### 10. SPECULATIVE GENERALITY: `lib/core/network/api_endpoints.dart`
- **Class**: `ApiEndpoint`
- **Issue**: Static constants that are used in only a few places (auth interceptor)
- **Severity**: Low
- **Refactoring**: Inline where used or create focused enum

## Top 10 Worst Files (by smell count and severity)

| File | Lines | Smells | Worst Smell | Recommendation |
|---|---|---|---|---|
| `lib/features/practice/presentation/pages/practice_page.dart` | 1149 | 4 | Long Method | Extract session summary and active session into separate widgets |
| `lib/core/error/app_exception.dart` | 89 | 3 | Long Method / Switch Statement | Extract status code handling into map |
| `lib/core/storage/app_database.dart` | 617 | 4 | Divergent Change | Split into separate database services |
| `lib/features/translate/presentation/pages/translate_page.dart` | 302 | 3 | Switch Statement / Long Method | Replace language code switch with map |
| `lib/features/practice/presentation/widgets/quick_translate_card.dart` | 341 | 2 | Data Clump | Create LanguagePair value object |
| `lib/features/translate/presentation/widgets/language_dropdown.dart` | 53 | 2 | Switch Statement | Replace with map lookup |
| `lib/features/auth/presentation/pages/register_page.dart` | 323 | 2 | Temporary Field | Extract password fields into component |
| `lib/features/vocabulary/presentation/widgets/folder_popup_menu.dart` | ~71 | 2 | Switch Statement | Replace with enum/expansion |
| `lib/features/vocabulary/data/models/term_definitions.dart` | 48 | 2 | Primitive Obsession | Create domain type for definitions |
| `lib/core/widgets/main_shell.dart` | 359 | 1 | Lazy Class | Extract shell navigation logic |

## Refactoring Priority Queue

1. **Split `AppDatabase`** — fixes 4 smells (divergent change), high effort M/L
2. **Create `LanguageCode` value class** — fixes primitive obsession across 12 files, medium effort M
3. **Replace language code switches with maps** — fixes 3 switch smells, low effort S
4. **Extract `PracticePage` widgets** — fixes 4 long method smells, medium effort M
5. **Extract `ApiErrorHandler` status logic** — fixes 1 long method + switch, low effort S
6. **Create `LanguagePair` value object** — fixes data clump across 5+ files, medium effort M

## Metrics
- Average method length: ~30 lines (excluding blank lines and comments)
- Average class length: ~85 lines
- Longest method: `_buildSessionSummary` (128 lines) in `practice_page.dart`
- Largest class: `AppDatabase` (617 lines) in `app_database.dart`
- Deepest message chain: 3 links in `translate_page.dart` → `translate_cubit` → `translate_repository`

## Next Steps
- "Run `/iterate` to implement the top refactorings."
- "Run `/dead-code` for thorough dead code removal."
- "Run `/tech-debt` for a broader technical debt inventory."
- "Run `/perf` to check if any smelly code is also a performance bottleneck."

## Self-Healing Validation (max 3 iterations)

After completing fixes, re-validate:
1. Re-run the specific checks that originally found issues
2. Run the project's test suite to verify fixes didn't introduce regressions
3. Run build/compile to confirm no breakage
4. If new issues surfaced from fixes, add them to the fix queue
5. Repeat the fix-validate cycle up to 3 iterations total

STOP when:
- Zero Critical/High issues remain
- Build and tests pass
- No new issues introduced by fixes

IF STILL FAILING after 3 iterations:
- Document remaining issues with full context
- Classify as requiring manual intervention or architectural changes