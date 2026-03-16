# Storyboard Diagrams — Back2U (CampusFind)
### Iteration 2 | Team [Your Team Number]

> Each storyboard shows the sequence of screens a user sees when completing a use case, with descriptions of key UI elements, user actions, and system responses on each screen.

---

## Use Case 1 — User Registration

**Screen 1 — Splash Screen**
```
┌─────────────────────────┐
│                         │
│                         │
│        [LOGO]           │
│       Back2U            │
│  CampusFind             │
│                         │
│   ████████████████      │
│   Loading...            │
│                         │
└─────────────────────────┘
```
*Action: App launches. Logo and loading bar shown for 2 seconds. Auto-redirects to Login Screen.*

---

**Screen 2 — Login Screen (entry point)**
```
┌─────────────────────────┐
│       Back2U            │
│  Lost & Found           │
├─────────────────────────┤
│ Email                   │
│ ┌─────────────────────┐ │
│ │ student@conestoga.. │ │
│ └─────────────────────┘ │
│ Password                │
│ ┌─────────────────────┐ │
│ │ ••••••••            │ │
│ └─────────────────────┘ │
│ [        Sign In      ] │
│                         │
│  Don't have an account? │
│  [   Create Account   ] │◄── User taps here
│ Forgot Password?        │
└─────────────────────────┘
```
*Action: User taps "Create Account".*

---

**Screen 3 — Register Screen**
```
┌─────────────────────────┐
│ ← Register              │
├─────────────────────────┤
│ First Name    Last Name │
│ ┌──────────┐ ┌────────┐ │
│ │ John     │ │ Doe    │ │
│ └──────────┘ └────────┘ │
│ Student ID              │
│ ┌─────────────────────┐ │
│ │ 8881234             │ │
│ └─────────────────────┘ │
│ Email                   │
│ ┌─────────────────────┐ │
│ │ jdoe@conestogac...  │ │
│ └─────────────────────┘ │
│ Campus       Program    │
│ ┌──────────┐ ┌────────┐ │
│ │ Doon   ▼│ │ Comp.  │ │
│ └──────────┘ └────────┘ │
│ Password                │
│ ┌─────────────────────┐ │
│ │ ••••••••            │ │
│ └─────────────────────┘ │
│ Confirm Password        │
│ ┌─────────────────────┐ │
│ │ ••••••••            │ │
│ └─────────────────────┘ │
│ [      Register       ] │
└─────────────────────────┘
```
*Action: User fills in all fields and taps "Register".*

---

**Screen 4 — Success Toast → Redirects to Login**
```
┌─────────────────────────┐
│ ← Register              │
├─────────────────────────┤
│  ... (form fields) ...  │
│                         │
│ ┌─────────────────────┐ │
│ │ ✓ Account created!  │ │
│ │   Please verify     │ │
│ │   your email.       │ │
│ └─────────────────────┘ │
│                         │
└─────────────────────────┘
```
*System: Shows success toast. After 1 second, navigates to Login Screen.*

---

## Use Case 2 — User Login

**Screen 1 — Login Screen**
```
┌─────────────────────────┐
│       Back2U            │
│  Lost & Found           │
├─────────────────────────┤
│ Email                   │
│ ┌─────────────────────┐ │
│ │ jdoe@conestogac...  │ │
│ └─────────────────────┘ │
│ Password                │
│ ┌─────────────────────┐ │
│ │ ••••••••            │ │
│ └─────────────────────┘ │
│ [        Sign In      ] │◄── User taps
│                         │
│  Don't have an account? │
│  [   Create Account   ] │
│ Forgot Password?        │
└─────────────────────────┘
```
*Action: User enters email and password, taps "Sign In".*

---

**Screen 2a — Login Success → Home Screen**
```
┌─────────────────────────┐
│  Back2U          🔔     │
├─────────────────────────┤
│  Good morning, John! 👋 │
│                         │
│ ┌─────────┐ ┌─────────┐ │
│ │ 📦 Lost │ │ 🔍Found │ │
│ │   12    │ │   8     │ │
│ └─────────┘ └─────────┘ │
│                         │
│  Recent Found Items     │
│ ┌─────────────────────┐ │
│ │ 👜 Black Wallet     │ │
│ │ Doon Campus · 2h    │ │
│ └─────────────────────┘ │
├─────────────────────────┤
│ 🏠  🔍  📦  📋  👤     │
└─────────────────────────┘
```
*System: JWT saved. User lands on Home tab.*

