# User Flow Diagrams — Back2U (CampusFind)
### Iteration 2 | Team [Your Team Number]
---

## Overview

The following diagrams represent the 10 major user flows within the Back2U mobile application. Each flow includes decision points, alternate paths, and system responses.

---

## Use Case 1 — User Registration

```
[START]
    │
    ▼
Open App → Splash Screen (2 s auto-redirect)
    │
    ▼
Login Screen
    │
    └──► Tap "Create Account"
              │
              ▼
         Register Screen
              │
         Fill in form:
         • First Name / Last Name
         • Student ID
         • Email (@conestogac.on.ca)
         • Campus (dropdown)
         • Program
         • Password / Confirm Password
              │
              ▼
         ┌─── Validate form ───┐
         │                     │
       PASS                  FAIL
         │                     │
         ▼                     ▼
    API: POST              Show inline
    /auth/register          field errors
         │                     │
    ┌────┴────┐                 │
  201 Created  4xx Error        │
    │           │               │
    ▼           ▼               │
 Show "Success  Show error      │
 toast, verify  toast, stay ◄───┘
 email"         on screen
    │
    ▼
 Wait 1 s → Navigate to Login Screen
    │
   [END]
```

**Alternate Paths:**
- Student ID already exists → 400 error "Student ID already registered"
- Email already exists → 400 error "Email already in use"
- Password too weak (< 8 chars / no number / no special char) → inline validation error before API call
- Non-Conestoga email → inline error "Must be a @conestogac.on.ca address"

---

## Use Case 2 — User Login

```
[START]
    │
    ▼
Login Screen
    │
    ├── Enter Email + Password
    │
    ▼
Tap "Sign In"
    │
    ▼
┌─── Local Validation ───┐
│                        │
PASS                   FAIL
│                        │
▼                        ▼
API: POST             Show field
/auth/login           errors inline
│
┌──────────────────────────┐
│                          │
200 OK                 401/403 Error
(returns JWT token)        │
│                          ▼
│                     Check role:
│                     • "security" → Show
│                       "Use web portal"
│                       banner, block login
│                     • Other error → toast
│
▼
Save JWT token to
SharedPreferences
│
▼
Navigate to Main Screen
(Home tab)
│
[END]
```

**Alternate Paths:**
- Forgot Password → Tap "Forgot Password?" link → Use Case 3
- No account → Tap "Create Account" → Use Case 1
- Security staff login → Blocked with "Please use the web portal" message

---

## Use Case 3 — Forgot Password (OTP Reset)

```
[START]
    │
    ▼
Login Screen → Tap "Forgot Password?"
    │
    ▼
┌─────────────────────────────────┐
│  STEP 1: Enter Email            │
│  ┌─────────────────────────┐    │
│  │ Email field             │    │
│  └─────────────────────────┘    │
│  Tap "Send OTP"                 │
└─────────────────────────────────┘
    │
    ▼
API: POST /auth/forgot-password
(90 s timeout — Render cold start)
    │
┌───┴───────────────┐
│                   │
Email FOUND      Email NOT FOUND
(has "info" key)  (no "info" key)
│                   │
▼                   ▼
Advance to      Show amber warning
Step 2          banner + "Create
                Account" button
                STOP — stay Step 1
    │
    ▼
┌─────────────────────────────────┐
│  STEP 2: Enter 6-digit OTP      │
│  ┌─────────────────────────┐    │
│  │ OTP field (6 digits)    │    │
│  └─────────────────────────┘    │
│  [Verify OTP] [Resend OTP]      │
└─────────────────────────────────┘
    │
    ▼
API: POST /auth/verify-otp
    │
┌───┴───────────────┐
│                   │
OTP Valid         OTP Invalid/Expired
(returns           │
resetToken JWT)    ▼
│             Show error toast
▼             Stay on Step 2
Store resetToken
Advance to Step 3
    │
    ▼
┌─────────────────────────────────┐
│  STEP 3: Set New Password       │
│  ┌─────────────────────────┐    │
│  │ New Password            │    │
│  │ Confirm Password        │    │
│  └─────────────────────────┘    │
│  Requirements shown:            │
│  • Min 8 characters             │
│  • At least 1 number            │
│  • At least 1 special character │
└─────────────────────────────────┘
    │
    ▼
Client-side validation
    │
    ▼
API: POST /auth/reset-password
{email, otp, newPassword}
+ Authorization: Bearer resetToken
    │
┌───┴───────────────┐
│                   │
200 OK          400 Error
│               (validation
▼               failure with
Show success    errors array)
toast           │
│               ▼
Wait 2 s    Show error toast
│           with each rule
▼           that failed
Navigate to
Login Screen (Get.offAllNamed)
    │
   [END]
```

