# Back2U — Iteration 2 Presentation Script
### Conestoga College | Capstone Project | Group 4

> **How to use this file:**
> Each slide has a heading and a **"Say this:"** section — just read that part out loud.
> You do not need to memorize anything. One slide = roughly 1 minute of speaking.

---

## Slide 1 — Title Slide
**Title:** Back2U — Campus Lost & Found Application
**Subtitle:** Iteration 2 Presentation | Group 4
**Members:** Rudraksh Kharadi · Bishal Paudel · Gagan Singh · Gurjant Singh

> **Say this:**
> "Good morning / Good afternoon everyone.
> My name is [your name], and I am presenting on behalf of Group 4 — Team Back2U.
> Our project is called Back2U — a mobile lost and found application built specifically for Conestoga College students.
> In this presentation, we will walk you through everything we completed in Iteration 2 — the core features, what each team member built, our database design, and what we are planning for Iteration 3.
> We have about twelve slides today, so let's get started."

---

## Slide 2 — What Is Back2U?
**Bullet points:**
- A Flutter mobile app for Conestoga College students
- Students can report lost or found items on campus
- Other students can submit claims to recover their belongings
- Built-in messaging between the claimer and item reporter
- Push notifications for every key event

> **Say this:**
> "So, what exactly is Back2U?
> Back2U is a mobile application built with Flutter that solves a very common campus problem — losing things and having no easy way to find them or report them.
> On our app, a student who finds something on campus can report it as a found item. A student who has lost something can report it as well.
> When a found item matches what someone lost, they can submit a claim to get it back. The two students then communicate through the built-in messaging system inside the app.
> And throughout this whole process, both students receive in-app notifications so they are always updated without having to check manually.
> It is a complete, end-to-end lost and found system for the campus."

---

## Slide 3 — Team Overview & Responsibilities

| Member | Role | Main Area |
|--------|------|-----------|
| Rudraksh Kharadi | Team Lead / Full Stack | Backend API, Authentication |
| Gagan Singh | Flutter Developer | Item Reporting, Claim Submission |
| Gurjant Singh | Flutter Developer | Browse Screen, Messaging UI |
| Bishal Paudel | Flutter Developer | Notifications, Profile, Documentation |

> **Say this:**
> "Our team has four members, and each person owned a specific part of the application.
> Rudraksh is our team lead and full stack developer. He handled the backend API and the entire authentication system, including the forgot password flow.
> Gagan focused on the Flutter side — specifically the item reporting screens for both lost and found items, and the claim submission feature.
> Gurjant built the browse and search screen where students can discover items, and he also built the messaging UI inside the claim detail screen.
> And Bishal handled notifications, the profile and settings screens, dark mode, and all of our project documentation — the flow diagrams, storyboards, and the ERD.
> In the next few slides, I will go into more detail on what each person built."

---

## Slide 4 — Rudraksh Kharadi — Authentication & Backend

**What he built:**
- Complete JWT-based login and registration
- 3-step Forgot Password flow using OTP
- Fixed API field names, timeouts, and reset token handling
- Navigation routing and configuration setup

> **Say this:**
> "Starting with Rudraksh.
> Rudraksh set up and maintained the backend API communication layer for the entire app. He built the complete authentication system — registration with student ID and institutional email validation, and login with JWT tokens.
> One of the more complex things he delivered was the three-step forgot password flow. In Step 1, the user enters their email. If the email is not found, the app now shows a warning banner instead of silently moving forward — that was a specific bug fix in this iteration. In Step 2, the user receives a six-digit OTP which expires after 90 seconds. He increased that timeout to handle server cold-start delays. In Step 3, the user sets a new password with full validation — at least 8 characters, one number, and one special character.
> He also cleaned up all the route configuration and fixed incorrect API field names that were causing password resets to fail silently."

---

## Slide 5 — Gagan Singh — Item Reporting & Claim Submission

**What he built:**
- Report Lost Item screen (multi-field form with GPS)
- Report Found Item screen (photo upload mandatory)
- Item Detail screen with conditional claim button
- Claim submission form with verification notes