---

**Screen 2b — Security Role Blocked**
```
┌─────────────────────────┐
│       Back2U            │
├─────────────────────────┤
│  ┌───────────────────┐  │
│  │ ⚠  Security Staff │  │
│  │                   │  │
│  │ Please use the    │  │
│  │ web portal to     │  │
│  │ access your       │  │
│  │ account.          │  │
│  │                   │  │
│  │ portal.back2u.ca  │  │
│  └───────────────────┘  │
└─────────────────────────┘
```
*System: Security role users are blocked from the mobile app.*

---

## Use Case 3 — Forgot Password (OTP Reset)

**Screen 1 — Step 1: Enter Email**
```
┌─────────────────────────┐
│ ← Reset Password        │
├─────────────────────────┤
│  Step 1 of 3            │
│  ●────────────────      │
│                         │
│  Enter your             │
│  institutional email    │
│                         │
│ ┌─────────────────────┐ │
│ │ jdoe@conestogac...  │ │
│ └─────────────────────┘ │
│                         │
│ [      Send OTP       ] │
│                         │
│ ⓘ This may take up to  │
│   30 seconds on first   │
│   launch                │
└─────────────────────────┘
```

---

**Screen 2 — Email Not Found Warning**
```
┌─────────────────────────┐
│ ← Reset Password        │
├─────────────────────────┤
│  Step 1 of 3            │
│  ●────────────────      │
│                         │
│ ┌─────────────────────┐ │
│ │ ⚠  No account found │ │
│ │ for this email.     │ │
│ │                     │ │
│ │ [  Create Account ] │ │
│ └─────────────────────┘ │
│                         │
│ ┌─────────────────────┐ │
│ │ unknown@email.com   │ │
│ └─────────────────────┘ │
│                         │
│ [      Send OTP       ] │
└─────────────────────────┘
```
*System: Amber warning shown. User cannot proceed. "Create Account" button navigates to Register.*

---

**Screen 3 — Step 2: Enter OTP**
```
┌─────────────────────────┐
│ ← Reset Password        │
├─────────────────────────┤
│  Step 2 of 3            │
│  ●●───────────────      │
│                         │
│  Enter the 6-digit OTP  │
│  sent to your email     │
│                         │
│ ┌─────────────────────┐ │
│ │  4  8  2  7  1  9   │ │
│ └─────────────────────┘ │
│                         │
│ [      Verify OTP     ] │
│ [      Resend OTP     ] │
└─────────────────────────┘
```

---

**Screen 4 — Step 3: New Password**
```
┌─────────────────────────┐
│ ← Reset Password        │
├─────────────────────────┤
│  Step 3 of 3            │
│  ●●●──────────────      │
│                         │
│  ┌───────────────────┐  │
│  │ ✓ Min 8 chars     │  │
│  │ ✓ One number      │  │
│  │ ✓ One special chr │  │
│  └───────────────────┘  │
│                         │
│ New Password            │
│ ┌─────────────────────┐ │
│ │ ••••••••••          │ │
│ └─────────────────────┘ │
│ Confirm Password        │
│ ┌─────────────────────┐ │
│ │ ••••••••••          │ │
│ └─────────────────────┘ │
│ [   Reset Password    ] │
└─────────────────────────┘
```
*Action: User sets new password and submits. Navigates to Login Screen.*

---

## Use Case 4 — Report Lost Item

**Screen 1 — Action Sheet (FAB)**
```
┌─────────────────────────┐
│  Back2U          🔔     │
├─────────────────────────┤
│  (home content)         │
│                      [+]│
│                         │
│ ╔═════════════════════╗ │
│ ║ What would you do?  ║ │
│ ╠═════════════════════╣ │
│ ║ 🔴 Report Lost Item ║◄│── User taps
│ ║   I lost something  ║ │
│ ╠═════════════════════╣ │
│ ║ 🟢 Report Found     ║ │
│ ║   I found something ║ │
│ ╚═════════════════════╝ │
└─────────────────────────┘
```

---