**Alternate Paths:**
- OTP expired → Re-enter OTP or tap "Resend OTP" → repeats Step 2
- Passwords don't match → inline validation before API call
- Back to Step 1 → tap back arrow

---

## Use Case 4 — Report Lost Item

```
[START]
    │
    ▼
Main Screen (authenticated)
    │
    ├── FAB (+) → "Report Lost Item"
    │   OR
    └── Home → "Lost an Item?" card
    │
    ▼
Report Lost Item Screen
    │
Fill in form:
• Item Title (required)
• Category (dropdown: Wallet, Phone, Keys, etc.)
• Campus (dropdown: Main, Doon, Waterloo, etc.)
• Description (required)
• Location last seen (text / GPS button)
• Date Lost (date picker, default today)
• Distinctive Features (optional)
• Upload Photo (Camera or Gallery — optional)
    │
    ▼
┌─── Validate form ───┐
│                     │
PASS                FAIL
│                     │
▼                     ▼
API: POST          Show inline
/items             field errors
(multipart form    + warning toast
with image)
    │
┌───┴───────────────┐
│                   │
201 Created      Error
│                   │
▼                   ▼
Show success     Show error
toast            toast
    │
Wait 2 s
    │
    ▼
Navigate to
Main Screen (Get.offAllNamed)
    │
   [END]
```

**Alternate Paths:**
- GPS button tapped → device location captured and inserted into location field
- Image upload fails → warning toast, form can still be submitted without photo for lost items

---

## Use Case 5 — Report Found Item

```
[START]
    │
    ▼
Main Screen (authenticated)
    │
    ├── FAB (+) → "Report Found Item"
    │   OR
    └── My Items → Found tab → (+)
    │
    ▼
Report Found Item Screen
    │
Fill in form:
• Item Title (required)
• Category (dropdown)
• Campus (dropdown)
• Description (required)
• Location found (text / GPS button)
• Date Found (date picker, default today)
• Distinctive Features (optional)
• Upload Photo (REQUIRED — Camera or Gallery)
    │
    ▼
┌─── Validate ──────────────────┐
│   Photo attached?              │
│                               │
PASS (image selected)        FAIL (no image)
│                               │
▼                               ▼
API: POST                   Show warning
/items (multipart)          toast: "Photo
                            is required for
                            found items"
    │
┌───┴───────────────┐
│                   │
201 Created      API Error
│                   │
▼                   ▼
Show "Thank you  Show error
for helping!"    toast, stay
toast            on screen
    │
Wait 2 s
    │
    ▼
Navigate to
Main Screen (Get.offAllNamed)
    │
   [END]
```

**Alternate Paths:**
- GPS button tapped → location field auto-filled with coordinates
- Image too large → client-side resize before upload

---

## Use Case 6 — Browse and Search Items