> **Say this:**
> "Next, Gagan.
> Gagan built the core workflow of the app — reporting items and submitting claims.
> The Report Lost Item screen has a full form — title, category, campus, description, location with GPS capture, a date picker, and an optional photo. Everything is validated on the client side before it even reaches the API.
> The Report Found Item screen is slightly different — here, the photo is mandatory. If you found someone's item, you need to upload a photo so the owner can verify it. When the form is submitted, a success message says 'Thank you for helping' and the user is redirected home.
> Gagan also built the Item Detail screen, which is smart — it shows a Claim This Item button only for found items. If the user already submitted a claim, the button changes to View My Claim. And if the user is the one who reported the item, the button is hidden entirely.
> Finally, the Claim Submission form collects verification notes and an optional answer, which the item owner can review."

---

## Slide 6 — Gurjant Singh — Browse Screen & Messaging UI

**What he built:**
- Browse & Search screen with tabs, filters, real-time search
- Claim Detail screen with live message thread
- Home screen item cards
- My Items screen with status actions

> **Say this:**
> "Now, Gurjant.
> Gurjant built the discovery side of the app — the part where students actually find items.
> The Browse screen has two tabs — Found Items and Lost Items. It supports real-time search that filters by title and description as you type. It also has category and campus filters, and a pull-to-refresh feature. If the API fails, the screen shows a proper error state with a Retry button — not just a blank screen.
> He also built the Claim Detail screen, which is where the conversation between the claimer and the item owner happens. The message thread automatically refreshes every 10 seconds, so both users see new messages without doing anything. The unread message count appears as a badge on the Profile tab.
> He also worked on the Home screen item cards and the My Items screen, where users can view, update, or delete items they reported."

---

## Slide 7 — Bishal Paudel — Notifications, Profile & Documentation

**What he built:**
- Notifications screen with unread badge
- Profile & Settings screen with dark mode
- Complete project documentation (flow diagrams, storyboards, ERD)
- Data dictionary with all 5 database tables

> **Say this:**
> "And finally, Bishal.
> Bishal handled two separate areas — the UI features and all of the project documentation.
> On the UI side, he built the Notifications screen, which shows all in-app alerts — things like 'Someone submitted a claim on your item' or 'Your claim was approved'. Unread notifications show a badge on the Profile tab. When a notification is opened, it is automatically marked as read.
> He also built the Profile and Settings screens — users can view and edit their information, toggle dark mode, read the Privacy Policy and Terms of Service, and log out with a confirmation dialog.
> On the documentation side, Bishal created all the iteration documents — the ten use case flow diagrams, the fifteen storyboard screens, the Entity Relationship Diagram, the full data dictionary for all five database tables, and the release summary. This documentation represents a significant amount of careful work beyond just writing code."

---

## Slide 8 — Features Delivered in Iteration 2

**Full feature list:**
1. Authentication System (Register, Login, Forgot Password)
2. Report Lost Item
3. Report Found Item
4. Browse & Search Items
5. Item Detail Screen
6. Submit a Claim
7. In-App Messaging
8. My Items Screen
9. My Claims Screen
10. Notifications
11. Profile & Settings

> **Say this:**
> "Here is a complete list of everything that was delivered in Iteration 2.
> We delivered eleven features in total. Starting from the top — the full authentication system, reporting lost items, reporting found items, browsing and searching, viewing item details, submitting a claim, the messaging system between users, managing your own reported items, tracking your submitted claims, in-app notifications, and the profile and settings screen.
> At the start of Iteration 2, none of these existed. The app had basic navigation and structure from Iteration 1. Everything on this list was built from scratch during this iteration.
> We also fixed ten known bugs from Iteration 1 — things like the password reset timing out, incorrect API field names, and missing back navigation buttons.
> All eleven features have been tested and are working in the current build."

---

## Slide 9 — Database Design Overview