**Screen 2 — Report Lost Item Form**
```
┌─────────────────────────┐
│ ← Report Lost Item      │
├─────────────────────────┤
│ Item Title *            │
│ ┌─────────────────────┐ │
│ │ Black Leather Wallet│ │
│ └─────────────────────┘ │
│ Category *   Campus *   │
│ ┌──────────┐ ┌────────┐ │
│ │ Wallet ▼│ │ Doon ▼ │ │
│ └──────────┘ └────────┘ │
│ Description *           │
│ ┌─────────────────────┐ │
│ │ Lost near Library.. │ │
│ └─────────────────────┘ │
│ Location Last Seen      │
│ ┌──────────────┐ [GPS] │ │
│ │ Library 2F   │       │ │
│ └──────────────┘       │ │
│ Date Lost   [📅 Today] │ │
│ Distinctive Features    │
│ ┌─────────────────────┐ │
│ │ Blue stitching...   │ │
│ └─────────────────────┘ │
│ Photo (optional)        │
│ ┌────────┐ ┌─────────┐  │
│ │📷 Cam │ │🖼 Gallery│  │
│ └────────┘ └─────────┘  │
│ [     Submit Report   ] │
└─────────────────────────┘
```

---

**Screen 3 — Success**
```
┌─────────────────────────┐
│ ← Report Lost Item      │
├─────────────────────────┤
│                         │
│  ┌───────────────────┐  │
│  │ ✓ Report submitted│  │
│  │ We hope it gets   │  │
│  │ found soon!       │  │
│  └───────────────────┘  │
│                         │
└─────────────────────────┘
```
*System: Success toast shown. After 2 seconds, navigates to Home screen.*

---

## Use Case 5 — Report Found Item

**Screen 1 — Report Found Item Form**
```
┌─────────────────────────┐
│ ← Report Found Item     │
├─────────────────────────┤
│ Item Title *            │
│ ┌─────────────────────┐ │
│ │ Set of Keys         │ │
│ └─────────────────────┘ │
│ Category *   Campus *   │
│ ┌──────────┐ ┌────────┐ │
│ │ Keys   ▼│ │ Main ▼ │ │
│ └──────────┘ └────────┘ │
│ Description *           │
│ ┌─────────────────────┐ │
│ │ Found on cafeteria..│ │
│ └─────────────────────┘ │
│ Location Found          │
│ ┌──────────────┐ [GPS] │ │
│ │ Cafeteria    │       │ │
│ └──────────────┘       │ │
│ Photo (REQUIRED) *      │
│ ┌─────────────────────┐ │
│ │  [📷 Take Photo]    │ │
│ │  [🖼  From Gallery] │ │
│ └─────────────────────┘ │
│ [     Submit Report   ] │
└─────────────────────────┘
```

---

**Screen 2 — Photo Validation Error**
```
┌─────────────────────────┐
│ ← Report Found Item     │
├─────────────────────────┤
│ ... (form fields) ...   │
│                         │
│ ┌─────────────────────┐ │
│ │ ⚠  Photo is required│ │
│ │ for found items     │ │
│ └─────────────────────┘ │
│                         │
│ [     Submit Report   ] │
└─────────────────────────┘
```
*System: Warning toast shown if user taps Submit without a photo.*

---

**Screen 3 — Success**
```
┌─────────────────────────┐
│ ← Report Found Item     │
├─────────────────────────┤
│  ┌───────────────────┐  │
│  │ 🙏 Thank you for  │  │
│  │    helping!       │  │
│  │ Your report has   │  │
│  │ been submitted.   │  │
│  └───────────────────┘  │
└─────────────────────────┘
```
*System: Navigates to Home screen after 2 seconds.*

---

## Use Case 6 — Browse and Search Items

**Screen 1 — Browse Screen (default)**
```
┌─────────────────────────┐
│  Browse Items     ← ✕  │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │🔍 Search items...   │ │
│ └─────────────────────┘ │
│ [Category▼] [Campus▼]  │
├─────────┬───────────────┤
│Found(8) │  Lost(12)     │
├─────────┴───────────────┤
│ ┌─────────────────────┐ │
│ │[img] Black Wallet   │ │
│ │      Wallet · Open  │ │
│ │      Doon Campus    │ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │[img] Blue Earbuds   │ │
│ │      Electronics    │ │
│ │      Main Campus    │ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │[img] Set of Keys    │ │
│ │      Keys · Open    │ │
│ │      Waterloo       │ │
│ └─────────────────────┘ │
├─────────────────────────┤
│ 🏠  🔍  📦  📋  👤     │
└─────────────────────────┘
```

