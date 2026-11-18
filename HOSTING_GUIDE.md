# Hosting & Automated CI/CD Guide

This project ships a unified production bundle inside `portfolio_website/`:
- **Portfolio Website** (`/`) — Static HTML/CSS/JS portfolio (`portfolio_website/index.html`)
- **ATS Resume PDF** (`/assets/Rahul_Deore_ATS_Resume.pdf`) — Generated programmatically by `ats_resume_builder/tool/export_ats_pdf.dart`
- **ATS Resume Builder App** (`/resume-builder/`) — Flutter Web release build of `ats_resume_builder/`

---

## Multi-Environment CI/CD Pipeline

The GitHub Actions workflow at `.github/workflows/deploy.yml` enforces a 5-branch enterprise promotion workflow:

| Branch | Pipeline Behavior |
|---|---|
| `dev` | Runs `flutter pub get`, `flutter analyze`, `flutter test`, ATS PDF export, and release Web build verification |
| `sit` | Full verification + packages downloadable `portfolio-preview-sit` artifact (14-day retention) |
| `uat` | Full verification + packages downloadable `portfolio-preview-uat` artifact (14-day retention) |
| `prod` | Full verification + regenerates ATS PDF & Flutter Web bundle + **deploys live to GitHub Pages** |
| `main` | Full CI verification on baseline branch |

> **Manual Deploy:** You can also trigger a full build and production deployment at any time from **GitHub → Actions → CI/CD & Production Deployment → Run workflow**.

---

## Go Live in 3 Steps (GitHub Pages — Recommended, Free & Automated)

### Step 1: Link Your GitHub Repository & Push All 5 Branches

Create a new empty repository on GitHub (for example, `ats-resume-builder` or `<your-username>.github.io`), then run from `D:\ATS_Resume_Builder\`:

```powershell
git remote add origin https://github.com/<your-username>/<your-repo>.git
git push -u origin main dev sit uat prod
```

> **Note on `BASE_HREF`:** The CI workflow automatically detects your repository name.
> - If your repo is `<your-username>.github.io`, Flutter Web is built with `--base-href "/resume-builder/"`.
> - For any other repo name, Flutter Web is built with `--base-href "/<your-repo>/resume-builder/"`.

### Step 2: Enable GitHub Pages (GitHub Actions Source)

1. Open your repository on GitHub and go to **Settings → Pages**.
2. Under **Build and deployment → Source**, select **GitHub Actions**.
3. Save (no branch selection is needed — `.github/workflows/deploy.yml` deploys directly from `prod`).

### Step 3: Trigger Your First Live Deployment

If you pushed `prod` before enabling GitHub Pages in Step 2, trigger the first live deploy in either of two ways:
- **Option A (GitHub UI):** Go to **Actions → CI/CD & Production Deployment → Run workflow** (select branch `prod`) and click **Run workflow**.
- **Option B (Git push):** Promote your next change to `prod`:
  ```powershell
  git checkout prod
  git merge uat
  git push origin prod
  ```

Once the **Deploy to GitHub Pages (Production)** job finishes (green checkmark), GitHub prints your live URL in the workflow summary:
- **User-site repo (`<your-username>.github.io`):**
  - Portfolio: `https://<your-username>.github.io/`
  - Resume Builder App: `https://<your-username>.github.io/resume-builder/`
  - ATS Resume PDF: `https://<your-username>.github.io/assets/Rahul_Deore_ATS_Resume.pdf`
- **Project repo (e.g., `ats-resume-builder`):**
  - Portfolio: `https://<your-username>.github.io/<your-repo>/`
  - Resume Builder App: `https://<your-username>.github.io/<your-repo>/resume-builder/`
  - ATS Resume PDF: `https://<your-username>.github.io/<your-repo>/assets/Rahul_Deore_ATS_Resume.pdf`

---

## Optional: Instant Hosting via Netlify Drop (Zero Setup)

Want a live HTTPS preview URL in under 30 seconds without waiting for GitHub setup?

1. Open [https://app.netlify.com/drop](https://app.netlify.com/drop) in your browser.
2. Drag and drop the `D:\ATS_Resume_Builder\portfolio_website` folder directly onto the page.
3. Netlify immediately publishes the portfolio, the embedded Flutter Web app at `/resume-builder/`, and the downloadable PDF at `/assets/Rahul_Deore_ATS_Resume.pdf`.

For continuous Git-based Netlify hosting, connect your GitHub repository in Netlify — the root `netlify.toml` is already pre-configured with `publish = "portfolio_website"`, security headers, and Flutter Web cache rules.

---

## Optional: Hosting via Firebase Hosting

`firebase.json` is pre-configured to publish `portfolio_website/` with clean URLs, trailing slash handling for `/resume-builder/`, and optimized cache headers:

```powershell
# From D:\ATS_Resume_Builder\
firebase login
firebase use --add
firebase deploy --only hosting
```

---

## Local Regeneration & Preview

To regenerate the ATS PDF and Flutter Web bundle locally before deploying via Netlify Drop or Firebase Hosting:

```powershell
# 1. Regenerate ATS PDF into portfolio_website/assets/
cd D:\ATS_Resume_Builder\ats_resume_builder
flutter test tool/export_ats_pdf.dart

# 2. Rebuild Flutter Web for root-hosted sites (Netlify / Firebase / <user>.github.io)
flutter build web --release --base-href "/resume-builder/"

# 3. Copy build output into portfolio_website/resume-builder/
Remove-Item -Recurse -Force ..\portfolio_website\resume-builder\*
Copy-Item -Recurse -Force build\web\* ..\portfolio_website\resume-builder\

# 4. Preview locally
cd ..\portfolio_website
dart serve.dart
```
