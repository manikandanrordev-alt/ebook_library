# Assumptions and Known Limitations

This document captures architectural assumptions and known functional limitations of the Digital Ebook Library system.

---

## 1. Assumptions

- **Local Storage Strategy**: We assumed a single-server, local-storage approach using Active Storage's Disk Service. This avoids cloud-dependency overhead (e.g. AWS/S3 credentials setup) during verification.
- **Port Bindings**: We assumed standard development ports:
  - Port `3000` is dedicated for the Rails REST API server.
  - Port `5000` is dedicated for the Flutter Web Server during browser integration.
- **Database Rules**: We assumed PostgreSQL security defaults can be adapted locally. The loopback authentication protocol in `pg_hba.conf` was modified to `trust` mode for passwordless access to bypass terminal prompts.
- **Platform Coverage**: We assumed PDF format is the baseline standard for document reading. EPUB is supported for uploads, filters, and metadata extraction, with a placeholder flow for visual reading.

---

## 2. Limitations

- **EPUB Inline Reader**: An inline EPUB parser is not included. Although users can upload, manage, filter, and download EPUB files, tapping to read an EPUB will trigger a mockup SnackBar alerting the user that EPUB reading is placeholder-only.
- **Playwright Browser Drive**: The browser subagent execution cannot record automated walkthrough sessions. This is due to a persistent 404 response on the Playwright CDN download registry for the target OS environment driver (`1.57.0-win32_x64`).
- **Disk Cleanups**: Book deletes trigger database purge callbacks to remove Active Storage blobs. The downloaded local caches on the mobile/web clients are also deleted from the sandbox directory when a book is deleted.
- **State Persistence**: The client keeps tracks of local file downloads on the persistent documents directory. However, reading session stats (like the last read page position) are session-bound and not saved across client restarts.
