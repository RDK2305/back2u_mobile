# Iteration 3 — Test Plan and Results
**Project:** Back2U Campus Lost & Found System
**Iteration:** 3
**Test Type:** Manual Functional Testing
**Date:** April 2026

---

## 1. Test Scope

This test plan covers all new features delivered in Iteration 3 across both platforms:
- Web Application (Node.js/Express backend + HTML/JS/Tailwind frontend)
- Flutter Mobile Application (Student-facing)

Previously tested features from Iterations 1 and 2 are assumed stable (regression).

---

## 2. Test Environment

| Item | Web | Mobile |
|---|---|---|
| Backend | Node.js/Express + MySQL | Same backend API |
| Frontend | Chrome / Edge browser | Flutter (Android Emulator / Physical device) |
| Auth | JWT Bearer token | JWT stored in SharedPreferences |
| Test Accounts | 2 student accounts (User A = finder, User B = claimer) | Same accounts |

---

## 3. Test Cases

---

### MODULE 1: Messaging System

#### TC-M-01: View Messages Page (Web)
| Field | Value |
|---|---|
| **Test ID** | TC-M-01 |
| **Feature** | Messages Page — Web |
| **Precondition** | User is logged in; at least one claim exists with messages |
| **Steps** | 1. Click "Messages" in nav → `messages.html` opens<br>2. Observe left panel conversation list<br>3. Click a conversation |
| **Expected** | Left panel shows claim title, other user's name, last message preview, timestamp. Right panel loads full chat thread. |
| **Result** | ✅ PASS |
| **Notes** | Unread conversations show a red dot indicator |

#### TC-M-02: Send a Message (Web)
| Field | Value |
|---|---|
| **Test ID** | TC-M-02 |
| **Feature** | Send Message — Web |
| **Precondition** | A conversation is open |
| **Steps** | 1. Type a message in the text area<br>2. Click "Send" or press Enter |
| **Expected** | Message appears as a blue bubble on the right side; timestamp shown; input field cleared |
| **Result** | ✅ PASS |
| **Notes** | Auto-refresh picks up new messages from the other user within 8 seconds |

#### TC-M-03: XSS Prevention in Messages (Web)
| Field | Value |
|---|---|
| **Test ID** | TC-M-03 |
| **Feature** | Security — Message Content Sanitization |
| **Precondition** | Conversation is open |
| **Steps** | 1. Send a message containing `<script>alert('xss')</script>` |
| **Expected** | Message renders as plain escaped text, no script executes |
| **Result** | ✅ PASS |
| **Notes** | `escapeHtml()` applied to all message content before DOM insertion |

#### TC-M-04: Messages Inbox — Mobile
| Field | Value |
|---|---|
| **Test ID** | TC-M-04 |
| **Feature** | Messages Inbox Screen — Flutter |
| **Precondition** | User logged in with existing claim messages |
| **Steps** | 1. Navigate to Profile → Messages (Quick Actions)<br>2. Observe inbox list |
| **Expected** | Conversations grouped by claim, showing other user's name, item title in blue, last message preview, time ago |
| **Result** | ✅ PASS |
| **Notes** | Unread conversations highlighted with red dot |

#### TC-M-05: Search Conversations — Mobile
| Field | Value |
|---|---|
| **Test ID** | TC-M-05 |
| **Feature** | Search in Messages Inbox — Flutter |
| **Precondition** | Multiple conversations exist |
| **Steps** | 1. Open Messages Inbox<br>2. Type in search bar |
| **Expected** | List filters in real-time by other user's name or item title |
| **Result** | ✅ PASS |

#### TC-M-06: Unread Messages Badge — Mobile
| Field | Value |
|---|---|
| **Test ID** | TC-M-06 |
| **Feature** | Unread Count Badge on Claims Tab |
| **Precondition** | User has unread messages |
| **Steps** | 1. Log in<br>2. Observe bottom navigation bar Claims tab |
| **Expected** | Red badge with count appears on Claims tab icon |
| **Result** | ✅ PASS |
| **Notes** | Badge uses `RxInt` reactive observable, updates on app init |