---

**Screen 2 — Search Active**
```
┌─────────────────────────┐
│  Browse Items           │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │🔍 wallet          ✕ │ │
│ └─────────────────────┘ │
│ [Category▼] [Campus▼]  │
├─────────┬───────────────┤
│Found(2) │  Lost(1)      │
├─────────┴───────────────┤
│ ┌─────────────────────┐ │
│ │[img] Black Wallet   │ │
│ │      Wallet · Open  │ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │[img] Brown Purse    │ │
│ │      Wallet · Open  │ │
│ └─────────────────────┘ │
└─────────────────────────┘
```

---

**Screen 3 — Error State (Network)**
```
┌─────────────────────────┐
│  Browse Items           │
├─────────────────────────┤
│         ☁✕             │
│                         │
│   Unable to load items  │
│   Check your connection │
│                         │
│   [  🔄 Retry  ]        │
└─────────────────────────┘
```
*Action: User taps Retry → re-fetches items.*

---

## Use Case 7 — View Item Detail & Submit a Claim

**Screen 1 — Item Detail (Found Item)**
```
┌─────────────────────────┐
│ ←  Item Detail          │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │                     │ │
│ │   [ITEM PHOTO]      │ │
│ │                     │ │
│ └─────────────────────┘ │
│  [Wallet] [Open]        │
│  Black Leather Wallet   │
│                         │
│  📍 Doon — Library 2F   │
│  📅 March 10, 2026      │
│                         │
│  Description            │
│  Found on table near    │
│  the water fountain...  │
│                         │
│  Distinctive Features   │
│  Blue stitching on edge │
│                         │
│ [    Claim This Item  ] │
└─────────────────────────┘
```

---

**Screen 2 — Claim Dialog**
```
┌─────────────────────────┐
│  Claim This Item        │
├─────────────────────────┤
│  Describe your proof of │
│  ownership:             │
│ ┌─────────────────────┐ │
│ │ It has my student   │ │
│ │ card inside and a   │ │
│ │ blue keychain...    │ │
│ └─────────────────────┘ │
│                         │
│  Verification Answer    │
│  (optional)             │
│ ┌─────────────────────┐ │
│ │ Black with blue     │ │
│ └─────────────────────┘ │
│                         │
│ [Cancel] [Submit Claim] │
└─────────────────────────┘
```

---

**Screen 3 — After Claim Submitted**
```
┌─────────────────────────┐
│ ←  Item Detail          │
├─────────────────────────┤
│  ... (item details) ... │
│                         │
│  ┌───────────────────┐  │
│  │ ✓ Claim submitted!│  │
│  └───────────────────┘  │
│                         │
│ [    View My Claim    ] │
└─────────────────────────┘
```
*System: "Claim This Item" button replaced with "View My Claim".*

---

## Use Case 8 — Review a Claim (Item Owner)

**Screen 1 — My Items → Item with Claims**
```
┌─────────────────────────┐
│ ←  My Items             │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │[img] Black Wallet   │ │
│ │      Wallet · Open  │ │
│ │      3 claims       │ │◄── tap
│ └─────────────────────┘ │
└─────────────────────────┘
```

---

**Screen 2 — Claims List**
```
┌─────────────────────────┐
│ ←  Claims (3)           │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │ 👤 Alex Johnson     │ │
│ │    [Pending] Mar 10 │ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │ 👤 Maria Singh      │ │
│ │    [Pending] Mar 11 │ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │ 👤 Jake Brown       │ │
│ │    [Pending] Mar 12 │ │
│ └─────────────────────┘ │
└─────────────────────────┘
```

---

**Screen 3 — Claim Detail (Owner View)**
```
┌─────────────────────────┐
│ ←  Claim Detail         │
├─────────────────────────┤
│  Alex Johnson           │
│  Submitted: Mar 10      │
│  Status: [Pending]      │
│                         │
│  Verification Notes:    │
│  "It has my student     │
│   card inside and a     │
│   blue keychain..."     │
│                         │
│  Verification Answer:   │
│  "Black with blue edge" │
├─────────────────────────┤
│  Messages               │
│  ─────────────────────  │
│  [No messages yet]      │
│  ┌─────────────────────┐│
│  │ Type a message...   ││
│  └─────────────────────┘│
├─────────────────────────┤
│ [ Reject ] [ Approve ]  │
└─────────────────────────┘
```

