# Digital Ebook Library

An end-to-end, high-performance Digital Ebook Library application built using Ruby on Rails for the backend REST API and Flutter for the cross-platform frontend. The application features a classic wooden bookshelf UI resembling the vintage iOS iBooks experience, with full EPUB and PDF reading support, last-read-position tracking, and a deployable Docker setup.

---

## ✨ Features

| Feature | Status |
| :--- | :---: |
| Bookshelf-style UI (iOS iBooks-inspired wooden shelves) | ✅ |
| Ebook cover generation / preview (colour-coded per book) | ✅ |
| EPUB support (custom paginated text reader) | ✅ |
| PDF support (full pdfx-powered in-app reader) | ✅ |
| **Last read position** (per-book, persisted via SharedPreferences) | ✅ |
| Sorting (Recent / Title A-Z / Title Z-A / Author A-Z) | ✅ |
| Filtering (All / PDF / EPUB chips) | ✅ |
| Search (debounced live search by title, author, filename) | ✅ |
| Upload (PDF + EPUB with optional cover image) | ✅ |
| Download (browser blob-URL download, native file save) | ✅ |
| Delete (confirmation dialog, clean UI feedback) | ✅ |
| Responsive layout (adaptive 3-column bookshelf grid) | ✅ |
| Clean animations (book open/press, shelf transitions) | ✅ |
| Flutter Web support (runs in browser at localhost:5000) | ✅ |
| Docker setup (docker-compose with PostgreSQL + Rails) | ✅ |
| Seed / demo data (20 PDFs + 3 EPUBs auto-seeded) | ✅ |
| Good documentation (README + docs/ folder) | ✅ |

---

## Tech Stack

### Backend
- **Ruby on Rails 8.1** — API-only mode.
- **PostgreSQL** — High-performance relational database.
- **Active Storage** — Handles file uploads and cover image attachments using local disk storage.
- **Minitest** — Comprehensive controller and model integration tests.

### Frontend
- **Flutter (Dart)** — Modern cross-platform frontend (Web, Android, iOS, Desktop).
- **State Management** — Clean `ChangeNotifier` controller to decouple UI from API.
- **PDF rendering** — Cross-platform PDF parsing and viewing using the `pdfx` library.
- **EPUB rendering** — Custom paginated text reader with font-size controls and progress bar.
- **SharedPreferences** — Persistent last-read-page tracking per book.

---

## Setup & Running Instructions

### Prerequisites
- Ruby (>= 3.2.0)
- PostgreSQL
- Flutter SDK (>= 3.12)
- Git

---

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Install Ruby gems:
   ```bash
   bundle install
   ```
3. Configure environment variables in `.env` (copy from `.env.example` if needed). Ensure your PostgreSQL credentials are correct:
   ```env
   DATABASE_USERNAME=postgres
   DATABASE_PASSWORD=yourpassword
   DATABASE_HOST=127.0.0.1
   DATABASE_PORT=5432
   ```
4. Create, migrate and seed the database:
   ```bash
   bin/rails db:create db:migrate db:seed
   ```
5. Run the Rails server:
   ```bash
   bin/rails server -p 3000
   ```
   *The backend will be live at `http://localhost:3000`.*

---

### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the Flutter application on your desired device/platform:
   ```bash
   # Web (recommended for quick preview)
   flutter run -d chrome --web-port 5000

   # Native (Android/iOS/Desktop)
   flutter run
   ```

---

## 🐳 Docker Setup (Full Stack)

Start the entire backend + database with a single command from the project root:

```bash
docker-compose up --build
```

This will:
1. Start a **PostgreSQL 16** database container.
2. Build and start the **Rails backend** container.
3. Automatically run `db:create`, `db:migrate`, and `db:seed` on first run.
4. Expose the API at **`http://localhost:3000`**.

> **Tip:** The Flutter frontend still runs locally via `flutter run`. Point it at `http://localhost:3000`.

To stop:
```bash
docker-compose down
```

To stop and remove all data volumes:
```bash
docker-compose down -v
```

---

## Running Tests

### Backend Tests
Execute Minitests for models and controllers inside the `backend` folder:
```bash
cd backend
bin/rails test
```

### Frontend Tests
Execute Flutter widget tests inside the `frontend` folder:
```bash
cd frontend
flutter test
```

---

## API Overview

All API endpoints are prefixed with `/api`.

| HTTP Method | Endpoint | Description |
| :--- | :--- | :--- |
| **GET** | `/api/ebooks` | Fetch all ebooks (supports `q`, `file_type`, `sort_by` query params) |
| **GET** | `/api/ebooks/search` | Search ebooks using a `q` keyword |
| **POST** | `/api/ebooks` | Upload a new ebook (multipart: `file`, `cover_image`, `title`, `author`) |
| **GET** | `/api/ebooks/:id` | Fetch details of a single ebook |
| **GET** | `/api/ebooks/:id/download` | Stream download of the attached ebook file |
| **DELETE** | `/api/ebooks/:id` | Delete an ebook record and all its attachments |

---

## 📖 Last Read Position

