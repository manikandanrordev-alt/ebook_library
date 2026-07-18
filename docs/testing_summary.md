# Testing Summary & Manual Verification Checklist

This document details both automated test coverage outputs and manual user flow testing checklists.

---

## 1. Automated Rails Backend Tests (Minitest)
Tests cover model properties and controller actions (`index`, `show`, `search`, `create`, `download`, `delete`) in the Rails REST API.

**Test Execution Command:**
```bash
cd backend
rails test
```

**Results:**
- **16 tests, 59 assertions passed, 0 failures, 0 errors, 0 skips**.

---

## 2. Automated Flutter Widget Tests (WidgetTester)
Tests cover component rendering, empty states, ebook bookshelves, and long-press deletion sheets in the Flutter frontend.

**Test Execution Command:**
```bash
cd frontend
flutter test
```

**Results:**
- **3 widget tests passed successfully**.

---

## 3. Manual Testing Checklist

Below is the verification checklist for manual validation:

### Library State Verification
- [ ] **Empty Shelf State**: Clear all books from database and confirm empty wooden shelves are drawn with the text "Your library is empty. Tap the button below to upload your first book."
- [ ] **Seeded State**: Run `bin/rails db:seed` and reload. Verify "Clean Code", "The Pragmatic Programmer", and "Refactoring" display as books arranged on the shelves.

### Search, Filter & Sort Verification
- [ ] **Debounced Search**: Type "Pragmatic" in the search bar. Verify results filter to show only "The Pragmatic Programmer" within ~500ms without hitting enter.
- [ ] **File Type Filters**: Toggle the `PDF` choice chip. Verify only PDF files are visible. Toggle `EPUB`. Verify only EPUB files (or empty shelf if none exist) are visible.
- [ ] **Sorting Dropdown**: Change sort order to "Title (A-Z)". Verify that book cards list alphabetically by title. Change to "Recent". Verify recently uploaded books are first.

### Upload Flow Verification
- [ ] **Form Modal**: Click Floating Action Button `+`. Verify the sheet slides up.
- [ ] **Empty Validation**: Click "Upload Book" without selecting a file. Verify a snackbar appears saying "Please select an ebook file."
- [ ] **File Picker**: Select a valid PDF file. Verify file label updates to show selected filename.
- [ ] **Successful Upload**: Provide Title and Author, click "Upload Book". Verify sheet closes, success snackbar appears, and the new book is rendered on the shelf.

### Reading, Downloading & Offline Indicators
- [ ] **Download Trigger**: Tap a book card with a cloud download icon. Verify dialog asks "Would you like to download and read..." Click "Download". Verify spinner runs and PDF viewer loads.
- [ ] **Offline Indicator**: After reading, return to the shelf. Verify the cloud download icon is gone, indicating the book is stored locally.
- [ ] **PDF Navigation**: Scroll through the PDF. Verify page indicators and next/previous navigation buttons at the bottom work. Pinch-to-zoom and zoom out.

### Deletion Flow Verification
- [ ] **Long Press Sheets**: Long press any book card. Verify options sheet slides up.
- [ ] **Confirmation Dialog**: Click "Delete from Library". Verify a dialog pops up asking "Are you sure...". Click "Cancel" and verify the card remains.
- [ ] **Successful Delete**: Repeat, click "Delete", and verify the card is removed from the bookshelf and deleted from the local disk.
