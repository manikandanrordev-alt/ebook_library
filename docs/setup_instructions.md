# Project Setup & Execution Instructions

This document provides step-by-step setup instructions to install and run the Digital Ebook Library on a local machine.

---

## 1. Prerequisites
- **Ruby**: Version `>= 3.2.0` (Verify using `ruby -v`)
- **PostgreSQL**: Relational database service running locally on port `5432`
- **Flutter SDK**: Version `>= 3.12` (Verify using `flutter --version`)
- **Git**: Installed and configured (Verify using `git --version`)

---

## 2. Rails Backend Setup

1. Open your terminal and navigate to the Rails application directory:
   ```bash
   cd backend
   ```
2. Install all required dependencies (Gems) specified in the Gemfile:
   ```bash
   bundle install
   ```
3. Setup environmental variables in `.env` if necessary. Confirm that your local PostgreSQL service is running. Create and migrate databases:
   ```bash
   bin/rails db:create db:migrate
   ```
4. Load the default books to populate your library (Clean Code, Refactoring, The Pragmatic Programmer):
   ```bash
   bin/rails db:seed
   ```
5. Spin up the Rails API server:
   ```bash
   ruby bin/rails server -p 3000
   ```
   *The backend will be live and listening for requests at `http://localhost:3000`.*

---

## 3. Flutter Frontend Setup

1. Open a new terminal session and navigate to the Flutter project directory:
   ```bash
   cd frontend
   ```
2. Fetch the required package dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application in your local Google Chrome browser to view the web build:
   ```bash
   flutter run -d chrome
   ```
   *Or run on target mobile devices using `flutter run`.*
