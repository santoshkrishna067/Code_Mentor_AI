# Update 4 - real camera proctoring (face, multiple people, phone, looking away)

## What is new
* **Live camera panel on the exam page** (bottom-right): your camera, a box around your face, a plain-language status line ("Proctoring active", "Face not visible", "More than one person detected", "Phone detected", "Please look at the screen") and a warning counter.
* **Server-side face analysis.** The browser sends one frame per second to the backend, which asks a small Python service (`proctoring-service/`, OpenCV + dlib + YOLO from the proctoring project) what the frame shows. The backend decides what is a warning and records it through the **existing** escalation policy (3 high-severity or 8 total warnings end the attempt). Nothing was changed in that policy.
* **Sustained conditions only.** No face for ~4 s, a second person for ~2 s, a phone for ~2 s, or a head turned away for ~5 s (measured against your own starting position). One warning per type per minute at most. A single flickering frame never counts.
* Laptops, books, monitors and remotes seen in the camera are only **logged** for the reviewer; they never raise a warning.
* If the Python service is not running, the exam continues normally and one "service unavailable" note is logged for the reviewer.

## Bugs fixed on the way
| Problem | Fix |
|---|---|
| The small camera preview on the exam page was always black: the video element did not exist yet when the camera stream was attached | The stream is now attached inside the panel, where the video element lives |
| Turning the camera off, or denying camera access, left no trace | Both now record a HIGH warning for the reviewer |
| The global rate limit (300 requests/minute per IP) would have blocked a classroom on one network once frames flow | Frames have their own per-student limit and are excluded from the per-IP one |

## New / changed files
* `proctoring-service/` (new): `detectors.py`, `server.py`, `live_preview.py`, `requirements.txt`, `copy-models.ps1`, README
* `backend/src/modules/proctoring/`: `proctoring.vision.logic.ts` (rules), `proctoring.vision.service.ts`, `proctoring.vision.schema.ts`, new route `POST /api/proctoring/sessions/:examAttemptId/frame`
* `backend/src/config/env.ts`, `backend/.env.example`, `backend/src/app.ts` (optional settings + rate-limit exemption)
* `backend/tests/proctoringVision.logic.test.ts` (new unit tests, no database needed)
* `frontend/src/components/ProctoringPanel.tsx` (new), `frontend/src/pages/ExamPage.tsx`, `frontend/src/services/proctoring.service.ts`
* `SETUP.ps1`, `START.ps1`, `UPDATE.ps1`: install and start the camera service

## Needs a decision from you
* A student who denies the camera can still continue the exam (as before); they now get a HIGH warning. If you want to block the exam from starting without a camera, say so.
* Thresholds (seconds held, head angles, cooldown) are constants at the top of `proctoring.vision.logic.ts`. Try them with real students before relying on automatic termination.

# Update 3 - remaining admin / learning items completed

## Bugs fixed
| Problem | Fix |
|---|---|
| A lesson whose practice questions were all removed still showed "Start practice" and the page crashed | Empty practice sets are no longer offered; the runner also shows a friendly message if a set is empty |
| Admin's "Explanation" was never shown to students | After submitting a practice set students now get a **Review your answers** section: their answer, the correct answer and the explanation for every question, plus **Try again** |
| "Predict the output" code appeared as plain text; every answer was a big text box | Code is shown in a code block; short answer = one-line box; each question shows what its type means |
| Extra materials (links) were invisible unless the lesson also had notes | Materials show in the Notes tab even when there are no written notes |
| Questions saved with no lesson stayed hidden forever | Question Bank: **Add to a lesson** on every question, a Visible / Hidden filter, and a banner counting hidden questions |
| Admin could not see which lessons still lack content | Manage content: green/grey dots per lesson (video / notes / practice), totals at the top, and "No video / No notes / No practice" filters |
| Unplayable video links were accepted (blank player for students) | Saving is blocked with a clear message unless the link is YouTube, Vimeo, Google Drive or a direct .mp4/.webm file. Direct files also preview |

## Learning content design
* New lesson header, rounded cards, better spacing and typography.
* Code blocks have a language label and a **Copy** button; the Markdown in notes now supports links, quotes and rules too.
* Status badges (green / amber) are readable in dark mode.

## AI chatbot (Mira)
* Already floating, female avatar, same backend/history as the AI Tutor, hidden on exam / assessment / test / quiz pages (and blocked by the server during a live exam).
* Now also tells the tutor which course you are viewing, closes with the Escape key, and its avatar no longer breaks when several copies are on screen.