---

**Screen 4 — After Approval**
```
┌─────────────────────────┐
│ ←  Claim Detail         │
├─────────────────────────┤
│  Alex Johnson           │
│  Status: [Approved ✓]   │
│                         │
│  ┌───────────────────┐  │
│  │ ✓ Claim approved! │  │
│  │ Alex was notified │  │
│  └───────────────────┘  │
│                         │
│  (Action buttons hidden)│
└─────────────────────────┘
```

---

## Use Case 9 — View My Items & Update Status

**Screen 1 — My Items Screen**
```
┌─────────────────────────┐
│  My Items         [+]   │
├─────────┬───────────────┤
│ Lost(3) │  Found(2)     │
├─────────┴───────────────┤
│ ┌─────────────────────┐ │
│ │[img] Black Wallet   │ │
│ │      Lost · Open    │ │
│ │      Doon · Mar 5   │ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │[img] Blue Jacket    │ │
│ │      Lost · Open    │ │
│ │      Main · Mar 8   │ │
│ └─────────────────────┘ │
├─────────────────────────┤
│ 🏠  🔍  📦  📋  👤     │
└─────────────────────────┘
```

---

**Screen 2 — Item Detail (Owner — Lost Item)**
```
┌─────────────────────────┐
│ ←  Item Detail          │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │   [ITEM PHOTO]      │ │
│ └─────────────────────┘ │
│  [Lost] [Open]          │
│  Black Wallet           │
│  📍 Doon — Library      │
│  📅 March 5, 2026       │
│                         │
│  Description ...        │
│                         │
│ ┌─────────────────────┐ │
│ │ [Mark as Returned]  │ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │   [Delete Report]   │ │
│ └─────────────────────┘ │
└─────────────────────────┘
```

---

**Screen 3 — Mark as Returned Confirmation**
```
┌─────────────────────────┐
│  Confirm                │
├─────────────────────────┤
│                         │
│  Mark "Black Wallet"    │
│  as returned?           │
│                         │
│  This means the item    │
│  has been reunited      │
│  with its owner.        │
│                         │
│ [   Cancel   ] [  OK  ] │
└─────────────────────────┘
```

---

**Screen 4 — Updated Status Badge**
```
┌─────────────────────────┐
│ ←  Item Detail          │
├─────────────────────────┤
│  [Lost] [Returned ✓]    │
│  Black Wallet           │
│                         │
│  ┌───────────────────┐  │
│  │ ✓ Marked returned │  │
│  └───────────────────┘  │
│                         │
│  (Action buttons hidden)│
└─────────────────────────┘
```

---

## Use Case 10 — View Notifications & Mark as Read

**Screen 1 — Profile Screen with Badge**
```
┌─────────────────────────┐
│  Profile       🔔(3)    │◄── badge
├─────────────────────────┤
│  👤  John Doe           │
│      Doon · Comp. Prog  │
│                         │
│  ─────────────────────  │
│  🔔 Notifications  (3)  │◄── tap
│  📦 My Reports          │
│  📋 My Claims           │
│  ⚙  Settings           │
│  🚪 Logout              │
└─────────────────────────┘
```

---

**Screen 2 — Notifications Screen**
```
┌─────────────────────────┐
│ ←  Notifications    ✓✓ │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │🔴 New claim on your │ │
│ │   "Black Wallet"    │ │
│ │   2 minutes ago     │ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │🔴 Claim approved ✓  │ │
│ │   "Blue Earbuds"    │ │
│ │   1 hour ago        │ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │⬜ New message from  │ │
│ │   Alex — "Keys..."  │ │
│ │   Yesterday         │ │
│ └─────────────────────┘ │
└─────────────────────────┘
```
*Action: Tapping a notification marks it as read and deep-links to the relevant screen.*

---

**Screen 3 — Empty Notifications**
```
┌─────────────────────────┐
│ ←  Notifications        │
├─────────────────────────┤
│                         │
│         🔔              │
│                         │
│   You're all caught up! │
│   No new notifications  │
│                         │
└─────────────────────────┘
```

---

## Use Case 11 — In-App Messaging (Claim Thread)

