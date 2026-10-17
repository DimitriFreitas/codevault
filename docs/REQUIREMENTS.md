# CodeVault — Requirements Matrix

Authoritative functional requirements for **CodeVault — a Programming Project
Manager** (academic Flutter/Dart mobile application). Written in English; the
application UI is pt-BR.

Status legend:
- `PENDING` — not implemented.
- `IMPLEMENTED` — code exists but the behavior has not been exercised.
- `VERIFIED` — behavior was actually exercised (test or manual demonstration),
  with evidence recorded.

> Current baseline: `lib/main.dart` is still the stock `flutter create` counter
> template, so every CodeVault requirement below starts as `PENDING`.

| # | Requirement | Expected behavior | Screens / components / services | Verification method | Status | Evidence / notes |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Public project listing | A visitor (not logged in) sees the list of projects loaded from JSON. | `ProjectListScreen`, `ProjectCard`, `ProjectRepository` | Widget test rendering the list from a loaded fixture; manual run as visitor | PENDING | — |
| 2 | Public project details | Opening a project shows name, description, programming languages, technologies and development status, readable by visitors. | `ProjectDetailScreen`, `Project`, `ProjectRepository` | Widget test asserting all five fields render; manual run | PENDING | — |
| 3 | Mock login | Authenticated with fictional credentials from `users.json`; invalid credentials rejected with a pt-BR message. | `LoginScreen`, `MockAuthService`, `AppUser`, `AppState` | Unit test of auth service (valid + invalid); widget test of error message | PENDING | No real provider/hashing allowed. |
| 4 | Logout | Clears the in-memory session and returns the app to visitor state. | `AppState`, app bar / menu action | Widget test: login → logout → gated actions blocked | PENDING | Session is memory-only. |
| 5 | Project registration | An authenticated user registers a project (name, description, languages, technologies, status); it appears in the list and in their own projects. | `NewProjectScreen`, `Project`, `AppState` | Widget test filling and submitting the form; assert the new item appears | PENDING | In memory only; not written to JSON. |
| 6 | User-specific project listing | "My projects" shows only projects owned by the logged-in user. | `MyProjectsScreen`, `AppState` | Widget test with two users asserting filtering | PENDING | — |
| 7 | Favorite / unfavorite | An authenticated user can toggle favorite on a project; state updates immediately. | `ProjectCard` / `ProjectDetailScreen` actions, `AppState` | Widget test toggling and asserting icon/state | PENDING | — |
| 8 | User-specific favorites | Favorites are scoped to the logged-in user and listed in a dedicated section. | `FavoritesScreen`, `AppState` | Widget test: favorite as user A, verify isolation from user B | PENDING | — |
| 9 | Public comment reading | Comments on a project are readable by everyone, including visitors. | `ProjectDetailScreen`, comment list widget, `Comment` | Widget test rendering seeded comments as a visitor | PENDING | — |
| 10 | Authenticated comment publishing | A logged-in user posts a comment that appears immediately for that project. | Comment form widget, `ProjectDetailScreen`, `AppState` | Widget test: login → post → assert comment appears | PENDING | — |
| 11 | Local JSON data loading | Initial data comes from `assets/data/*.json`, declared in `pubspec.yaml`, loaded via `rootBundle.loadString` + `jsonDecode`. No network. | `ProjectRepository`, `MockAuthService`, assets | Unit test decoding the actual asset bundles; `flutter test` | PENDING | Assets must not be treated as writable. |
| 12 | Correct access restrictions | Visitor actions that require auth (new project, favorite, my projects, post comment) are blocked or redirect to login. | Navigation guards, `AppState` | Widget tests for each gated action while logged out | PENDING | No silent success. |
| 13 | Runtime state consistency | New projects, favorites and comments made in a session stay consistent across screens until restart (then reset). | `AppState` (`ChangeNotifier`) | Widget test navigating across screens asserting shared state; restart resets | PENDING | Expected reset on restart. |

## Notes

- Rows must be moved to `IMPLEMENTED` only when code exists, and to `VERIFIED`
  only when the behavior was demonstrated and the evidence recorded here.
- See [`IMPLEMENTATION_PLAN.md`](IMPLEMENTATION_PLAN.md) for the build sequence
  and per-phase acceptance criteria.
