# Iteration 3 Plan — Back2U (CampusFind)
### Team [Your Team Number] | Sprint Duration: 2 Weeks

---

## Iteration Goal

Iteration 3 focuses on **polishing the user experience**, adding **push notifications**, implementing **item matching intelligence**, and completing the **admin/security web portal** integration. The goal is to deliver a production-ready application that is stable, performant, and accessible.

---

## Agile Backlog — User Stories

### Epic 1: Push Notifications (Firebase Cloud Messaging)

---

**US-301**
> **As a** item owner,
> **I want to** receive a push notification when someone submits a claim on my found item,
> **So that** I am immediately aware even if the app is closed.

| Field | Detail |
|-------|--------|
| Priority | High |
| Story Points | 5 |
| Assigned To | [Member 1] |
| Status | To Do |

**Acceptance Criteria:**
- [ ] Firebase Cloud Messaging (FCM) is integrated into the Flutter app
- [ ] FCM token is registered with the backend on login
- [ ] A push notification is received within 5 seconds of a new claim being created
- [ ] Notification shows item title and claimer name
- [ ] Tapping notification deep-links to the Claim Detail screen

---

**US-302**
> **As a** claimer,
> **I want to** receive a push notification when my claim is approved or rejected,
> **So that** I can act immediately without having to check the app manually.

| Field | Detail |
|-------|--------|
| Priority | High |
| Story Points | 3 |
| Assigned To | [Member 1] |
| Status | To Do |

**Acceptance Criteria:**
- [ ] Push notification sent when claim status changes to `approved` or `rejected`
- [ ] Notification body states the item name and new status
- [ ] Tapping notification navigates to the relevant Claim Detail screen
- [ ] Works when app is in background and foreground

---

**US-303**
> **As a** user,
> **I want to** receive a push notification when I get a new message on a claim,
> **So that** I can respond quickly without polling.

| Field | Detail |
|-------|--------|
| Priority | Medium |
| Story Points | 3 |
| Assigned To | [Member 2] |
| Status | To Do |

**Acceptance Criteria:**
- [ ] Push notification sent when a new message is added to a claim thread
- [ ] Notification is only sent to the receiver, not the sender
- [ ] Message preview (first 50 chars) shown in notification body
- [ ] Tapping navigates directly to the Claim Detail / Messages screen

---

### Epic 2: Item Matching

---

**US-304**
> **As a** user who reported a lost item,
> **I want to** be notified when a found item with a matching category and campus is posted,
> **So that** I can quickly check if it's mine.

| Field | Detail |
|-------|--------|
| Priority | High |
| Story Points | 8 |
| Assigned To | [Member 1] |
| Status | To Do |

**Acceptance Criteria:**
- [ ] Backend runs a match check on every new found-item POST
- [ ] Match criteria: same `category` AND same `campus`
- [ ] All users with a matching open lost-item report receive a push + in-app notification
- [ ] Notification message: "A [category] was found at [campus] — could it be yours?"
- [ ] Tapping notification navigates to the found item's detail screen
- [ ] Match notifications appear in the Notifications screen with type `item_matched`

---

**US-305**
> **As a** user browsing found items,
> **I want to** see a "Possible Match" badge on items that match my lost report,
> **So that** I can prioritise reviewing them.

| Field | Detail |
|-------|--------|
| Priority | Medium |
| Story Points | 5 |
| Assigned To | [Member 3] |
| Status | To Do |

**Acceptance Criteria:**
- [ ] Browse screen highlights items matching the user's open lost-item category + campus
- [ ] A "Match" chip/badge is shown on matching item cards
- [ ] Badge is only shown if the user has at least one open lost report
- [ ] No badge shown on items they have already claimed

---

### Epic 3: Admin & Security Portal Integration

---

**US-306**
> **As a** security staff member,
> **I want to** log in to a web portal to view all items reported on my campus,
> **So that** I can assist with physical item collection and return.

| Field | Detail |
|-------|--------|
| Priority | High |
| Story Points | 8 |
| Assigned To | [Member 4] |
| Status | To Do |

**Acceptance Criteria:**
- [ ] Security role users are blocked from the mobile app with a "Use web portal" message
- [ ] Web portal shows all items filtered by campus
- [ ] Security staff can update item status to `returned`
- [ ] Portal is accessible at a published URL

---

**US-307**
> **As an** admin,
> **I want to** be able to deactivate suspicious item reports,
> **So that** I can keep the platform free of spam or fraudulent listings.

| Field | Detail |
|-------|--------|
| Priority | Medium |
| Story Points | 3 |
| Assigned To | [Member 4] |
| Status | To Do |

**Acceptance Criteria:**
- [ ] Admin can set `is_active = false` on any item via the web portal
- [ ] Deactivated items no longer appear in the mobile app browse screen
- [ ] Item reporter receives an in-app notification when their item is deactivated

---

### Epic 4: UX Polish & Accessibility

---

**US-308**
> **As a** user with a large item list,
> **I want** the browse screen to use pagination or infinite scroll,
> **So that** the app doesn't slow down when loading hundreds of items.

| Field | Detail |
|-------|--------|
| Priority | High |
| Story Points | 5 |
| Assigned To | [Member 2] |
| Status | To Do |

**Acceptance Criteria:**
- [ ] Browse screen loads items in pages of 20
- [ ] Infinite scroll loads the next page when user reaches 80% of current list
- [ ] A loading indicator appears at the bottom while fetching
- [ ] Filters and search still work correctly with paginated data

---

