# HireWise

## What It Is

HireWise is a Flutter marketplace app that connects students and professionals in Kigali, Rwanda with verified freelance experts across Tech, Design, Legal, Finance, Education, and Marketing. The core problem: finding qualified, trustworthy specialists locally is slow, informal, and unreliable. HireWise solves this by letting users browse expert profiles, book sessions, and communicate — all in one place.

---

## Team Members & Primary Contributions

| Member | Registration Number | Primary Contribution |
|--------|---------------------|----------------------|
| Tresor Ndungutse | 223003172 | OOP data models, BaseModel abstract class, Expert & Conversation classes; Role dashboards — TutorShell, AdminShell, AppState service |
| Uwamwezi Esther | 223010694 | Flutter UI — HomeScreen, ExpertCard widget, sector filter, hero banner; Navigation & Forms — LoginScreen, ValidationMixin, named routes |

---

## How to Run

**Prerequisites:** Flutter SDK 3.x, VS Code or Android Studio.

```bash
# 1. Clone the repository
git clone <repo-url>
cd hirewise

# 2. Install dependencies
flutter pub get

# 3. Run on Chrome (recommended for quick demo)
flutter run -d chrome

# 4. Run on Windows desktop
flutter run -d windows

# 5. Run on Android (requires Android emulator or physical device)
flutter run
```

**Demo accounts (no sign-up needed):**

| Role | Email | Password |
|------|-------|----------|
| Student | student@demo.com | password |
| Tutor (approved) | tutor@demo.com | password |
| Tutor (pending) | tutor2@demo.com | password |
| Admin | admin@demo.com | admin123 |

---

## Flutter Doctor

![flutter doctor output](flutter_doctor.png)

```
Doctor summary (to see all details, run flutter doctor -v):
[√] Flutter (Channel stable, 3.41.2, on Microsoft Windows [Version 10.0.26200.8246], locale en-US)
[√] Windows Version (11 Pro 64-bit, 25H2, 2009)
[√] Android toolchain - develop for Android devices (Android SDK version 36.1.0)
[√] Chrome - develop for the web
[√] Visual Studio - develop Windows apps (Visual Studio Community 2022 17.14.19)
[√] Connected device (3 available)
[√] Network resources

• No issues found!
```

---

## Mini-Capstone Snapshot — Parts A–D

> HireWise is a Flutter marketplace app that connects clients with verified freelance experts in Kigali. The mini-capstone covers four progressive layers: Dart fundamentals → OOP models → Flutter UI → Navigation & Forms.

---

### Part A — Dart Fundamentals
**Files:** `lib/models/expert.dart`, `lib/utils/validation_mixin.dart`, `lib/services/app_state.dart`

| Concept | Where used |
|---------|-----------|
| Explicit types & `var` | All model fields (`String id`, `double rating`, `var label`) |
| `final` / `const` | `kExperts` constant list, `const Expert(...)` entries, widget keys |
| Null safety (`??`, `?`, `!`) | `expert.bio ?? 'No bio'`, nullable `AppUser?`, force-unwrap on validated routes |
| Named & optional params | `validatePassword({int minLength = 6})`, `Expert({required this.name, this.bio})` |
| Arrow functions | `validateNotEmpty`, `toMap()` single-expression bodies |
| Collections | `List<Expert> kExperts`, `Map<String, dynamic> toMap()`, `Set<String>` for unique sectors |
| Control flow | Regex email validation, role-based route guard, ternary in widget builds |

---

### Part B — OOP & Data Models
**Files:** `lib/models/base_model.dart`, `lib/models/expert.dart`, `lib/models/message.dart`

| Concept | Implementation |
|---------|---------------|
| Abstract class | `BaseModel` — declares `String get id` and `Map<String,dynamic> toMap()` |
| Inheritance | `Expert extends BaseModel`, `Conversation extends BaseModel` |
| Constructors | `const`, named, and `factory Expert.fromMap(Map m)` on `Expert` |
| Mixin | `ValidationMixin` mixed into `_LoginScreenState` — shared validation without inheritance |
| Enum | `TutorStatus { pending, approved, rejected }` on `AppUser` |
| Async simulation | `Future<void> _submit()` with `await Future.delayed(Duration(seconds: 1))` in login flow |
| `copyWith` | `Conversation.copyWith(...)` for immutable message state updates |

---

### Part C — Flutter UI
**Files:** `lib/screens/home_screen.dart`, `lib/screens/expert_profile_screen.dart`, `lib/widgets/`

| Screen / Widget | Key detail |
|----------------|-----------|
| `HomeScreen` | Hero banner, stats strip, sector filter row (`SectorChip`), expert grid, top-rated horizontal list |
| `ExpertProfileScreen` | `SliverAppBar` with collapsing header, services list, reviews, dual CTA (Book / Message) |
| `ExpertCard` | Reusable card widget — avatar, rating stars, sector badge, price |
| `SectorChip` | Filter pill; selected state driven by `AppState` notifier |
| `AppTheme` | Material Design 3: `useMaterial3: true`, `ColorScheme.fromSeed(seedColor: Color(0xFF1565C0))` |

---

### Part D — Navigation & Forms
**Files:** `lib/main.dart`, `lib/screens/login_screen.dart`, `lib/screens/book_expert_screen.dart`

| Concept | Implementation |
|---------|---------------|
| Named routes | `/login`, `/` (home), `/tutor`, `/admin`, `/expert/:id`, `/book` — all registered in `MaterialApp.routes` |
| Route arguments | `Expert` object passed via `Navigator.pushNamed(context, '/expert', arguments: expert)` |
| Form validation | `Form` + `GlobalKey<FormState>` + `TextFormField` with inline validators in `LoginScreen` |
| Tutor signup fields | Name, phone, email, password, confirm password, specialty, qualifications, experience (8 validated fields) |
| Back navigation | `Navigator.pop()` throughout; `Navigator.pushReplacementNamed` for post-login redirect |
| Role-based routing | `AppState.currentUser.role` determines whether app routes to `/`, `/tutor`, or `/admin` after login |

---

### Phase 0 — Design
- **Colour palette:** Primary `#1565C0` (deep blue) · Accent `#FF6F00` (amber) · Surface `#F5F5F5` (light grey)
- **Typography:** `Poppins` for headings, `Inter` for body text
- **Rationale:** Deep blue conveys professional trust; amber drives CTA urgency; card-based layout mirrors established marketplace patterns (Upwork, Fiverr) familiar to the target user