**Screen 1 — Claim Detail with Messages**
```
┌─────────────────────────┐
│ ←  Claim Detail         │
├─────────────────────────┤
│  Black Wallet           │
│  Claimer: Alex Johnson  │
│  Status: [Pending]      │
├─────────────────────────┤
│  Messages               │
│  ─────────────────────  │
│             ┌─────────┐ │
│  Mar 10     │ Is your │ │
│  You      → │ wallet  │ │
│             │ black?  │ │
│             └─────────┘ │
│  ┌────────────┐         │
│  │ Yes, black │ Mar 10  │
│  │ leather    │ Alex    │
│  └────────────┘         │
│             ┌─────────┐ │
│  Mar 11   → │ What's  │ │
│  You        │ inside? │ │
│             └─────────┘ │
│  ─────────────────────  │
│ ┌──────────────────┐[→]│ │
│ │ Type a message...│   │ │
│ └──────────────────┘   │ │
└─────────────────────────┘
```
*Action: User types a message and taps send (→). Screen polls for new messages every 10 seconds.*

---

**Screen 2 — Message Sent**
```
┌─────────────────────────┐
│ ←  Claim Detail         │
├─────────────────────────┤
│  Messages               │
│  ─────────────────────  │
│             ┌─────────┐ │
│             │ Is your │ │
│             │ wallet  │ │
│             │ black?  │ │
│             └─────────┘ │
│  ┌────────────┐         │
│  │ Yes, black │         │
│  │ leather    │         │
│  └────────────┘         │
│             ┌─────────┐ │
│             │ What's  │ │
│             │ inside? │ │
│             └─────────┘ │
│  ┌──────────────────┐   │
│  │ My student card  │   │
│  │ and transit pass │ ✓ │◄── just sent
│  └──────────────────┘   │
│ ┌──────────────────┐[→]│ │
│ │ Type a message...│   │ │
│ └──────────────────┘   │ │
└─────────────────────────┘
```

---

## Use Case 12 — Edit Profile

**Screen 1 — Profile Screen**
```
┌─────────────────────────┐
│  Profile                │
├─────────────────────────┤
│  👤  John Doe           │
│      jdoe@conestogac... │
│      Student ID: 888123 │
│      Doon Campus        │
│      Computer Prog.     │
│                         │
│  [ ✏  Edit Profile  ]  │◄── tap
│                         │
│  ─────────────────────  │
│  🔔 Notifications       │
│  ⚙  Settings           │
│  🚪 Logout              │
└─────────────────────────┘
```

---

**Screen 2 — Edit Profile Form**
```
┌─────────────────────────┐
│ ←  Edit Profile         │
├─────────────────────────┤
│ First Name              │
│ ┌─────────────────────┐ │
│ │ John                │ │
│ └─────────────────────┘ │
│ Last Name               │
│ ┌─────────────────────┐ │
│ │ Doe                 │ │
│ └─────────────────────┘ │
│ Campus                  │
│ ┌─────────────────────┐ │
│ │ Doon              ▼ │ │
│ └─────────────────────┘ │
│ Program                 │
│ ┌─────────────────────┐ │
│ │ Computer Programm.. │ │
│ └─────────────────────┘ │
│                         │
│  ⓘ Email and Student ID │
│  cannot be changed      │
│                         │
│ [      Save Changes   ] │
└─────────────────────────┘
```

---

**Screen 3 — Profile Updated**
```
┌─────────────────────────┐
│  Profile                │
├─────────────────────────┤
│  👤  John Doe           │
│      Doon Campus        │
│      Computer Prog.     │
│                         │
│ ┌─────────────────────┐ │
│ │ ✓ Profile updated!  │ │
│ └─────────────────────┘ │
└─────────────────────────┘
```

---

## Use Case 13 — Settings & Dark Mode

**Screen 1 — Settings Screen**
```
┌─────────────────────────┐
│ ←  Settings             │
├─────────────────────────┤
│  Appearance             │
│  ─────────────────────  │
│  Dark Mode      [ 🌙 ◉] │◄── tap to toggle
│                         │
│  Account                │
│  ─────────────────────  │
│  Change Password   ›    │
│                         │
│  Legal                  │
│  ─────────────────────  │
│  Privacy Policy    ›    │
│  Terms of Service  ›    │
│                         │
│  App Version: 2.0.0     │
└─────────────────────────┘
```