**5 core tables:**
- `users` — accounts, roles, OTP & reset tokens
- `items` — lost/found reports with status lifecycle
- `claims` — ownership verification requests
- `messages` — claim conversation thread
- `notifications` — in-app alerts per user

**Relationships:** All One-to-Many (1 : N)

> **Say this:**
> "Let's talk briefly about the database.
> The Back2U database has five core tables.
> The Users table stores everything about a registered account — name, email, student ID, campus, program, password hash, and the OTP and reset token fields for the forgot password flow.
> The Items table is the heart of the system. It stores lost and found reports with a type field — lost or found — and a status field that moves through open, claimed, and returned.
> The Claims table connects a found item to the person claiming it and the person who reported it. It stores the verification notes and the claim status — pending, approved, or rejected.
> The Messages table stores the conversation thread tied to a specific claim. Each message has a sender and a receiver.
> And the Notifications table stores all the alerts sent to a user, with a type field so the app knows what screen to open when a notification is tapped.
> All relationships are one-to-many. One user can have many items, many claims, many messages, and many notifications."

---

## Slide 10 — Live Demo

**Links:**
- 📱 Video Demo: `https://drive.google.com/file/d/1vxfzWt0NURxp_QomztxLPbxIYz98xh6d/view`
- 💻 GitHub (Mobile): `https://github.com/RDK2305/back2u_mobile`
- 🌐 GitHub (Web/Backend): `https://github.com/RDK2305/back2u`

> **Say this:**
> "We have a recorded video demonstration of the app running.
> In the video, you can see the full user journey — registration, login, reporting a found item with a photo, browsing the item list, submitting a claim from another account, the owner reviewing the claim and approving it, the messaging thread between both users, and the notification appearing in real time.
> The full source code is available on GitHub — we have two repositories, one for the Flutter mobile app and one for the React and Node backend.
> The links are on this slide, and they are also in our submission document.
> If you would like to see a specific feature in the demo video, I can point you to the right timestamp."

---

## Slide 11 — Iteration 3 Plan

**5 Epics planned:**
1. 🔔 Push Notifications via Firebase Cloud Messaging
2. 🔎 Smart Item Matching (auto-suggest matches)
3. 🖥 Admin & Security Web Portal
4. ⚡ UX Polish — Infinite scroll, image compression
5. ♿ Accessibility improvements

**Total: 9 user stories | 43 story points | 14-day sprint**

> **Say this:**
> "Looking ahead, here is what we have planned for Iteration 3.
> We have five epics. The first is push notifications using Firebase Cloud Messaging — so users get real-time alerts even when the app is closed.
> The second is smart item matching. When a found item is reported, the backend will automatically check if it matches any open lost reports based on category and campus, and notify the owner.
> The third is the admin and security web portal. Security staff currently cannot use the mobile app — they need a separate web interface to view campus items and update their status.
> The fourth is UX improvements — specifically infinite scrolling for item lists, and automatic image compression before upload.
> And the fifth is accessibility.
> We have nine user stories totalling 43 story points across a fourteen-day sprint, with assignments already distributed across the team."

---

## Slide 12 — Conclusion & Q&A

**Summary:**
- 11 features delivered end-to-end ✅
- 10 bugs resolved ✅
- 4 team members contributed on schedule ✅
- 15 commits across March 1–16 ✅
- Database fully documented ✅
- Iteration 3 plan ready ✅

> **Say this:**
> "To wrap up —
> In Iteration 2, we delivered a fully functional campus lost and found application. Eleven features were built from scratch, ten bugs were resolved, and the entire project — code, database design, and documentation — was completed by all four team members over the course of two weeks.
> The app handles registration, login, password recovery, item reporting, claim submission, messaging, notifications, and profile management — the complete user workflow from end to end.
> Our Iteration 3 plan is ready and our team is already aligned on the next sprint.
> Thank you for your time. We are happy to answer any questions about the features, the code, or the design decisions we made."

---

*Prepared by Group 4 — Back2U | Conestoga College Capstone | Iteration 2*
*Script format: read-aloud, one minute per slide, twelve slides total ≈ 12 minutes*
