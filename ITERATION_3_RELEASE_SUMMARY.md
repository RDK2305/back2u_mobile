# Iteration 3 — Release Summary
**Project:** Back2U Campus Lost & Found System
**Iteration:** 3 of 3
**Release Date:** April 2026
**Team Platforms:** Web Application (Node.js/Express) · Mobile App (Flutter/Dart)

---

## 1. Overview

Iteration 3 delivered the **communication, trust, and usability layer** of the Back2U system. Building on the core lost-item reporting and claiming functionality from Iterations 1 and 2, this iteration added real-time messaging between students, a mutual rating system, a full notification center, and several student-experience enhancements (saved items, help center, ratings dashboard). All features were shipped on both the web frontend and the Flutter mobile app.

---

## 2. Features Delivered

### 2.1 Web Application

| Feature | Description | Status |
|---|---|---|
| **Notifications Page** (`notifications.html`) | Full-page notification center with filter tabs (All / Claims / Messages / System), mark-all-as-read, per-notification delete, relative timestamps, deep-link routing to source pages | ✅ Shipped |
| **Messages Page** (`messages.html`) | Two-panel chat interface — left: conversation list grouped by claim with unread red dot; right: threaded chat with date separators, sent (blue) vs received (gray) bubbles, auto-refresh every 8 s, XSS-safe message rendering | ✅ Shipped |
| **Rate User (My Claims)** | "⭐ Rate User" button on verified/completed claims; 5-star interactive picker with hover labels; duplicate-rating check; comment field; submits to `/api/ratings` | ✅ Shipped |
| **Navigation Updates** | Messages + Notifications links added to desktop nav AND mobile menu on all pages: `dashboard.html`, `report-lost.html`, `browse-found.html`, `index.html` | ✅ Shipped |
| **CSS Layer Fix** | Wrapped all custom component CSS in `@layer components` to restore Tailwind v4 cascade order across all pages | ✅ Shipped |

### 2.2 Flutter Mobile App

| Feature | File(s) | Status |
|---|---|---|
| **Messages Inbox Screen** | `messages_inbox_screen.dart` | ✅ Shipped |
| **Unread Messages Badge** | `main_screen.dart` | ✅ Shipped |
| **Rate User (Claim Detail)** | `claim_detail_screen.dart` | ✅ Shipped |
| **Profile Rating Card** | `profile_screen.dart` | ✅ Shipped |
| **My Ratings Screen** | `my_ratings_screen.dart` | ✅ Shipped |
| **Saved Items Screen** | `saved_items_screen.dart` | ✅ Shipped |
| **Help & FAQ Screen** | `help_faq_screen.dart` | ✅ Shipped |
| **Rating + API Models** | `rating.dart`, `api_service.dart` | ✅ Shipped |
| **Route Registration** | `routes.dart` | ✅ Shipped |

---

## 3. Detailed Feature Descriptions

### 3.1 Messaging System (Web + Mobile)

**Web (`messages.html`):**
- Conversations grouped by claim ID; latest message shown as preview
- Determining receiver: if current user is claimer → receiver is owner, and vice versa
- Sends via `POST /api/messages`; auto-refreshes every 8 seconds
- Timestamps formatted as relative time ("2 min ago", "Yesterday")

**Mobile (`MessagesInboxScreen`):**
- Conversation list with avatar initials, other party's name, item title, last message preview
- Unread indicator (red dot) per conversation
- Reactive unread badge on the Claims bottom nav tab using `RxInt`
- Tapping a conversation opens `ClaimDetailScreen` for that claim
- Search bar to filter conversations by name or item title

### 3.2 Ratings System (Web + Mobile)

**Web:**
- ⭐ Rate User button appears on claims with `status = 'verified'` or `'completed'`
- Checks existing rating via `GET /api/ratings/claim/:id` — updates rather than duplicates
- Interactive 5-star picker with label ("Poor" → "Excellent") and optional comment

**Mobile (`ClaimDetailScreen` + `MyRatingsScreen`):**
- Star icon in AppBar for eligible claims → bottom sheet with star picker + comment field
- `MyRatingsScreen` shows: summary gradient card with average, breakdown progress bars (5★–1★), individual review tiles with quoted comments
- Profile screen rating card now shows star row, score, count, and "See All" → `MyRatingsScreen`

