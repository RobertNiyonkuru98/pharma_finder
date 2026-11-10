# Contributing

## Branches
- `main` — what we submit. Protected. Always builds.
- `dev` — integration. All PRs merge here.
- `feat/<yourname>/<what>` — e.g. `feat/david/erd-firestore`

## Commits
Descriptive, prefixed:
`feat(auth): add Google sign-in`
`fix(facilities): handle empty stock list`
`docs(report): add ERD section`

Never: `update`, `changes`, `final`, `wip`.

## Before every PR
1. `flutter analyze` → must say **No issues found!**
2. `flutter test` → all green
3. `dart format .`

## Never
- Push directly to `main`
- Use `setState()` for state management
- Run `flutter run -d chrome` — web builds score zero