---

### MODULE 2: Notification Center

#### TC-N-01: View Notifications Page (Web)
| Field | Value |
|---|---|
| **Test ID** | TC-N-01 |
| **Feature** | Notifications Page — Web |
| **Precondition** | User has notifications |
| **Steps** | 1. Click "Notifications" in nav |
| **Expected** | All notifications listed with icon, title, message, relative time |
| **Result** | ✅ PASS |

#### TC-N-02: Filter Notifications (Web)
| Field | Value |
|---|---|
| **Test ID** | TC-N-02 |
| **Feature** | Notification Filters |
| **Steps** | 1. Click "Claims" tab → 2. Click "Messages" tab → 3. Click "System" tab |
| **Expected** | Each tab shows only notifications of that type. "All" shows everything. |
| **Result** | ✅ PASS |

#### TC-N-03: Mark All as Read (Web)
| Field | Value |
|---|---|
| **Test ID** | TC-N-03 |
| **Feature** | Mark All Notifications Read |
| **Steps** | 1. Open Notifications page<br>2. Click "Mark All as Read" |
| **Expected** | All notifications lose unread styling; API call to `PUT /notifications/read-all` succeeds |
| **Result** | ✅ PASS |

#### TC-N-04: Deep-link from Notification (Web)
| Field | Value |
|---|---|
| **Test ID** | TC-N-04 |
| **Feature** | Notification Deep Linking |
| **Steps** | 1. Click on a claim-type notification |
| **Expected** | User is navigated to `my-claims.html?viewClaim=<id>` and the claim modal opens |
| **Result** | ✅ PASS |

---

### MODULE 3: Ratings System

#### TC-R-01: Rate User Button Visible on Eligible Claim (Web)
| Field | Value |
|---|---|
| **Test ID** | TC-R-01 |
| **Feature** | Rate User Button Visibility — Web |
| **Precondition** | User has a claim with status "verified" or "completed" |
| **Steps** | 1. Go to My Claims<br>2. Click on a verified claim |
| **Expected** | "⭐ Rate User" button appears in the claim modal |
| **Result** | ✅ PASS |
| **Notes** | Button does NOT appear on pending or rejected claims |

#### TC-R-02: Submit Rating (Web)
| Field | Value |
|---|---|
| **Test ID** | TC-R-02 |
| **Feature** | Submit Rating — Web |
| **Steps** | 1. Click "⭐ Rate User"<br>2. Select 4 stars<br>3. Enter optional comment<br>4. Click Submit |
| **Expected** | Rating saved via `POST /api/ratings`; success toast shown; modal closes |
| **Result** | ✅ PASS |

#### TC-R-03: Duplicate Rating Check (Web)
| Field | Value |
|---|---|
| **Test ID** | TC-R-03 |
| **Feature** | Existing Rating Detection |
| **Steps** | 1. Open rating modal on a claim that was already rated |
| **Expected** | Modal shows "You previously gave X ⭐. Submitting will update your rating." |
| **Result** | ✅ PASS |

#### TC-R-04: Rate User Bottom Sheet — Mobile
| Field | Value |
|---|---|
| **Test ID** | TC-R-04 |
| **Feature** | Rating Bottom Sheet — Flutter |
| **Precondition** | Claim has status "verified" or "completed" |
| **Steps** | 1. Open claim detail<br>2. Tap ⭐ star icon in AppBar |
| **Expected** | Bottom sheet opens with 5-star GestureDetector row, label ("Excellent" etc.), comment field, disabled submit until a star is selected |
| **Result** | ✅ PASS |

#### TC-R-05: My Ratings Screen — Mobile
| Field | Value |
|---|---|
| **Test ID** | TC-R-05 |
| **Feature** | My Ratings Screen — Flutter |
| **Steps** | 1. Go to Profile<br>2. Tap "See All" on rating card OR tap "My Ratings" quick action |
| **Expected** | Screen shows: gradient summary card with avg score, 5-star breakdown bars, individual review tiles with quoted comments |
| **Result** | ✅ PASS |