## Notes
* No database change in this update: no `prisma:push` needed. Just `npm install` (nothing new) and restart.
* New backend endpoint: GET /api/admin/courses/:courseId/content-summary.

# What was fixed / added in this update

## Why "Course not found" appeared on every course
The course page asked the API for `/courses/python-programming` (the slug). The
backend searched `id OR slug`, but on MongoDB the `id` column only accepts a
24-character ObjectId, so a slug made the query fail. **Fixed** in
`backend/src/modules/courses/courses.service.ts`. All 9 courses now open with
their full structure and YouTube videos from the Excel files.

## Fixed
| Problem you reported | Fix |
|---|---|
| Course opens empty / "Course Not Found" | Slug lookup fixed (above) |
| No videos, no topics | Course page now lists every topic (collapsible) and every lesson; lesson page has an NPTEL-style outline sidebar + video player. All 306 YouTube links convert to working embeds (playlist links were broken before) |
| "Mark as Complete" failed on most lessons | Only the first lesson of each topic had content attached; the rest are now completable too |
| Tests / Quizzes / Assessments → 404 | New list pages `/quizzes`, `/tests`, `/assessments` |
| Certificates, Bookmarks, Profile, Notifications → 404 | New pages; Profile has **Log out** and change-password |
| No compiler / no place to write code | Coding page = problem list + VS Code (Monaco) editor + **Run** (with your own input) + **Submit** (graded by hidden test cases) + free **Playground**. Python, JavaScript, Java, C, C++ |
| Practice vs Coding confusion | Practice page now explains the difference |
| Recommendations empty | New students get "Start this course" suggestions automatically |
| Contact form went nowhere | Messages are saved in MongoDB (`contact_messages`), every admin gets a notification, and there is a new **Admin → Messages** inbox with reply-by-email / resolve / delete |
| No admin / how to become admin | `npm run make-admin -- you@example.com` |
| AI Tutor "no reply" | The page now tells you if the AI engine isn't running and how to start it. Works with local Ollama **or** Claude via API key |
| Google login did nothing | Real "Sign in with Google" (needs a Google Client ID — see `.env.example`); the useless GitHub button was removed |
| Admin sidebar had 9 dead links | Trimmed to pages that exist |

## Still needs content from you (not code)
* **Quizzes, tests, assessments, assignments, exams** need questions. The Excel
  files only contain video links, so nothing was invented. Add them from the
  admin pages (Question Bank, Exams) — the student pages are ready to show them.
* **Notes** per lesson are likewise not in the Excel files.

## After copying these files, run once (in `backend`)
```
npm install
npm run prisma:generate
npm run prisma:push        # adds the new collections: contact_messages, bookmarks
npm run seed:courses       # safe to re-run
npm run seed:coding        # 11 starter coding problems
npm run dev
```
Frontend: `npm install` then `npm run dev`.
`frontend/.env` must have `VITE_API_URL=http://localhost:4000/api` (note the `/api`).

## Honest limits
* The local code runner uses the compilers on your computer. Install Python,
  Node, a JDK and gcc/g++ (MinGW on Windows) and make sure they are on PATH.
  It is NOT a sandbox — for a public website switch to Judge0.
* The AI Tutor needs either Ollama running with a model pulled, or an
  `ANTHROPIC_API_KEY`.
* I could type-check and build both apps and test the code runner and video-link
  converter, but I could not connect to your MongoDB Atlas from here, so the
  database-backed flows were not exercised end to end.

## Hotfix
- Fixed "progressBySubtopic?.get is not a function" on course pages (courses.service.ts: .map passed the index as the progress map).

## Admin & learning upgrade
- Question Bank: guided 3-step builder (Multiple choice / Short answer / Predict the output), choose the lesson students will see it in; every question shows "Visible to students" or "Hidden".
- Courses > "Manage content": one page per course to replace a lesson's video link, notes (+code examples), practice questions and extra material links.
- Videos are links only (YouTube, Vimeo, Google Drive, direct .mp4) - replacing swaps the link, nothing is stored in MongoDB.
- Lesson page redesigned (typography, cards, code blocks) with a softer dark theme (sun/moon button in the top bar).
- Floating AI tutor "Mira" (same backend and history as the AI Tutor page); hidden on exam/assessment/test/quiz pages.
- Practice tab has a multi-language code editor (Python, JavaScript, Java, C, C++, SQL).
- Optional: seed:content script reads data/content/*.json for bulk lesson notes + practice questions. That folder is NOT included in this zip; without it, add content from Admin -> Courses -> Manage content.
