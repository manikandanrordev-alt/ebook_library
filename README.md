# Digital Ebook Library

An end-to-end, high-performance Digital Ebook Library application built using Ruby on Rails for the backend REST API and Flutter for the cross-platform frontend. The application features a classic wooden bookshelf UI resembling the vintage iOS iBooks experience.

---

## Tech Stack

### Backend
- **Ruby on Rails 8.1**: API-only mode.
- **PostgreSQL**: High-performance relational database.
- **Active Storage**: Handles file uploads and cover image attachments using local storage.
- **Minitest**: Comprehensive controller and model integration tests.

### Frontend
- **Flutter (Dart)**: Modern cross-platform frontend framework.
- **State Management**: Clean state controller using `ChangeNotifier` to decouple UI from API.
- **PDF rendering**: Cross-platform PDF parsing and viewing using the `pdfx` library.

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
4. Create and migrate databases:
   ```bash
   bin/rails db:create db:migrate
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
   flutter run
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
| **GET** | `/api/ebooks` | Fetch all ebooks (supports `q`, `file_type`, `sort_by` query parameters) |
| **GET** | `/api/ebooks/search` | Search ebooks using a `q` keyword |
| **POST** | `/api/ebooks` | Upload a new ebook (multipart data: `file`, `cover_image`, `title`, `author`) |
| **GET** | `/api/ebooks/:id` | Fetch details of a single ebook |
| **GET** | `/api/ebooks/:id/download` | Stream download of the attached ebook file |
| **DELETE** | `/api/ebooks/:id` | Delete an ebook record and its attachments |

---

## AI-Assisted Development & Reflection

In accordance with the product brief, here is a detailed log of the AI collaboration during development:

1. **AI Tools Used**: Antigravity (Advanced Agentic Coding AI).
2. **AI-Assisted Portions**:
   - **Database Configurations**: AI assisted in editing `pg_hba.conf` local rules to bypass database prompt hangs.
   - **Code Cleanups & Comments Removal**: AI assisted in removing comments across files to fit coding rules.
   - **N+1 Queries Resolution**: AI identified Active Storage preloading optimization scopes (`with_attached_file.with_attached_cover_image`).
   - **Tests Implementation**: AI generated the model/integration tests and Flutter widget tests.
3. **Manual Review & Corrected Code**:
   - **FilePicker Refactoring**: The compiler complained about `FilePicker.platform.pickFiles` being missing. AI found that `file_picker` v11.x uses direct static calls `FilePicker.pickFiles()` and refactored the screens accordingly.
   - **Widget Tests Pumping**: AI corrected the `pumpAndSettle` timeout failures by switching to robust `runAsync` microtask delays and mocking the native `path_provider` MethodChannel.
   - **PDF View Callback**: AI fixed the signature for `pageLoaderBuilder` which only takes `BuildContext` rather than `(context, pageIndex)`.

---

## Docker Instructions

The Rails backend is containerized. To build and run it using Docker:

1. Build the Docker image from the `backend/` directory:
   ```bash
   cd backend
   docker build -t ebook-backend .
   ```
2. Run the container:
   ```bash
   docker run -p 3000:3000 ebook-backend
   ```

---

## Manual Testing Checklist

Below is the checklist for verifying the application flows manually:

### 1. Library State Verification
- [ ] **Empty Shelf State**: Clear all books from the library (or verify on clean install) and confirm three empty wooden shelves are drawn with the text "Your library is empty. Tap the button below to upload your first book."
- [ ] **Seeded State**: Run `bin/rails db:seed` and reload the app. Verify that "Clean Code", "The Pragmatic Programmer", and "Refactoring" appear correctly styled as book cards on the wooden shelves.

### 2. Search, Filter & Sort Verification
- [ ] **Debounced Search**: Type "Clean" in the search bar. Verify the list filters automatically to show "Clean Code" or "Clean Architecture" after a ~500ms delay without pressing enter.
- [ ] **File Type Filters**: Toggle the `PDF` choice chip. Verify only PDF files are visible. Toggle `EPUB`. Verify only EPUB files (or empty shelf if none exist) are visible.
- [ ] **Sorting Dropdown**: Change the sort order to "Title (A-Z)". Verify that book cards list alphabetically by title. Change to "Recent". Verify recently uploaded books are first.

### 3. Upload Flow Verification
- [ ] **Form Modal**: Click the Floating Action Button `+`. Verify the bottom sheet slides up cleanly.
- [ ] **Empty Validation**: Click "Upload Book" without selecting a file. Verify a snackbar appears saying "Please select an ebook file."
- [ ] **File Picker**: Select a valid PDF file. Verify the file label updates to show the selected filename.
- [ ] **Successful Upload**: Provide a custom Title and Author, click "Upload Book", and wait. Verify the sheet closes, a success snackbar appears, and the new book is rendered on the shelf.

### 4. Reading, Downloading & Offline Indicators
- [ ] **Download Trigger**: Tap a book card that has a cloud download icon overlay. Verify an alert pops up asking "Would you like to download and read..." Click "Download". Verify the spinner runs and the PDF viewer loads page content.
- [ ] **Offline Indicator**: After reading, return to the shelf. Verify that the cloud download icon is gone, indicating the book is stored locally.
- [ ] **PDF Navigation**: Scroll through the PDF. Verify the page indicators (e.g. `2 / 24`) and next/previous navigation buttons at the bottom work. Pinch-to-zoom and zoom out.

### 5. Deletion Flow Verification
- [ ] **Long Press Sheets**: Long press any book card. Verify a bottom modal option sheet slides up showing option actions.
- [ ] **Confirmation Dialog**: Click "Delete from Library". Verify a dialog pops up asking "Are you sure...". Click "Cancel" and verify the card remains.
- [ ] **Successful Delete**: Repeat, click "Delete", and verify the card is immediately removed from the bookshelf and deleted from the local disk.

---

## Known Limitations
- **EPUB Reader**: Direct EPUB reading in-app is a mockup fallback showing a SnackBar alert (the prompt mentions EPUB reading is optional, PDF reading is the required baseline).
- **Active Storage Disk Storage**: Large files are stored locally on disk under `storage/` directory in development/testing.
