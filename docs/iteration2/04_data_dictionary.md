# Data Dictionary — Back2U (CampusFind)
### Iteration 2 | Team [Your Team Number]
---

## Overview

This document defines every field in the Back2U database schema. For each table, the field name, data type, constraints, and description are provided.

---

## Table: `users`

Stores registered application users (students, security staff, and admins).

| # | Field | Type | Constraints | Description |
|---|-------|------|-------------|-------------|
| 1 | `id` | INTEGER | PK, AUTO_INCREMENT, NOT NULL | Unique numeric identifier for each user |
| 2 | `student_id` | VARCHAR(20) | UNIQUE, NOT NULL | Conestoga College student ID (e.g., 8888888) |
| 3 | `email` | VARCHAR(255) | UNIQUE, NOT NULL | Institutional email address — must end in `@conestogac.on.ca` |
| 4 | `first_name` | VARCHAR(100) | NOT NULL | User's legal first name |
| 5 | `last_name` | VARCHAR(100) | NOT NULL | User's legal last name |
| 6 | `campus` | VARCHAR(100) | NOT NULL | Campus the user primarily attends (e.g., Main, Doon, Waterloo) |
| 7 | `program` | VARCHAR(150) | NOT NULL | Academic program name (e.g., Computer Programming) |
| 8 | `password_hash` | VARCHAR(255) | NOT NULL | bcrypt-hashed password — plaintext is never stored |
| 9 | `role` | ENUM | NOT NULL, DEFAULT 'student' | User role: `student`, `security`, or `admin` — controls access |
| 10 | `is_verified` | BOOLEAN | NOT NULL, DEFAULT FALSE | Whether the user has verified their email address |
| 11 | `otp_code` | VARCHAR(6) | NULLABLE | 6-digit one-time password for password reset; null when not in reset flow |
| 12 | `otp_expires_at` | TIMESTAMP | NULLABLE | Expiry timestamp for the OTP; null when not in reset flow |
| 13 | `reset_token_hash` | VARCHAR(255) | NULLABLE | Hashed JWT reset token issued after OTP verification; authorises step 3 |
| 14 | `reset_token_expires_at` | TIMESTAMP | NULLABLE | Expiry timestamp for the reset token (typically 10 minutes) |
| 15 | `created_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the record was inserted |
| 16 | `updated_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp of the most recent update (auto-managed) |

---

## Table: `items`

Stores all lost and found item reports submitted by users.

| # | Field | Type | Constraints | Description |
|---|-------|------|-------------|-------------|
| 1 | `id` | INTEGER | PK, AUTO_INCREMENT, NOT NULL | Unique numeric identifier for each item |
| 2 | `user_id` | INTEGER | FK → users.id, NOT NULL | ID of the user who reported this item |
| 3 | `title` | VARCHAR(255) | NOT NULL | Short descriptive title (e.g., "Black Leather Wallet") |
| 4 | `description` | TEXT | NOT NULL | Detailed description of the item |
| 5 | `category` | VARCHAR(50) | NOT NULL | Item category: Wallet, Phone, Keys, ID, Clothing, Bag, Textbook, Electronics, Other |
| 6 | `type` | ENUM | NOT NULL | Report type: `lost` (user lost it) or `found` (user found it) |
| 7 | `status` | ENUM | NOT NULL, DEFAULT 'open' | Current item status: `open`, `claimed`, or `returned` |
| 8 | `campus` | VARCHAR(100) | NOT NULL | Campus where the item was lost or found |
| 9 | `location` | VARCHAR(255) | NOT NULL | Specific location description or GPS coordinates (e.g., "Library, 2nd floor") |
| 10 | `date_lost_found` | DATE | NOT NULL | Calendar date the item was lost or found |
| 11 | `distinctive_features` | TEXT | NULLABLE | Any unique identifying marks (e.g., "Scratch on back cover") |
| 12 | `image_url` | VARCHAR(500) | NULLABLE | URL to uploaded image stored in cloud storage; required for found items |
| 13 | `is_active` | BOOLEAN | NOT NULL, DEFAULT TRUE | Soft-delete flag; false means the item is hidden from browsing |
| 14 | `created_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the report was submitted |
| 15 | `updated_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp of the most recent update |

---

## Table: `claims`

Stores ownership claims submitted by users who believe a found item belongs to them.

