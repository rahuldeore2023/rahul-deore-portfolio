# Rahul Deore — Portfolio Website & ATS Resume Builder

Standalone static website combining:
1. **Personal Portfolio Website** (`/`) — Responsive dark/light theme, interactive skill category filters, 7+ YOE timeline, FinoPay & Pidilite EHS projects, copy-to-clipboard contact links, and one-click ATS PDF download.
2. **Downloadable ATS Resume PDF** (`/assets/Rahul_Deore_ATS_Resume.pdf`) — Generated directly from the Flutter `AtsPdfGenerator`.
3. **Production Flutter Web App** (`/resume-builder/`) — Full interactive Riverpod ATS Resume Builder with live ATS scoring and PDF export.

## Preview Locally

Run any static HTTP server inside `D:\ATS_Resume_Builder\portfolio_website`:

```powershell
# Using Python (recommended)
cd D:\ATS_Resume_Builder\portfolio_website
python -m http.server 5000
```

Or with Node.js:
```powershell
npx serve D:\ATS_Resume_Builder\portfolio_website -l 5000
```

Then open:
- Portfolio Website: `http://localhost:5000/`
- Interactive ATS Resume Builder: `http://localhost:5000/resume-builder/`

## Deploy Online (Free Hosting Options)
- **Netlify Drop:** Drag and drop the `D:\ATS_Resume_Builder\portfolio_website` folder directly into https://app.netlify.com/drop
- **Firebase Hosting:** Run `firebase init hosting` with public directory `.` and `firebase deploy`
- **GitHub Pages:** Push the contents of `portfolio_website` to a repository and enable GitHub Pages on `main` (root)
