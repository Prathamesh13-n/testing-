# SmartResumeAI — Project Guide

> **Build smarter resumes. Match better jobs. Get interview-ready.**

SmartResumeAI is a full-stack resume workspace for writing resumes, reviewing resume content, and comparing a resume with a specific job posting. It is built as a major-project learning application with a transparent, testable ATS-style estimate—not an integration with or score from a commercial Applicant Tracking System (ATS).

## Table of contents

- [Project at a glance](#project-at-a-glance)
- [What the application does](#what-the-application-does)
- [Technology](#technology)
- [Requirements](#requirements)
- [Quick start on Windows](#quick-start-on-windows)
- [Environment configuration](#environment-configuration)
- [First run checklist](#first-run-checklist)
- [How to use the application](#how-to-use-the-application)
- [How the ATS-style estimate works](#how-the-ats-style-estimate-works)
- [Backend API reference](#backend-api-reference)
- [Project structure](#project-structure)
- [Database and migrations](#database-and-migrations)
- [Tests and quality checks](#tests-and-quality-checks)
- [Security and privacy](#security-and-privacy)
- [Troubleshooting](#troubleshooting)
- [Known limitations and roadmap](#known-limitations-and-roadmap)
- [More manuals](#more-manuals)

## Project at a glance

| Item | Details |
|---|---|
| Audience | Students, recent graduates, job seekers, and professionals |
| Frontend | React, Vite, Tailwind CSS v4, React Router |
| API | Python, FastAPI, Pydantic |
| Database | SQLite locally; PostgreSQL supported through SQLAlchemy |
| ORM and migrations | SQLAlchemy and Alembic |
| Resume formats | PDF and DOCX text extraction |
| AI provider | Google Gemini, optional and called from the backend only |
| Authentication | Argon2 password hashes and signed bearer JWTs |
| Local frontend | `http://localhost:5173` |
| Local API | `http://127.0.0.1:8000` |
| API reference | `http://127.0.0.1:8000/docs` |

## What the application does

- Registers and signs in users, protects workspace screens, and keeps resume data scoped to its owner.
- Lets users create, edit, save, and delete resume drafts.
- Parses PDF and DOCX documents in memory and shows extracted text for review.
- Scores visible resume sections with a rule-based 100-point checklist.
- Compares a saved resume with a pasted job description using an explainable ATS-style rubric.
- Offers AI rewrite suggestions if a Gemini key is configured; the user reviews and accepts, edits, or rejects them.
- Shows saved resumes and analysis history in the dashboard and history screen.
- Previews resumes using two layouts and offers browser print-to-PDF.

Scores are guidance for users and a demonstrable project feature. They are not hiring predictions, proof of qualifications, or official vendor scores.

## Technology

### Frontend

- React and React Router
- Vite development server and production bundler
- Tailwind CSS v4 via `@tailwindcss/vite`
- Inter variable font
- Browser Fetch API for backend requests

### Backend

- FastAPI and Pydantic v2
- SQLAlchemy ORM and Alembic migrations
- SQLite for a no-service local setup; PostgreSQL via Psycopg for deployments
- Argon2 password hashing and `python-jose` JWT signing
- PyMuPDF for PDF extraction and `python-docx` for DOCX extraction
- Google Gen AI Python SDK for optional Gemini text rewriting
- Pytest and FastAPI's test client

## Requirements

The current project has been verified in this workspace with **Python 3.14.6**, **Node.js 24.19.0**, and **npm 11.17.0**. Install a supported Python and Node.js release if those runtimes are not available on your machine.

- Git (optional, for version control)
- Windows PowerShell for the commands in this guide
- No PostgreSQL server is required for the default SQLite development setup.
- A Google Gemini API key is optional. Only the improvement feature requires it.

## Quick start on Windows

Open **two PowerShell terminals** in VS Code. Keep each server terminal open while you use the app.

### 1. Start the backend

In the first terminal:

```powershell
cd D:\personal_project\SmartResumeAI\backend
.\.venv\Scripts\Activate.ps1
python -m alembic upgrade head
python -m uvicorn app.main:app --reload
```

Activation assumes the project's virtual environment already exists. If it does not, create it and install dependencies first:

```powershell
cd D:\personal_project\SmartResumeAI\backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
```

Create `backend\.env` from the example only if the file does not already exist. Preserve your existing `.env` and secret:

```powershell
cd D:\personal_project\SmartResumeAI\backend
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
```

Set `JWT_SECRET` in `.env` to a private random value with at least 32 characters. To generate a value, run this from an activated backend environment:

```powershell
python -c "import secrets; print(secrets.token_urlsafe(48))"
```

Paste the generated value after `JWT_SECRET=` in `backend\.env`. Do not share it. The API configuration resolves this `.env` file relative to the backend source, so it can find the settings even if Uvicorn is launched from the repository root.

Confirm the API is alive:

- Health check: <http://127.0.0.1:8000/health>
- Interactive API documentation: <http://127.0.0.1:8000/docs>

The health check should return JSON containing `"status": "ok"`.

### 2. Start the frontend

In the second terminal:

```powershell
cd D:\personal_project\SmartResumeAI\frontend
npm install
if (-not (Test-Path .env.local)) { Copy-Item .env.example .env.local }
npm run dev
```

Open <http://localhost:5173>. Vite normally reloads code changes automatically. Stop a server with **Ctrl+C** in its terminal.

## Environment configuration

### Backend: `backend\.env`

`backend\.env.example` lists the available settings. Keep actual credentials in the ignored `.env` file; never copy real values into source code or commit them.

| Variable | Required | Purpose |
|---|---:|---|
| `APP_NAME` | No | API title |
| `ENVIRONMENT` | No | Environment label |
| `DATABASE_URL` | No | Database connection; defaults to a local SQLite database |
| `JWT_SECRET` | Yes for account registration/login | Private signing secret; use a random value of at least 32 characters |
| `JWT_ALGORITHM` | No | JWT signing algorithm; default is `HS256` |
| `JWT_EXPIRE_MINUTES` | No | Access-token lifetime; default is 60 minutes |
| `GEMINI_API_KEY` | No | Enables AI rewriting when configured |
| `GEMINI_MODEL` | No | Gemini model name; default is `gemini-2.5-flash` |
| `CORS_ORIGINS` | No | Comma-separated allowed browser origins |
| `MAX_UPLOAD_MB` | No | Upload size limit; default is 5 MB |
| `MAX_JOB_DESCRIPTION_CHARS` | No | Intended job description character limit |
| `MAX_RESUME_CHARS` | No | Intended resume text character limit |

The default `DATABASE_URL=sqlite:///./smartresume.db` stores the development database in the backend working directory. PostgreSQL URLs should use the Psycopg driver, for example:

```text
postgresql+psycopg://username:password@localhost:5432/smartresume
```

If a database password contains reserved URL characters, URL-encode them in the connection string.

### Frontend: `frontend\.env.local`

| Variable | Default | Purpose |
|---|---|---|
| `VITE_API_URL` | `http://127.0.0.1:8000` | Public base URL used by the browser to call the API |

Anything with a `VITE_` prefix is bundled for browser access. Never put passwords, JWT secrets, database URLs, or Gemini keys in frontend environment variables.

## First run checklist

1. Confirm `backend\.env` exists and has a private `JWT_SECRET` of 32 or more characters.
2. Confirm you started the backend and see Uvicorn's “running on” message.
3. Open `/health` and verify `"status": "ok"`.
4. Confirm Alembic migrations completed without an error.
5. Start Vite and open <http://localhost:5173>.
6. Create an account with a valid email address and a password of at least 10 characters.
7. Create a resume from the builder or upload a PDF/DOCX.
8. Use **Save and analyze** or the upload-review flow.
9. Select a saved resume and paste a complete job description on the job-match screen.
10. Optionally add a Gemini key to try AI rewrite suggestions.

## How to use the application

### Create an account or log in

Register with a name, valid email, and a password of 10–128 characters. Use the show-password checkbox if you need to verify your entry. The account screens keep the short-lived access token in browser `sessionStorage`.

### Build a resume

1. Open **Create Resume**.
2. Fill in contact details, summary, skills, experience, education, and projects.
3. Check the live preview and select the Classic or Modern template.
4. Select **Save resume** to store a draft, or **Save and analyze** to also save a resume checklist analysis.
5. Choose **Export PDF** or **Print / save PDF**, then select **Save as PDF** in the browser print dialog.

Experience, education, and projects accept plain text; use separate lines to make entries readable. The current editor is intentionally simple and does not provide a separate form row for each employer or degree.

### Upload and analyze a resume

1. Open **Analyze Resume**.
2. Select a text-based PDF or DOCX up to 5 MB.
3. Review the extracted text and fields; correct parsing mistakes before saving.
4. Select **Save and analyze**.
5. Review the score breakdown and recommendations.

The upload itself is processed in memory and discarded. If you choose to save it, the extracted resume text and structured fields are stored in the account database.

### Compare a resume to a job

1. Save a resume first.
2. Open **Job Match** and choose the resume.
3. Paste at least 100 characters from the role description (maximum 12,000).
4. Review the ATS-style estimate, its rubric, recognized matching terms, and missing terms.
5. Treat missing skills as possible learning goals, not details to claim unless they are true.

The current keyword vocabulary is finite and primarily English. A keyword match only means text was found, not that the applicant has the skill or experience.

### Improve wording with AI

1. Configure `GEMINI_API_KEY` in `backend\.env`, then restart the backend.
2. Open **Improve**, choose a saved resume, and paste the exact bullet or summary to review.
3. Inspect the original and suggested wording side by side.
4. Edit the suggestion if needed, then accept, save your edit, reject, or regenerate.

When accepted text exactly matches content in the saved resume, that text is replaced there. Otherwise, the action is recorded but the suggestion is not inserted into a resume. Verify that every AI-suggested fact is accurate.

### View and delete saved data

- **Dashboard** shows resume and analysis counts, recent resumes, and recent analysis entries.
- **History** displays saved resumes and the full analysis breakdown; it can delete a resume or analysis.
- Deleting a resume also deletes analyses, matches, and rewrite suggestions associated with it.
- **Profile and settings** allows changing the account display name.

## How the ATS-style estimate works

### The important distinction

There is **no single universal ATS score**. ATS vendors use different products, parsers, configurations, and proprietary ranking logic. SmartResumeAI does not connect to Workday, Greenhouse, Lever, or another vendor and cannot return that vendor’s official score.

The app instead calculates a **transparent, ATS-style job-fit estimate out of 100** for a saved resume and the job description entered by the user. It is an educational heuristic, not a prediction of interviews, screening outcomes, or hiring decisions.

### Scoring rubric

| Category | Base weight | What is compared |
|---|---:|---|
| Required skill coverage | 55 points | Recognized technical and transferable skills not identified as preferred |
| Preferred skill coverage | 15 points | Recognized skills near preference wording such as “preferred,” “bonus,” or “nice to have” |
| Relevant keyword coverage | 20 points | Recognized role, domain, and qualification terms from an expanded built-in vocabulary |
| Resume section readability | 10 points | Presence of common contact, summary, skills, experience, and education/project sections |

If no terms are found in a category, its base weight is redistributed proportionally across categories that can be assessed. This makes the available category maximums sum to 100. The response includes each category’s score, maximum, and explanation; category scores add up to the displayed total.

### What a match means

- Matching is based on normalized phrase/word boundaries, common separators, and simple plural handling.
- The entire saved text (structured fields and extracted text) is searched.
- A listed skill or keyword is a text-presence signal. The current version does not use a semantic model to judge context, recency, proficiency, or evidence.
- It does not evaluate visual layout, PDF reading order, columns, tables, graphics, or vendor-specific parsers.
- Unsupported terms may not be recognized. Scores may differ from scores produced by real employers’ ATS configurations.
- Never add a keyword, achievement, metric, qualification, or skill to a resume unless it accurately describes you.

### Improving the project for a major-project evaluation

To make the score more defensible as a research/engineering feature:

1. Document this rubric and add unit tests for every category and edge case.
2. Version each rubric so historical scores remain explainable after changes.
3. Build a labeled evaluation set of sample resumes and job descriptions, and report precision/recall or ranking agreement—do not claim vendor equivalence without authorized comparative data.
4. Add synonym and phrase normalization with an auditable mapping, rather than silently expanding the vocabulary.
5. Separate parser-quality, formatting, skills, and job-relevance signals in the UI.
6. Evaluate against real ATS vendor behaviour only when the vendor authorizes access and provides a documented API or test procedure.

## Backend API reference

All protected routes require:

```text
Authorization: Bearer <access_token>
```

FastAPI validates request and response data and exposes interactive examples at `/docs`.

| Method | Path | Purpose | Authentication |
|---|---|---|---|
| `GET` | `/health` | Service health check | No |
| `POST` | `/auth/register` | Register and receive an access token | No |
| `POST` | `/auth/login` | Sign in and receive an access token | No |
| `GET` | `/auth/me` | Read current user profile | Yes |
| `PATCH` | `/auth/me` | Update profile name | Yes |
| `POST` | `/resumes/parse` | Parse PDF/DOCX in memory for review | Yes |
| `GET` | `/resumes` | List current user’s resumes | Yes |
| `POST` | `/resumes` | Save a resume | Yes |
| `GET` | `/resumes/{resume_id}` | Get an owned resume | Yes |
| `PUT` | `/resumes/{resume_id}` | Update an owned resume | Yes |
| `DELETE` | `/resumes/{resume_id}` | Delete an owned resume and related data | Yes |
| `POST` | `/resumes/{resume_id}/analyze` | Create and save a rule-based resume analysis | Yes |
| `GET` | `/analyses` | List current user’s analyses | Yes |
| `GET` | `/analyses/{analysis_id}` | Get an owned analysis | Yes |
| `DELETE` | `/analyses/{analysis_id}` | Delete an owned analysis | Yes |
| `POST` | `/matches` | Calculate and save ATS-style job fit | Yes |
| `POST` | `/resumes/{resume_id}/improvements` | Request and save a Gemini rewrite suggestion | Yes |
| `PATCH` | `/improvements/{suggestion_id}` | Accept, edit, or reject an owned suggestion | Yes |
| `GET` | `/dashboard` | Get current user's dashboard summary | Yes |
| `GET` | `/history` | Get current user's saved resumes and analyses | Yes |

Resume JSON uses a `title`, a `content` object (contact details, summary, skills, experience, education, projects), and optional `raw_text`. Use Swagger UI at <http://127.0.0.1:8000/docs> to inspect exact request and response shapes.

## Project structure

```text
SmartResumeAI/
├── .gitignore
├── README.md
├── .vscode/
│   ├── extensions.json
│   └── settings.json
├── backend/
│   ├── .env.example
│   ├── alembic.ini
│   ├── requirements.txt
│   ├── migrations/
│   │   ├── env.py
│   │   └── versions/
│   ├── app/
│   │   ├── core/       # Configuration, auth dependencies, password/JWT helpers
│   │   ├── db/         # SQLAlchemy base, engine, database sessions
│   │   ├── models/     # Users, resumes, analyses, matches, suggestions
│   │   ├── routers/    # HTTP endpoints
│   │   ├── schemas/    # Pydantic request/response validation
│   │   └── services/   # Parsing, scoring, matching, AI provider
│   └── tests/
└── frontend/
    ├── .env.example
    ├── package.json
    └── src/
        ├── components/ # Shared navigation, access checks, form feedback, UI
        ├── context/    # Browser session authentication state
        ├── layouts/
        ├── pages/      # Landing, account, dashboard, resume workflows
        ├── services/   # API client
        └── utils/
```

## Database and migrations

The default SQLite database is created locally and ignored by Git. Schema changes are tracked in Alembic migrations.

From `D:\personal_project\SmartResumeAI\backend` with the virtual environment active:

```powershell
python -m alembic current
python -m alembic history
python -m alembic upgrade head
```

Create a migration after changing SQLAlchemy models:

```powershell
python -m alembic revision --autogenerate -m "describe the schema change"
```

Review the generated migration before applying it with `python -m alembic upgrade head`. Do not delete the database to work around migration errors; inspect the error and migration state first.

## Tests and quality checks

### Backend

From the `backend` folder:

```powershell
.\.venv\Scripts\python.exe -m pytest -q
.\.venv\Scripts\python.exe -m pip check
```

The tests cover health, registration/login, duplicate accounts, protected access, owner isolation, resume analysis, matching and rubric arithmetic, DOCX parsing, upload validation, and safe behaviour when Gemini is not configured.

### Frontend

From the `frontend` folder:

```powershell
npm run lint
npm run build
```

The project currently provides lint/build checks but does not yet have a separate automated frontend component test suite.

## Security and privacy

- Passwords are stored as Argon2 hashes, not plaintext.
- Access tokens are short-lived JWTs. The browser stores a token in `sessionStorage` and removes it on logout.
- Session storage reduces persistence compared with local storage, but same-origin script execution/XSS can still expose a token. Use HTTPS in production and prevent injection bugs.
- Backend routes scope resumes, analyses, and suggestions to the authenticated owner; another user's record returns not found.
- Uploads are allow-listed by extension/signature, limited in size, and parsed in memory. Uploaded file bytes are discarded after parsing.
- Resume text you choose to save is persisted in the configured database.
- When Gemini rewriting is configured and used, submitted text is sent to Google's Gemini service. Review the provider's current data terms before using real personal data.
- CORS is configured with an origin allow-list. Production must list the actual frontend URL.
- Keep `backend\.env` private. Never publish `.env` files, API keys, database passwords, JWT secrets, or real resume data.
- Rotate a secret if it has been exposed. Do not copy secret values into bug reports, screenshots, source code, or chat messages.

## Troubleshooting

### `JWT_SECRET must be configured with at least 32 characters`

1. Confirm `D:\personal_project\SmartResumeAI\backend\.env` exists (the name must be `.env`, not `.env.txt`).
2. Set `JWT_SECRET` to a private value of 32 or more characters. Generate one with:

   ```powershell
   cd D:\personal_project\SmartResumeAI\backend
   .\.venv\Scripts\Activate.ps1
   python -c "import secrets; print(secrets.token_urlsafe(48))"
   ```

3. Save `.env`, stop Uvicorn with **Ctrl+C**, then restart it.
4. Do not paste the secret into chat or commit it.

### `Could not connect to the API`

- Check the backend terminal is still running.
- Visit <http://127.0.0.1:8000/health>.
- Confirm `VITE_API_URL` in `frontend\.env.local` is correct.
- Restart Vite after changing `.env.local`.

### CORS error in the browser

- Check `CORS_ORIGINS` in `backend\.env` includes the exact frontend origin, such as `http://localhost:5173`.
- Protocol, hostname, and port must match. `localhost` and `127.0.0.1` are different origins.
- Restart the backend after changing the setting.

### Registration returns 422 or 409

- Use a syntactically valid email address.
- Password must be at least 10 characters and no more than 128.
- 409 means the email is already registered; use the login screen or another email.
- Check that migrations have run successfully.

### Resume upload says the file is unreadable

- Confirm the document is a genuine PDF or DOCX and is no larger than 5 MB.
- Image-only/scanned PDFs have no extractable text; use a text-based document.
- The parser does not perform OCR and extraction may need manual corrections.

### AI improvement says it is unavailable

- Add a valid `GEMINI_API_KEY` to `backend\.env`.
- Restart the backend.
- Check that the selected Gemini model is available to your API account and that quota/network access is available.
- Do not add the key to frontend environment files.

### PowerShell refuses to activate `.venv`

Use the virtual-environment interpreter directly instead:

```powershell
cd D:\personal_project\SmartResumeAI\backend
.\.venv\Scripts\python.exe -m uvicorn app.main:app --reload
```

If your machine permits scripts and you choose to change the policy, follow your organization's Windows security guidance.

## Known limitations and roadmap

Current limitations:

- **No official ATS integration or official vendor score.** Current job matching is a rule-based estimate.
- Skill/role keyword vocabulary is finite. Synonyms, context, nuanced qualifications, and different languages are not comprehensively interpreted.
- Presence of a word is not proof of proficiency or evidence that a resume meets a requirement.
- Section readability is a rough signal; actual parser compatibility and layout are not inspected.
- PDF/DOCX parsing does not support OCR for scanned image documents.
- AI rewriting requires a Gemini API key and a working provider account/quota.
- PDF export relies on browser print-to-PDF rather than a dedicated server PDF renderer.
- No password reset, account deletion, refresh token, or login rate-limiting workflow.
- Deployment is not included or verified. It requires hosting, production configuration, and a production database.

Possible future work:

- Add versioned scoring rubrics, qualification extraction, phrase/synonym handling, and contextual evidence matching.
- Create an anonymized and labeled evaluation dataset; report reproducible metrics and limitations.
- Add automated frontend tests and accessibility/browser tests.
- Add email verification, password reset, account deletion, and rate limits.
- Add OCR and a dedicated PDF export pipeline.
- Add a documented, authorized ATS-vendor integration only if a vendor provides suitable API access.

## More manuals

- [Backend setup and API guide](./backend/README.md)
- [Frontend development and UI guide](./frontend/README.md)