| # | Field | Type | Constraints | Description |
|---|-------|------|-------------|-------------|
| 1 | `id` | INTEGER | PK, AUTO_INCREMENT, NOT NULL | Unique numeric identifier for each claim |
| 2 | `item_id` | INTEGER | FK → items.id, NOT NULL | ID of the found item being claimed |
| 3 | `claimer_id` | INTEGER | FK → users.id, NOT NULL | ID of the user submitting the claim |
| 4 | `owner_id` | INTEGER | FK → users.id, NOT NULL | ID of the user who reported the found item (the reviewer) |
| 5 | `status` | ENUM | NOT NULL, DEFAULT 'pending' | Claim status: `pending`, `approved`, or `rejected` |
| 6 | `verification_notes` | TEXT | NOT NULL | Claimer's written proof of ownership description |
| 7 | `verification_answer` | TEXT | NULLABLE | Optional answer to a specific verification question (e.g., "What colour is it?") |
| 8 | `created_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the claim was submitted |
| 9 | `updated_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp of the most recent status update |

---

## Table: `messages`

Stores chat messages between the claimer and item owner within a specific claim thread.

| # | Field | Type | Constraints | Description |
|---|-------|------|-------------|-------------|
| 1 | `id` | INTEGER | PK, AUTO_INCREMENT, NOT NULL | Unique numeric identifier for each message |
| 2 | `claim_id` | INTEGER | FK → claims.id, NOT NULL | ID of the claim this message belongs to |
| 3 | `sender_id` | INTEGER | FK → users.id, NOT NULL | ID of the user who sent this message |
| 4 | `receiver_id` | INTEGER | FK → users.id, NOT NULL | ID of the user who receives this message |
| 5 | `message` | TEXT | NOT NULL | Body text of the message |
| 6 | `is_read` | BOOLEAN | NOT NULL, DEFAULT FALSE | Whether the receiver has read this message |
| 7 | `created_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the message was sent |

---

## Table: `notifications`

Stores in-app notification records sent to users on key events.

| # | Field | Type | Constraints | Description |
|---|-------|------|-------------|-------------|
| 1 | `id` | INTEGER | PK, AUTO_INCREMENT, NOT NULL | Unique numeric identifier for each notification |
| 2 | `user_id` | INTEGER | FK → users.id, NOT NULL | ID of the user who should receive this notification |
| 3 | `title` | VARCHAR(255) | NOT NULL | Short notification headline (e.g., "New Claim on Your Item") |
| 4 | `message` | TEXT | NOT NULL | Full notification body text |
| 5 | `type` | VARCHAR(50) | NOT NULL | Category: `new_claim`, `claim_approved`, `claim_rejected`, `new_message`, `item_matched` |
| 6 | `reference_id` | INTEGER | NULLABLE | ID of the related entity (claim_id or item_id) for deep linking |
| 7 | `is_read` | BOOLEAN | NOT NULL, DEFAULT FALSE | Whether the user has read this notification |
| 8 | `created_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | Timestamp when the notification was created |

---

## Enum Value Reference

| Table | Field | Allowed Values |
|-------|-------|----------------|
| `users` | `role` | `student`, `security`, `admin` |
| `items` | `type` | `lost`, `found` |
| `items` | `status` | `open`, `claimed`, `returned` |
| `claims` | `status` | `pending`, `approved`, `rejected` |
| `notifications` | `type` | `new_claim`, `claim_approved`, `claim_rejected`, `new_message`, `item_matched` |

---

## Category Values Reference

The `items.category` field accepts the following values (controlled by dropdown in the app):

| Value | Description |
|-------|-------------|
| `Wallet` | Wallets, purses, money clips |
| `Phone` | Mobile phones, smartphones |
| `Keys` | Keys, keychains, fobs |
| `ID` | Student cards, driver's licences, health cards |
| `Clothing` | Jackets, hoodies, hats, scarves |
| `Bag` | Backpacks, handbags, tote bags |
| `Textbook` | Course textbooks, notebooks, binders |
| `Electronics` | Laptops, earbuds, tablets, chargers |
| `Other` | Any item that doesn't fit the above categories |

---

## Campus Values Reference

The `items.campus` and `users.campus` fields accept the following values:

| Value | Full Name |
|-------|-----------|
| `Main` | Conestoga Main Campus (Kitchener) |
| `Doon` | Conestoga Doon Campus (Kitchener) |
| `Waterloo` | Conestoga Waterloo Campus |
| `Cambridge` | Conestoga Cambridge Campus |
| `Guelph` | Conestoga Guelph Campus |
| `Stratford` | Conestoga Stratford Campus |
| `Ingersoll` | Conestoga Ingersoll Campus |
| `Online` | Online / Remote |

---

*Document prepared by: Team [Number] | Back2U / CampusFind | Iteration 2*