When you open a PDF or EPUB book:
- The reader automatically **resumes from where you left off**.
- Your last-read page is saved locally using **SharedPreferences** (keyed by book ID).
- The app bar shows a subtle **"Last read: page X"** label when reopening a book mid-way.
- The EPUB reader also shows a **progress bar** at the top indicating how far through the book you are.

---

## AI-Assisted Development & Reflection

In accordance with the product brief, here is a detailed log of the AI collaboration during development:

1. **AI Tools Used**: Antigravity (Advanced Agentic Coding AI by Google DeepMind).
2. **AI-Assisted Portions**:
   - **Database Configurations**: AI assisted in editing `pg_hba.conf` local rules to bypass database prompt hangs.
   - **Code Cleanups & Comments Removal**: AI assisted in removing comments across files to fit coding rules.
   - **N+1 Queries Resolution**: AI identified Active Storage preloading optimization scopes (`with_attached_file.with_attached_cover_image`).
   - **Tests Implementation**: AI generated the model/integration tests and Flutter widget tests.
   - **Web Compatibility**: AI added `kIsWeb` guards, replaced `path_provider` with in-memory byte fetching for browsers, and implemented dart:html Blob-URL downloads.
   - **Last Read Position**: AI implemented SharedPreferences-based page tracking for both PDF and EPUB readers.
3. **Manual Review & Corrected Code**:
   - **FilePicker Refactoring**: The compiler complained about `FilePicker.platform.pickFiles` being missing. AI found that `file_picker` v11.x uses direct static calls `FilePicker.pickFiles()` and refactored the screens accordingly.
   - **Widget Tests Pumping**: AI corrected the `pumpAndSettle` timeout failures by switching to robust `runAsync` microtask delays and mocking the native `path_provider` MethodChannel.
   - **Dialog Context Fix**: AI fixed a "deactivated widget ancestor" crash on delete by saving `ScaffoldMessenger` reference before dialog dismissal.

---

## Docker Instructions (Manual)

The Rails backend has an individual `Dockerfile`. To build it standalone:

1. Build the Docker image from the `backend/` directory:
   ```bash
   cd backend
   docker build -t ebook-backend .
   ```
2. Run the container (requires an external Postgres instance):
   ```bash
   docker run -p 3000:3000 \
     -e DATABASE_URL=postgres://user:pass@host/db \
     ebook-backend
   ```

For the full stack with database, use `docker-compose up` from the project root (recommended).

---

## Manual Testing Checklist

### 1. Library State Verification
- [ ] **Empty Shelf State**: Clear all books from the library and confirm three empty wooden shelves are drawn with the text "Your library is empty. Tap the button below to upload your first book."
- [ ] **Seeded State**: Run `bin/rails db:seed` and reload the app. Verify 20 PDF books and 3 EPUB books appear correctly styled on the wooden shelves.

### 2. Search, Filter & Sort Verification
- [ ] **Debounced Search**: Type "PDF Book 1" in the search bar. Verify the list filters automatically after a ~500ms delay.
- [ ] **File Type Filters**: Toggle the `PDF` chip (brown bg, white text → active: white bg, brown text). Verify only PDF files are visible. Toggle `EPUB` to see only EPUB books.
- [ ] **Sorting Dropdown**: Change the sort order to "Title (A-Z)". Verify alphabetical ordering. Change to "Recent". Verify recently uploaded books are first.

### 3. Upload Flow Verification
- [ ] **Form Modal**: Click the Floating Action Button `+`. Verify the bottom sheet slides up cleanly.
- [ ] **Empty Validation**: Click "Upload Book" without selecting a file. Verify a snackbar appears saying "Please select an ebook file."
- [ ] **Successful Upload**: Select a valid PDF/EPUB, provide title and author, click "Upload Book". Verify success snackbar and new book on shelf.

### 4. Reading, Last Read Position & Download
- [ ] **Open PDF**: Long press a PDF book → "Read Now". Verify PDF reader opens and shows page navigation.
- [ ] **Last Read Position (PDF)**: Navigate to page 2 in the PDF reader. Go back and re-open the same book. Verify it reopens on page 2 with "Last read: page 2" shown in the app bar.
- [ ] **Open EPUB**: Long press an EPUB book → "Read Now". Verify EPUB reader opens with paginated text and progress bar.
- [ ] **Last Read Position (EPUB)**: Go to next page in EPUB. Close and reopen. Verify it resumes at the saved page.
- [ ] **Download File**: Long press any book → "Download File". Verify the browser opens a native save-file dialog.

### 5. Deletion Flow Verification
- [ ] **Long Press Sheet**: Long press any book card. Verify a bottom modal option sheet slides up.
- [ ] **Confirmation Dialog**: Click "Delete from Library". Verify a confirmation dialog appears.
- [ ] **Successful Delete**: Click "Delete" and verify the card is removed from the shelf with a green "Ebook deleted successfully." snackbar (no error message).

---

## Known Limitations
- **EPUB Parsing**: Real EPUB ZIP archives are detected but parsed as plain text. A production implementation would use a full EPUB XML parser.
- **Active Storage Disk**: Large files are stored locally under `storage/` in development. Switch to S3 or GCS for production deployments.
- **Web Offline**: The "Download Offline" option is hidden on web (browsers manage their own file system).