---

**Screen 2 — Dark Mode Enabled**
```
┌─────────────────────────┐  (dark background)
│ ←  Settings             │
├─────────────────────────┤
│  Appearance             │
│  ─────────────────────  │
│  Dark Mode      [◉ ☀ ] │  (toggle ON)
│                         │
│  Account                │
│  ─────────────────────  │
│  Change Password   ›    │
│                         │
│  Legal                  │
│  ─────────────────────  │
│  Privacy Policy    ›    │
│  Terms of Service  ›    │
│                         │
│  App Version: 2.0.0     │
└─────────────────────────┘
```
*System: Theme switches immediately. Preference saved to SharedPreferences.*

---

## Use Case 14 — My Claims (Claimer View)

**Screen 1 — My Claims Screen**
```
┌─────────────────────────┐
│  My Claims              │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │[img] Black Wallet   │ │
│ │      [Pending] ⏳   │ │
│ │      Submitted Mar 10│ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │[img] Blue Earbuds   │ │
│ │      [Approved] ✓   │ │
│ │      Submitted Mar 8│ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │[img] Red Backpack   │ │
│ │      [Rejected] ✗   │ │
│ │      Submitted Mar 5│ │
│ └─────────────────────┘ │
├─────────────────────────┤
│ 🏠  🔍  📦  📋  👤     │
└─────────────────────────┘
```
*Action: Tap a claim row to view Claim Detail and message thread.*

---

**Screen 2 — Claim Detail (Claimer View — Approved)**
```
┌─────────────────────────┐
│ ←  Claim Detail         │
├─────────────────────────┤
│  Blue Earbuds           │
│  Reported by: Sarah K.  │
│  Status: [Approved ✓]   │
│                         │
│  Your Verification:     │
│  "They are Sony WF-1000 │
│   in a white case..."   │
│                         │
├─────────────────────────┤
│  Messages               │
│  ─────────────────────  │
│  ┌─────────────────┐    │
│  │ Hi! Your claim  │    │
│  │ is approved.    │    │
│  │ Come to Doon    │    │
│  │ security desk.  │    │
│  └─────────────────┘    │
├─────────────────────────┤
│ ┌────────────────┐ [→]  │
│ │ Thank you! ... │      │
│ └────────────────┘      │
└─────────────────────────┘
```

---

## Use Case 15 — Home Screen & Dashboard

**Screen 1 — Home Screen (Authenticated)**
```
┌─────────────────────────┐
│  Back2U          🔔     │
├─────────────────────────┤
│  Good morning, John! 👋 │
│  Doon Campus            │
│                         │
│  ┌──────────┬─────────┐ │
│  │ 📦 Lost  │🔍 Found │ │
│  │    12    │    8    │ │
│  └──────────┴─────────┘ │
│                         │
│  ─ Recent Found Items ─ │
│ ┌─────────────────────┐ │
│ │[img] Black Wallet   │ │
│ │      Doon · 2h ago  │ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │[img] Set of Keys    │ │
│ │      Main · 5h ago  │ │
│ └─────────────────────┘ │
│                         │
│  ─ Quick Actions ─      │
│ ┌──────────┬──────────┐ │
│ │🔴 Lost   │🟢 Found  │ │
│ │ Report   │ Report   │ │
│ └──────────┴──────────┘ │
├─────────────────────────┤
│ 🏠  🔍  📦  📋  👤     │
└─────────────────────────┘
```

---

**Screen 2 — FAB Action Sheet**
```
┌─────────────────────────┐
│  Back2U          🔔     │
│                      [+]│
├─────────────────────────┤
│  (home content dimmed)  │
│                         │
│ ╔═════════════════════╗ │
│ ║  What would you     ║ │
│ ║  like to do?        ║ │
│ ╠═════════════════════╣ │
│ ║ 🔴 Report Lost Item ║ │
│ ║   I lost something  ║ │
│ ║   on campus      ›  ║ │
│ ╠═════════════════════╣ │
│ ║ 🟢 Report Found     ║ │
│ ║   I found something ║ │
│ ║   on campus      ›  ║ │
│ ╚═════════════════════╝ │
└─────────────────────────┘
```
*Action: Tapping either option navigates to the respective report screen.*

---

*Document prepared by: Team [Number] | Back2U / CampusFind | Iteration 2*