```
[START]
    │
    ▼
Main Screen → Browse tab (bottom nav)
    │
    ▼
Browse Items Screen
(TabBar: Found Items | Lost Items)
    │
    ▼
┌──────────────────────────────────┐
│ Default: All items loaded        │
│ • Search bar                     │
│ • Category filter chip           │
│ • Campus filter chip             │
└──────────────────────────────────┘
    │
    ├── User types in search bar
    │       │
    │       ▼
    │   Real-time local filter
    │   by title + description
    │
    ├── User taps Category chip
    │       │
    │       ▼
    │   Bottom sheet opens
    │   → select category
    │   → list filtered by category
    │
    ├── User taps Campus chip
    │       │
    │       ▼
    │   Bottom sheet opens
    │   → select campus
    │   → list filtered by campus
    │
    ├── User taps "Clear" chip
    │       │
    │       ▼
    │   All filters reset
    │   Full list shown again
    │
    ├── Pull-to-refresh
    │       │
    │       ▼
    │   API: GET /items re-called
    │
    ├── API Error state
    │       │
    │       ▼
    │   Show cloud-off icon + "Retry"
    │   → tap → re-fetch items
    │
    └── Tap item card
            │
            ▼
       Item Detail Screen
       (Use Case 7 continues)
    │
   [END]
```

**Alternate Paths:**
- No results matching filters → empty state with "Clear Filters" button
- No items in database → empty state with different icon per tab
- Network error on load → full-screen error state with Retry button

---

## Use Case 7 — View Item Detail & Submit a Claim

```
[START]
    │
    ▼
Browse Items → Tap Found Item card
    │
    ▼
Item Detail Screen
    │
    ├── View item info:
    │   title, category, campus, date,
    │   location, description, features, photo
    │
    ▼
Check: Is the viewer the item owner?
    │
┌───┴───────────────────┐
│                       │
YES (owner)         NO (other user)
│                       │
▼                       ▼
No claim button    Check: Already claimed
shown              by THIS user?
                       │
               ┌───────┴────────┐
               │                │
              YES               NO
               │                │
               ▼                ▼
          Show "View        Show "Claim
          My Claim"         This Item"
          button            button
               │
               ▼ (tap "Claim This Item")
               │
               ▼
        Claim Dialog opens:
        • Verification Notes textarea
          "Describe proof of ownership"
        • Verification Answer (optional)
              │
              ▼
        Tap "Submit Claim"
              │
              ▼
        API: POST /claims
        {item_id, verification_notes,
         verification_answer}
              │
        ┌─────┴───────────┐
        │                 │
     201 Created        Error
        │                 │
        ▼                 ▼
     Show success     Show error
     toast            toast
     UI updates to    Stay on
     "View My         screen
     Claim" button
              │
              ▼
        Tap "View My Claim"
              │
              ▼
        Claim Detail Screen
        (polling messages every 10 s)
    │
   [END]
```

**Alternate Paths:**
- Lost item detail → no claim button (only found items can be claimed)
- Claim already submitted → "View My Claim" button shown instead of "Claim This Item"

---

## Use Case 8 — Review a Claim (Item Owner — Approve or Reject)

```
[START]
    │
    ▼
Push/In-app notification:
"New claim on your item"
    │
    ▼
Tap notification
OR
My Items → tap found item → View Claims
    │
    ▼
Claims List for this item
• List of all submitted claims
• Each row: claimer name, status, date
    │
    ▼
Tap a claim row
    │
    ▼
Claim Detail Screen (owner view)
• Claimer name + profile
• Verification Notes
• Verification Answer (if provided)
• Current status badge (Pending)
• Message thread
    │
    ▼
┌─── Owner action ──────────────────────────┐
│                                           │
Tap "Approve"                      Tap "Reject"
│                                           │
▼                                           ▼
Confirm dialog:                    Confirm dialog:
"Approve this claim?"              "Reject this claim?"
│                                           │
Confirm                                Confirm
│                                           │
▼                                           ▼
API: PATCH /claims/:id             API: PATCH /claims/:id
{ status: "approved" }             { status: "rejected" }
│                                           │
▼                                           ▼
Item status → "claimed"            Claim marked rejected
│                                           │
▼                                           ▼
Push notification                  Push notification
to claimer:                        to claimer:
"Your claim was approved!"         "Your claim was rejected."
    │
    ▼
UI updates:
• Status badge → Approved / Rejected
• Action buttons hidden
    │
   [END]
```