### 3.3 Notification Center (Web)

- Filter tabs: All, Claims, Messages, System
- Smart routing: clicking a notification navigates to the relevant claim or message thread
- Mark individual or all as read; delete individual notifications
- `getTimeAgo()` utility for human-readable timestamps

### 3.4 Saved Items (Mobile — No API required)

- Bookmark icon on every `ItemDetailScreen` AppBar — filled when saved, outlined when not
- IDs persisted locally via `SharedPreferences` as JSON list
- `SavedItemsScreen` fetches full item details from existing `/api/items/:id` endpoint
- Swipe-to-dismiss or tap remove icon to unsave; "Clear All" with confirmation dialog
- Fully offline — no login required to save; syncs on load

### 3.5 Help & FAQ (Mobile — Zero API calls)

- Hero banner, 5-step "How It Works" connected timeline
- 12 expandable FAQ accordion cards (animated open/close, color-highlight on open)
- Contact section: email, campus office, office hours
- Works completely offline

---

## 4. API Endpoints Used (Iteration 3)

| Method | Endpoint | Used By |
|---|---|---|
| GET | `/api/messages/inbox` | Messages inbox (web + mobile) |
| POST | `/api/messages` | Send message (web + mobile) |
| GET | `/api/messages/claim/:id` | Claim chat thread (web + mobile) |
| GET | `/api/messages/unread/count` | Unread badge (mobile) |
| GET | `/api/notifications` | Notification center (web) |
| PUT | `/api/notifications/:id/read` | Mark read (web) |
| PUT | `/api/notifications/read-all` | Mark all read (web) |
| DELETE | `/api/notifications/:id` | Delete notification (web) |
| POST | `/api/ratings` | Submit rating (web + mobile) |
| GET | `/api/ratings/user/:id` | My received ratings (mobile) |
| GET | `/api/ratings/user/:id/average` | Average rating (mobile) |
| GET | `/api/ratings/claim/:id` | Check existing rating (web + mobile) |

---

## 5. Code Quality

| Metric | Result |
|---|---|
| `flutter analyze` errors | **0** |
| `flutter analyze` warnings | **0** |
| `flutter analyze` info | **0** |
| XSS protection (web messages) | `escapeHtml()` applied to all message content |
| Null safety | Full sound null safety — all `!` operators justified |
| Type safety | All `int?` → `int` coercions guarded with `?? 0` |

---

## 6. Known Limitations / Out of Scope

- Video/audio calling between students (out of scope)
- Push notifications (FCM) — in-app polling used instead
- Web mobile app (PWA) — separate web and mobile builds

---

## 7. Files Changed — Quick Reference

**Web (campusfind/):**
```
public/notifications.html          ← NEW
public/messages.html                ← NEW
public/javascripts/my-claims.js     ← MODIFIED (ratings added)
public/dashboard.html               ← MODIFIED (nav + CSS fix)
public/report-lost.html             ← MODIFIED (mobile menu)
public/browse-found.html            ← MODIFIED (mobile menu added)
public/index.html                   ← MODIFIED (nav links)
public/stylesheets/style.css        ← MODIFIED (@layer fix)
```

**Mobile (back2u/):**
```
lib/models/rating.dart                      ← NEW
lib/screens/messages_inbox_screen.dart      ← NEW
lib/screens/my_ratings_screen.dart          ← NEW
lib/screens/saved_items_screen.dart         ← NEW
lib/screens/help_faq_screen.dart            ← NEW
lib/services/api_service.dart               ← MODIFIED (6 new methods)
lib/screens/claim_detail_screen.dart        ← MODIFIED (rating sheet)
lib/screens/main_screen.dart                ← MODIFIED (unread badge)
lib/screens/profile_screen.dart             ← MODIFIED (rating card + quick actions)
lib/screens/item_detail_screen.dart         ← MODIFIED (bookmark button)
lib/screens/settings_screen.dart            ← MODIFIED (Help & FAQ link)
lib/config/routes.dart                      ← MODIFIED (3 new routes)
```

---

*End of Release Summary — Iteration 3*