#### TC-R-06: Profile Rating Card — Mobile
| Field | Value |
|---|---|
| **Test ID** | TC-R-06 |
| **Feature** | Profile Average Rating Display |
| **Steps** | 1. Log in as user with received ratings<br>2. Open Profile |
| **Expected** | Rating card shows filled/half/empty stars, numeric average, total count |
| **Result** | ✅ PASS |
| **Notes** | Shows "No ratings yet" message if count is 0 |

---

### MODULE 4: Saved Items (Mobile — No API)

#### TC-S-01: Save an Item
| Field | Value |
|---|---|
| **Test ID** | TC-S-01 |
| **Feature** | Bookmark Item — Flutter |
| **Steps** | 1. Open any item from Browse<br>2. Tap bookmark icon (🔖) in AppBar |
| **Expected** | Icon changes from outline to filled; green snackbar "Item added to your saved list" |
| **Result** | ✅ PASS |

#### TC-S-02: Saved State Persists
| Field | Value |
|---|---|
| **Test ID** | TC-S-02 |
| **Feature** | Bookmark Persistence |
| **Steps** | 1. Save an item<br>2. Close the app completely<br>3. Reopen and view item detail |
| **Expected** | Bookmark icon is still filled; item appears in Saved Items screen |
| **Result** | ✅ PASS |
| **Notes** | Uses `SharedPreferences` — survives app restart |

#### TC-S-03: View Saved Items Screen
| Field | Value |
|---|---|
| **Test ID** | TC-S-03 |
| **Feature** | Saved Items List |
| **Steps** | 1. Profile → Quick Actions → "Saved Items" |
| **Expected** | List shows all saved items with title, category icon, location, status dot; swipe-to-remove works |
| **Result** | ✅ PASS |

#### TC-S-04: Remove Item from Saved
| Field | Value |
|---|---|
| **Test ID** | TC-S-04 |
| **Feature** | Unsave Item |
| **Steps** | 1. On Saved Items screen, swipe an item left<br>OR tap the bookmark-remove icon |
| **Expected** | Item disappears from list; snackbar "Item removed from saved" |
| **Result** | ✅ PASS |

#### TC-S-05: Empty State
| Field | Value |
|---|---|
| **Test ID** | TC-S-05 |
| **Feature** | Empty Saved Items State |
| **Steps** | 1. Clear all saved items<br>2. Open Saved Items screen |
| **Expected** | Empty state illustration with "No saved items" text and "Browse Items" button |
| **Result** | ✅ PASS |

---

### MODULE 5: Help & FAQ (Mobile — Fully Offline)

#### TC-H-01: Open Help & FAQ
| Field | Value |
|---|---|
| **Test ID** | TC-H-01 |
| **Feature** | Help & FAQ Screen Access |
| **Steps** | 1. Settings → tap "Help & FAQ" |
| **Expected** | Screen opens with hero banner, How It Works steps, FAQ accordion, Contact section |
| **Result** | ✅ PASS |

#### TC-H-02: Expand FAQ Item
| Field | Value |
|---|---|
| **Test ID** | TC-H-02 |
| **Feature** | FAQ Accordion |
| **Steps** | 1. Tap any FAQ question |
| **Expected** | Answer expands with animation; question text turns blue; icon flips to arrow-up |
| **Result** | ✅ PASS |

#### TC-H-03: Multiple FAQ Items Open
| Field | Value |
|---|---|
| **Test ID** | TC-H-03 |
| **Feature** | Multiple Concurrent Expansions |
| **Steps** | 1. Tap FAQ item #1<br>2. Tap FAQ item #3 without closing #1 |
| **Expected** | Both items can be open simultaneously |
| **Result** | ✅ PASS |

#### TC-H-04: Offline Access
| Field | Value |
|---|---|
| **Test ID** | TC-H-04 |
| **Feature** | No Network Required |
| **Steps** | 1. Disable Wi-Fi and mobile data<br>2. Open Help & FAQ |
| **Expected** | Screen loads instantly with full content — no loading spinner, no error |
| **Result** | ✅ PASS |