**Alternate Paths:**
- Owner sends a message before deciding → message thread interaction
- After one claim is approved, remaining pending claims auto-rejected (backend)
- Owner has already approved/rejected → buttons not shown, read-only view

---

## Use Case 9 — View My Items & Update Item Status

```
[START]
    │
    ▼
Bottom Nav → "My Items" tab
    │
    ▼
My Items Screen
(TabBar: Lost Items | Found Items)
    │
    ├── Tab: Lost Items
    │   List of items user reported as lost
    │       │
    │       └── Tap item card
    │               │
    │               ▼
    │          Item Detail Screen (owner)
    │               │
    │          ┌────┴────────────────────┐
    │          │                        │
    │     Tap "Mark              Tap "Delete"
    │     as Returned"                │
    │          │                       ▼
    │          ▼                  Confirm dialog
    │    Confirm dialog           "Delete this
    │    "Item returned?"         report?"
    │          │                       │
    │          ▼                       ▼
    │    API: PATCH              API: DELETE
    │    /items/:id              /items/:id
    │    {status: returned}      (soft delete:
    │          │                  is_active=false)
    │          ▼                       │
    │    Status badge                  ▼
    │    → "returned"            Item removed
    │    Success toast           from list
    │
    ├── Tab: Found Items
    │   List of items user reported as found
    │       │
    │       └── Tap item card
    │               │
    │               ▼
    │          Item Detail (owner view)
    │          Claim count badge shown
    │          → "View Claims" → approve/reject
    │            (Use Case 8)
    │
    └── Pull-to-refresh
            │
            ▼
        Re-fetch items from API
    │
   [END]
```

**Alternate Paths:**
C

---

## Use Case 10 — View Notifications & Mark as Read

```
[START]
    │
    ▼
Main Screen — Profile tab
    │
Unread badge visible on Profile icon
(red dot when unread > 0,
 number badge when active tab)
    │
    ▼
Tap bell icon on Profile screen
OR
Profile → "Notifications" list tile
    │
    ▼
Notifications Screen
    │
    ▼
┌──────────────────────────────────────┐
│  Notifications                       │
│  ────────────────────────────────    │
│  [•] New claim on "Black Wallet"     │
│       2 minutes ago                  │
│  ────────────────────────────────    │
│  [•] Your claim was approved         │
│       "Blue Earbuds" — 1 hour ago    │
│  ────────────────────────────────    │
│  [ ] New message from Alex           │
│       "Keys found at Doon"           │
└──────────────────────────────────────┘
    │
    ├── Tap single notification
    │       │
    │       ▼
    │   API: PATCH /notifications/:id
    │   { is_read: true }
    │       │
    │       ▼
    │   Deep-link to relevant screen:
    │   • "New claim"         → Item Detail
    │   • "Claim approved"    → Claim Detail
    │   • "Claim rejected"    → Claim Detail
    │   • "New message"       → Claim Messages
    │   • "Item matched"      → Found Item Detail
    │
    ├── Tap "Mark all as read"
    │       │
    │       ▼
    │   API: PATCH /notifications/read-all
    │   All marked read
    │   Unread badge disappears
    │
    └── Pull-to-refresh
            │
            ▼
        API: GET /notifications
        Re-fetch notification list
    │
   [END]
```

**Alternate Paths:**
- No notifications → empty state "You're all caught up!"
- Notification for a deleted item → tapping shows "Item no longer available" toast
- Unread count updates via polling every 30 seconds in background

---

*Document prepared by: Team [Number] | Back2U / CampusFind | Iteration 2*
