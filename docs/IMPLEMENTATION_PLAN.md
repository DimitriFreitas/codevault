# CodeVault — Implementation Plan

Sequence for building **CodeVault** on top of the current stock Flutter template.
Written in English. Each phase lists concrete deliverables and acceptance
criteria; a phase is done only when its acceptance criteria are exercised and
recorded in [`REQUIREMENTS.md`](REQUIREMENTS.md).

Guiding constraints (see `AGENTS.md`): built-in Flutter state only, static
read-only JSON assets, in-memory runtime changes, no backend/database/persistence.

## Phase 1 — Data layer and assets

Deliverables:
- `assets/data/projects.json` and `assets/data/users.json` (fictional data).
- `assets:` entries in `pubspec.yaml`.
- `lib/models/` (`Project`, `Comment`, `AppUser`) with `fromJson` factories.
- `lib/services/project_repository.dart` and `lib/services/mock_auth_service.dart`
  loading via `rootBundle.loadString` + `jsonDecode`.

Acceptance criteria:
- `flutter pub get` succeeds with the new assets declared.
- Unit test decodes the real asset bundles and produces model instances.
- No network/persistence code introduced.

## Phase 2 — In-memory state and session

Deliverables:
- `lib/state/app_state.dart` (`ChangeNotifier`) holding the logged-in user,
  the projects, per-user favorites, and comments.
- Login/logout methods delegating to `MockAuthService`.

Acceptance criteria:
- Unit test: valid credentials set the session; invalid ones are rejected.
- Logout clears the session.
- State mutations (add project, toggle favorite, add comment) are observable
  through the notifier.

## Phase 3 — Public screens (visitor)

Deliverables:
- `ProjectListScreen` + `ProjectCard` (name, languages, status summary).
- `ProjectDetailScreen` showing name, description, languages, technologies,
  status, and the comment list (read-only).
- App entry wiring in `main.dart` (theme, routes, `ChangeNotifier` exposure).

Acceptance criteria (covers matrix rows 1, 2, 9, 11):
- As a visitor, the list renders from JSON; opening a project shows all five
  required fields and any seeded comments.
- Widget tests assert list rendering and detail rendering.

## Phase 4 — Authentication UI and gating

Deliverables:
- `LoginScreen` with pt-BR labels and invalid-credential error message.
- Guards/redirects so gated actions require login.

Acceptance criteria (covers rows 3, 4, 12):
- Valid login succeeds; invalid login shows a pt-BR error.
- Logout returns to visitor state.
- Each gated action (new project, favorite, my projects, post comment) is blocked
  or redirects to login when logged out.
- Widget tests cover login success/failure, logout, and each guard.

## Phase 5 — Authenticated features

Deliverables:
- `NewProjectScreen` form (name, description, languages, technologies, status).
- Favorite/unfavorite actions on the card and detail screen.
- `MyProjectsScreen` (owned by current user) and `FavoritesScreen` (per-user).
- Comment posting form on the detail screen.

Acceptance criteria (covers rows 5, 6, 7, 8, 10, 13):
- A new project appears in the public list and in "my projects".
- Favorites toggle immediately and are isolated per user.
- Posting a comment appends it immediately and it is visible to everyone.
- Widget tests exercise registration, favorite isolation, my-projects filtering,
  and comment publishing.
- Navigating across screens preserves the in-memory state for the session.

## Phase 6 — Verification and documentation

Deliverables:
- Full `flutter analyze` and `flutter test` runs, output recorded.
- `REQUIREMENTS.md` rows updated to `VERIFIED` with evidence.

Acceptance criteria:
- `flutter analyze` reports no issues.
- `flutter test` passes; each `VERIFIED` row cites the test or manual demo used.

## Out of scope (do not build)

Real backend/API, database, real registration or external auth, code-hosting
integration, social features, and any edit/delete/rating/review system.
