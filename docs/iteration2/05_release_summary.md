# Release Summary — Iteration 2
## Back2U (CampusFind) | Team [Your Team Number]
### Release Date: [Date] | Sprint Duration: 2 Weeks

---

## Release Overview

Iteration 2 marks the completion of the **core functional flows** of the Back2U app. Building on the foundation established in Iteration 1 (project setup, navigation scaffold, basic auth), this release delivers a fully working lost-and-found reporting and claiming system, end-to-end authentication including forgot password, and in-app messaging for claim communication.

---

## Features Delivered This Iteration

### 1. Complete Authentication System
- **User Registration** — Full form with student ID, institutional email validation, campus, program, password strength enforcement
- **User Login** — JWT-based login; security staff accounts blocked with redirect-to-web-portal message
- **Forgot Password (3-Step OTP Flow)**:
  - Step 1: Email entry with email-not-found warning and "Create Account" shortcut
  - Step 2: 6-digit OTP entry with 90-second server timeout support (Render cold-start)
  - Step 3: New password with enforced rules (min 8 chars, 1 number, 1 special character)
  - Reset token (JWT) passed as `Authorization: Bearer` header on final step

### 2. Report Lost Item
- Multi-field form: title, category, campus, description, location (text + GPS button), date picker, distinctive features, optional photo upload (camera or gallery)
- Client-side and API validation with inline field errors
- On success: navigates to Home screen

### 3. Report Found Item
- Same form as lost report with **photo upload required** (enforced)
- On success: "Thank you for helping" toast; navigates to Home screen

### 4. Browse & Search Items
- Tabbed list: Found Items | Lost Items
- Real-time search bar filtering by title and description
- Category and campus filter chips with bottom-sheet selector
- Error state with **Retry** button on API failure
- Pull-to-refresh

### 5. Item Detail Screen
- Full item view: image, category badge, status badge, location, date, description, distinctive features
- **Found items**: "Claim This Item" button (hidden if already claimed by this user)
- **Owner viewing their own item**: No claim button shown
- Explicit back navigation

### 6. Submit a Claim
- Claim dialog with verification notes (required) and optional verification answer
- On success: UI updates to "View My Claim" button
- Claim Detail Screen with status display and messaging thread (polls every 10 seconds)

### 7. In-App Messaging
- Message thread attached to each claim
- Claimer and item owner can exchange messages
- Real-time polling at 10-second intervals
- Unread message indicator on Profile tab icon

### 8. My Items Screen
- Tabs: Lost Items | Found Items (user's own reports)
- Tap to view, edit status (mark as returned), delete (soft-delete)

### 9. My Claims Screen
- List of all claims the user has submitted
- Tap to view Claim Detail and message thread
- Status chips: Pending / Approved / Rejected

### 10. Notifications
- In-app notification list (new claims, approvals, rejections, messages)
- Unread count badge on bottom nav Profile icon
- Mark as read on tap

### 11. Profile & Settings
- View profile info, edit name/campus/program
- Dark mode toggle
- Links to Privacy Policy and Terms of Service
- Logout with confirmation dialog

---

## Bug Fixes & Improvements

| # | Issue | Fix |
|---|-------|-----|
| 1 | Forgot password timed out on first run | Increased email timeout to 90 s; added loading hint "This may take up to 30 seconds on first launch" |
| 2 | `resetPassword` API sent `new_password` (snake_case) | Fixed to `newPassword` (camelCase) matching backend contract |
| 3 | `verifyOtp` discarded `resetToken` from backend | Now stores token and sends it as `Authorization: Bearer` header in step 3 |
| 4 | OTP validator accepted 4+ digits | Fixed to require exactly 6 digits with regex `^\d{6}$` |
| 5 | Password validator only checked length | Added number and special character checks matching backend `validatePassword()` |
| 6 | Email not found advanced to OTP step | Now detects absence of `info` key in response and shows amber inline warning |
| 7 | No back arrow on several screens | Added explicit back buttons to all pushed screens (report forms, item detail, notifications, claims, settings, legal screens) |
| 8 | Post-success navigation went to wrong screen | Forgot password → `/login`; report items → `/main` using `Get.offAllNamed()` |
| 9 | Browse screen showed blank on API error | Added error state widget with cloud-off icon and Retry button |
| 10 | Backend error `errors[]` array not shown to user | `_getErrorMessage()` now reads and joins the `errors` array with bullet formatting |

---

## Known Limitations / Out of Scope

- **Push notifications** — Currently in-app polling only; Firebase Cloud Messaging deferred to Iteration 3
- **Admin panel** — Web portal for security/admin management not included in mobile app
- **Image compression** — Large images uploaded without client-side compression
- **Offline mode** — No local caching; requires active network connection
- **Pagination** — All items loaded at once; pagination deferred to Iteration 3

---

## Iteration 1 Feedback Incorporated

| Feedback Item | Action Taken |
|---------------|--------------|
| "Add clearer error messages to forms" | Inline field validation errors + `errors[]` array parsing from API |
| "Users need a way to get back to previous screens" | Added back arrows to all navigation screens |
| "Registration flow needs better password guidance" | Added real-time password rules display in step 3 of forgot password and registration |
| "Browse screen should handle network failures gracefully" | Added error state with Retry button |

---

## Testing Summary

| Area | Status |
|------|--------|
| User Registration & Login | ✅ Tested |
| Forgot Password (all 3 steps) | ✅ Tested |
| Report Lost Item (with/without image) | ✅ Tested |
| Report Found Item (image required enforcement) | ✅ Tested |
| Browse + Search + Filters | ✅ Tested |
| Submit Claim + Message Thread | ✅ Tested |
| Notifications + Unread Badge | ✅ Tested |
| My Items + My Claims | ✅ Tested |
| Profile + Settings + Dark Mode | ✅ Tested |
| Error states & retry | ✅ Tested |

---

## Team Members & Contributions

| Name | Role | Key Contributions |
|------|------|-------------------|
| [Member 1] | Full-Stack | Backend API, auth flows, OTP system |
| [Member 2] | Flutter Dev | Report screens, item detail, claim flow |
| [Member 3] | Flutter Dev | Browse screen, filters, messaging UI |
| [Member 4] | Flutter Dev | Profile, notifications, settings, dark mode |

---

*Document prepared by: Team [Number] | Back2U / CampusFind | Iteration 2*