**US-309**
> **As a** user uploading a photo,
> **I want** the image to be compressed before upload,
> **So that** uploads are fast even on a slow campus WiFi connection.

| Field | Detail |
|-------|--------|
| Priority | Medium |
| Story Points | 3 |
| Assigned To | [Member 3] |
| Status | To Do |

**Acceptance Criteria:**
- [ ] Images are resized to max 1024x1024 pixels before upload
- [ ] File size is capped at 500 KB using quality compression
- [ ] Compression happens transparently — user sees no extra step
- [ ] Compressed preview shown in the form before submission

---

**US-310**
> **As a** user with accessibility needs,
> **I want** all interactive elements to have proper semantic labels,
> **So that** screen readers can describe them accurately.

| Field | Detail |
|-------|--------|
| Priority | Medium |
| Story Points | 3 |
| Assigned To | [Member 3] |
| Status | To Do |

**Acceptance Criteria:**
- [ ] All icon buttons have `Semantics` widget with `label` set
- [ ] All form fields have meaningful `hintText` and `labelText`
- [ ] Image placeholders have descriptive alt-text equivalents
- [ ] App tested with TalkBack (Android) to verify readability

---

**US-311**
> **As a** user,
> **I want to** edit my lost or found item report after submission,
> **So that** I can correct mistakes or add new details.

| Field | Detail |
|-------|--------|
| Priority | Medium |
| Story Points | 5 |
| Assigned To | [Member 2] |
| Status | To Do |

**Acceptance Criteria:**
- [ ] "Edit" button shown on item detail screen for the item owner
- [ ] Edit screen pre-populates all existing fields
- [ ] User can update title, description, location, features, and photo
- [ ] Category, type, and campus cannot be changed after submission
- [ ] API: `PATCH /items/:id` with changed fields only
- [ ] Success toast and screen refreshes with updated data

---

### Epic 5: Performance & Stability

---

**US-312**
> **As a** developer,
> **I want** HTTP responses to be cached locally for 60 seconds,
> **So that** repeated screen visits don't trigger unnecessary API calls.

| Field | Detail |
|-------|--------|
| Priority | Low |
| Story Points | 3 |
| Assigned To | [Member 1] |
| Status | To Do |

**Acceptance Criteria:**
- [ ] Item list is cached in memory for 60 seconds
- [ ] Cache is invalidated on pull-to-refresh
- [ ] Cache is invalidated when the user submits a new item
- [ ] Cached data is used during the Render cold-start period to avoid blank screens

---

**US-313**
> **As a** developer,
> **I want** automated widget tests for the authentication screens,
> **So that** regressions are caught before each release.

| Field | Detail |
|-------|--------|
| Priority | Low |
| Story Points | 5 |
| Assigned To | [Member 2, Member 3] |
| Status | To Do |

**Acceptance Criteria:**
- [ ] Widget tests cover: Login, Register, Forgot Password steps 1–3
- [ ] Tests mock the API service with fake responses
- [ ] All tests pass in CI/CD pipeline
- [ ] Code coverage report generated

---

## Sprint Planning Summary

| User Story | Epic | Points | Priority | Assigned |
|-----------|------|--------|----------|---------|
| US-301 | Push Notifications | 5 | High | Member 1 |
| US-302 | Push Notifications | 3 | High | Member 1 |
| US-303 | Push Notifications | 3 | Medium | Member 2 |
| US-304 | Item Matching | 8 | High | Member 1 |
| US-305 | Item Matching | 5 | Medium | Member 3 |
| US-306 | Admin/Security | 8 | High | Member 4 |
| US-307 | Admin/Security | 3 | Medium | Member 4 |
| US-308 | UX Polish | 5 | High | Member 2 |
| US-309 | UX Polish | 3 | Medium | Member 3 |
| US-310 | Accessibility | 3 | Medium | Member 3 |
| US-311 | UX Polish | 5 | Medium | Member 2 |
| US-312 | Performance | 3 | Low | Member 1 |
| US-313 | Testing | 5 | Low | Members 2+3 |
| **TOTAL** | | **59 pts** | | |

---

## Definition of Done

A user story is considered **Done** when:
1. Code is written and peer-reviewed (pull request approved)
2. Feature works on both Android and iOS (physical device or emulator)
3. Error states and edge cases are handled
4. No new lint warnings introduced (`flutter analyze` passes)
5. Feature is demonstrated in the sprint review demo

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| FCM setup complexity (iOS certificates) | Medium | High | Start FCM integration in week 1; allocate 2 days buffer |
| Render free-tier sleep on backend | High | Medium | Migrate to paid tier or Supabase before final demo |
| Item matching performance on large datasets | Low | Medium | Add DB index on `category + campus + type + status` |
| Team availability during final exam period | Medium | High | Complete high-priority stories in week 1 |

---

## Iteration 3 Timeline

| Day | Activity |
|-----|----------|
| Day 1–2 | Sprint planning, FCM setup, environment config |
| Day 3–4 | US-301, US-302 (new claim + approval notifications) |
| Day 5–6 | US-304 (item matching backend + notification) |
| Day 7 | Mid-sprint review, backlog re-prioritisation |
| Day 8–9 | US-306 (web portal), US-308 (pagination) |
| Day 10–11 | US-305, US-311, US-309 (match badge, edit item, image compression) |
| Day 12–13 | US-303, US-307, US-310, US-312 (remaining stories) |
| Day 14 | US-313 (tests), bug fixes, demo preparation, final release |

---

*Document prepared by: Team [Number] | Back2U / CampusFind | Iteration 3 Plan*
