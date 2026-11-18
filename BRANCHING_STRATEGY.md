# Multi-Environment Branching & Deployment Strategy

This repository follows a 5-branch enterprise promotion workflow:

```text
dev ──▶ sit ──▶ uat ──▶ prod (Live Deployment)
                 │
                 ▼
                main (Stable Baseline / Default Branch)
```

## Branches

| Branch | Purpose | CI/CD Behavior |
|---|---|---|
| `dev` | Active development & feature integration | Runs `flutter analyze`, `flutter test`, and web build verification |
| `sit` | System Integration Testing | Runs full CI verification + artifact packaging |
| `uat` | User Acceptance Testing & pre-release sign-off | Runs full CI verification + preview artifact packaging |
| `prod` | Production release branch | Builds Flutter Web + exports latest ATS PDF + **deploys live to GitHub Pages** |
| `main` | Clean default / baseline branch synced with stable releases | Runs full CI verification |

## Standard Promotion Commands

```powershell
# 1. Push all branches on first setup
git push -u origin main dev sit uat prod

# 2. Promote dev -> sit
git checkout sit
git merge dev
git push origin sit

# 3. Promote sit -> uat
git checkout uat
git merge sit
git push origin uat

# 4. Promote uat -> prod (triggers live deployment)
git checkout prod
git merge uat
git push origin prod

# 5. Keep main in sync with prod
git checkout main
git merge prod
git push origin main
```