---

### MODULE 6: Navigation & Routing

#### TC-NAV-01: All Web Pages Have Messages + Notifications Links
| Field | Value |
|---|---|
| **Test ID** | TC-NAV-01 |
| **Feature** | Web Navigation Consistency |
| **Steps** | Check desktop nav AND mobile hamburger menu on: index.html, dashboard.html, report-lost.html, browse-found.html, my-claims.html, profile.html |
| **Expected** | All 6 pages show "Messages" and "Notifications" in both desktop nav and mobile menu |
| **Result** | ✅ PASS |

#### TC-NAV-02: Mobile Routes Registered
| Field | Value |
|---|---|
| **Test ID** | TC-NAV-02 |
| **Feature** | Flutter Route Registration |
| **Steps** | Navigate to `/messages`, `/my-ratings`, `/saved-items`, `/help-faq` via `Get.toNamed()` |
| **Expected** | Each route loads the correct screen with rightToLeft transition |
| **Result** | ✅ PASS |

#### TC-NAV-03: Profile Quick Actions — Second Row
| Field | Value |
|---|---|
| **Test ID** | TC-NAV-03 |
| **Feature** | Profile Quick Actions Navigation |
| **Steps** | Tap each button in the second quick-actions row: Saved Items, Messages, My Ratings |
| **Expected** | Each navigates to the correct screen |
| **Result** | ✅ PASS |

---

### MODULE 7: Code Quality & Static Analysis

#### TC-Q-01: Flutter Analyze
| Field | Value |
|---|---|
| **Test ID** | TC-Q-01 |
| **Feature** | Static Analysis — Flutter |
| **Steps** | Run `flutter analyze --no-fatal-infos` in project root |
| **Expected** | `No issues found!` |
| **Result** | ✅ PASS — Exit code 0, 0 errors, 0 warnings, 0 info |

---

## 4. Test Summary

| Module | Total TCs | Pass | Fail | Pass Rate |
|---|---|---|---|---|
| Messaging System | 6 | 6 | 0 | 100% |
| Notification Center | 4 | 4 | 0 | 100% |
| Ratings System | 6 | 6 | 0 | 100% |
| Saved Items | 5 | 5 | 0 | 100% |
| Help & FAQ | 4 | 4 | 0 | 100% |
| Navigation & Routing | 3 | 3 | 0 | 100% |
| Code Quality | 1 | 1 | 0 | 100% |
| **TOTAL** | **29** | **29** | **0** | **100%** |

---

## 5. Defects Found and Resolved During Iteration

| # | File | Issue | Fix Applied |
|---|---|---|---|
| 1 | `claim_detail_screen.dart:210` | `unnecessary_non_null_assertion` — `existing!.rating` | Changed to `existing.rating` (inside null-check block) |
| 2 | `claim_detail_screen.dart:284` | `argument_type_not_assignable` — `int?` passed where `int` expected | Applied `rateeId ?? 0` fallback |
| 3 | `messages_inbox_screen.dart:24` | `unused_field` — `_claimProvider` declared but never used | Removed declaration and import |
| 4 | `profile_screen.dart:9` | `unused_import` — `rating.dart` not directly referenced | Removed import |
| 5 | `messages_inbox_screen.dart:233` | `unnecessary_underscores` — `(_, __)` in separatorBuilder | Changed to named params `(context, index)` |
| 6 | `saved_items_screen.dart` | Static helpers on private `_State` class inaccessible externally | Moved `toggleSave`, `isSaved`, `getSavedIds` to public `SavedItemsScreen` widget class |
| 7 | `claim_detail_screen.dart:210` | `invalid_null_aware_operator` — `?.` unnecessary in null-checked scope | Changed back to `existing.rating` |

**All 7 defects resolved. Final `flutter analyze` result: `No issues found!`**

---

*End of Test Plan and Results — Iteration 3*
