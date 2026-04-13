# Medi Exam - Project Structure Documentation

## Project Overview

**Project Name:** medi_exam  
**Type:** Flutter Mobile Application  
**Version:** 1.5.1+14  
**Dart SDK:** ^3.6.1  
**Status:** Active Development

### Description

Medi Exam is a comprehensive Flutter application designed to help medical students prepare for exams by providing a centralized platform for exam-related resources. The app offers:

- **Practice Tests & Quizzes:** Interactive MCQ and SBA (Short Answer Based) questions
- **Study Materials:** Downloadable study guides and reference materials
- **Exam Scheduling:** View and manage exam schedules
- **Progress Tracking:** Monitor exam performance and analytics
- **Payment Integration:** Multiple payment gateway support (bKash, Nagad, Visa, SSL Commerz, etc.)
- **Course Management:** Browse, enroll, and manage courses
- **Notifications:** Real-time exam notifications and updates
- **User Profiles:** Doctor profiles, personalized exam history, and preferences

---

## Project Directory Tree

```
medi_exam/
├── android/                           # Android platform-specific code
│   ├── app/                          # Android app module
│   │   ├── build.gradle              # App build configuration
│   │   ├── upload-keystore.jks       # Keystore for signing
│   │   └── src/                      # Android source files
│   ├── gradle/                       # Gradle wrapper
│   ├── build.gradle                  # Project build configuration
│   ├── gradle.properties              # Gradle properties
│   ├── key.properties                # Key properties
│   └── settings.gradle               # Gradle settings
│
├── assets/                            # Static assets
│   ├── icons/                        # SVG and PNG icons
│   │   ├── bkash_logo.svg
│   │   ├── call_icon.svg
│   │   ├── exam_icon.png
│   │   ├── feedback_icon.png
│   │   ├── home_icon.svg
│   │   ├── menus_icon.svg
│   │   ├── my_course_icon.svg
│   │   ├── nagad_logo.svg
│   │   ├── search_icon.png
│   │   ├── solve_icon.png
│   │   ├── support_icon.svg
│   │   ├── visa_logo.svg
│   │   ├── web.svg
│   │   └── whatsapp_icon.svg
│   └── images/                       # PNG and JPG images
│       ├── bkash_logo.png
│       ├── maunal_payment.png
│       ├── nagad_logo.png
│       ├── neuron_logo.png
│       ├── pg_easy_logo.png
│       ├── placeholder_image.png
│       ├── rocket_dbbl_logo.png
│       └── sslcommerz_logo.png
│
├── build/                             # Build output directory
│   └── [Generated build artifacts]
│
├── ios/                               # iOS platform-specific code
│   ├── Runner/                       # iOS app target
│   ├── Runner.xcodeproj/             # Xcode project
│   ├── Runner.xcworkspace/           # Xcode workspace
│   ├── Podfile                       # CocoaPods dependencies
│   └── Flutter/                      # Flutter iOS configuration
│
├── lib/                               # Main Dart code
│   ├── main.dart                     # Application entry point
│   ├── app.dart                      # Root widget and app configuration
│   ├── app_theme.dart                # Theme configuration and constants
│   ├── controller_binder.dart        # GetX dependency injection binding
│   │
│   ├── data/                         # Data layer
│   │   ├── models/                   # Data models (44+ model files)
│   │   │   ├── auth_models.dart
│   │   │   ├── exam_property_model.dart
│   │   │   ├── exam_question_model.dart
│   │   │   ├── exam_result_model.dart
│   │   │   ├── payment_details_model.dart
│   │   │   ├── courses_model.dart
│   │   │   ├── batch_details_model.dart
│   │   │   └── [40+ more models]
│   │   │
│   │   ├── services/                 # API service classes (44+ service files)
│   │   │   ├── auth_service.dart
│   │   │   ├── exam_property_service.dart
│   │   │   ├── exam_questions_service.dart
│   │   │   ├── payment_details_service.dart
│   │   │   ├── active_batch_courses_service.dart
│   │   │   ├── batch_enrollment_service.dart
│   │   │   └── [40+ more services]
│   │   │
│   │   ├── network_caller.dart       # HTTP client wrapper
│   │   ├── network_response.dart     # Network response model
│   │   │
│   │   └── utils/                    # Data layer utilities
│   │
│   └── presentation/                 # Presentation layer (UI)
│       ├── controllers/              # GetX controllers
│       │   └── background_settings_controller.dart
│       │
│       ├── screens/                  # Screen widgets (24+ screens)
│       │   ├── splash_screen.dart
│       │   ├── login_screen.dart
│       │   ├── home_screen.dart
│       │   ├── navbar_screen.dart
│       │   ├── profile_section_screen.dart
│       │   ├── courses_screen.dart
│       │   ├── available_batches_screen.dart
│       │   ├── batch_details_screen.dart
│       │   ├── batch_schedule_screen.dart
│       │   ├── open_exam_list_screen.dart
│       │   ├── easy_finder_screen.dart
│       │   ├── notice_screen.dart
│       │   ├── payment_screen.dart
│       │   ├── payment_history_screen.dart
│       │   ├── manual_payment_screen.dart
│       │   ├── edit_profile_screen.dart
│       │   ├── change_password_screen.dart
│       │   ├── subject_wise_preparation_screen.dart
│       │   ├── subject_wise_chapter_topics_screen.dart
│       │   ├── make_customize_question_screen.dart
│       │   ├── session_wise_batches_screen.dart
│       │   ├── invoice_webview.dart
│       │   ├── dashboard_screens/    # Dashboard sub-screens
│       │   └── [More screen files]
│       │
│       ├── widgets/                  # Reusable widget components (60+ widgets)
│       │   ├── common_scaffold.dart  # Common app scaffold
│       │   ├── custom_drawer.dart    # Navigation drawer
│       │   ├── custom_nav_bar.dart   # Bottom navigation bar
│       │   ├── exam_timer.dart       # Exam countdown timer
│       │   ├── exam_overview_dialog.dart
│       │   ├── loading_widget.dart   # Loading indicator
│       │   ├── shimmer_loading.dart  # Skeleton loader
│       │   ├── mcq_question_tile.dart
│       │   ├── sba_question_tile.dart
│       │   ├── mcq_answer_review_tile.dart
│       │   ├── sba_answer_review_tile.dart
│       │   ├── available_course_card_widget.dart
│       │   ├── enrolled_courses_card_widget.dart
│       │   ├── session_wise_batch_card.dart
│       │   ├── notice_card_widget.dart
│       │   ├── payment_success_dialog.dart
│       │   ├── image_slider_banner.dart
│       │   ├── floating_customer_care.dart
│       │   ├── custom_glass_card.dart
│       │   ├── app_background.dart   # Background styling
│       │   ├── animated_gradient_button.dart
│       │   ├── easy_finder_search_bar_card.dart
│       │   ├── question_action_row.dart
│       │   ├── helpers/              # Widget helper utilities
│       │   └── [40+ more widgets]
│       │
│       └── utils/                    # Presentation layer utilities
│
├── linux/                             # Linux platform-specific code
│   ├── CMakeLists.txt
│   ├── flutter/
│   └── runner/
│
├── macos/                             # macOS platform-specific code
│   ├── Podfile
│   ├── Flutter/
│   ├── Runner/
│   └── Runner.xcodeproj/
│
├── test/                              # Unit and widget tests
│   └── widget_test.dart
│
├── web/                               # Web platform code
│   ├── index.html                    # Web entry point
│   ├── manifest.json                 # PWA manifest
│   ├── favicon.png
│   └── icons/                        # Web app icons
│
├── windows/                           # Windows platform-specific code
│   ├── CMakeLists.txt
│   ├── flutter/
│   └── runner/
│
├── analysis_options.yaml              # Dart analysis configuration
├── devtools_options.yaml              # DevTools configuration
├── pubspec.yaml                       # Flutter project dependencies
├── pubspec.lock                       # Locked dependency versions
├── medi_exam.iml                      # IDE project file
├── README.md                          # Project readme
└── project_structure.md               # This file
```

---

## Project Structure Details

### 1. **Data Layer** (`lib/data/`)

Handles all backend communication and data management.

#### Models (44+ files)
Data models represent API responses and application entities:
- **Authentication:** `auth_models.dart`
- **Exams:** `exam_property_model.dart`, `exam_question_model.dart`, `exam_result_model.dart`
- **Courses:** `courses_model.dart`, `batch_details_model.dart`, `enrolled_course_item.dart`
- **Payments:** `payment_details_model.dart`, `payment_history_model.dart`, `payment_result_model.dart`
- **Users:** `doctor_profile_model.dart`, `update_profile_model.dart`
- **Analytics:** `question_analytics_breakdown_model.dart`, `exam_answers_model.dart`
- **Other:** Subjects, batches, schedules, notices, videos, etc.

#### Services (44+ files)
API service layer handling HTTP requests:
- Each service corresponds to a model for data fetching
- Examples: `auth_service.dart`, `exam_questions_service.dart`, `payment_details_service.dart`
- Services use `NetworkCaller` for HTTP communication

#### Network Files
- **`network_caller.dart`** - HTTP client wrapper for API requests
- **`network_response.dart`** - Standardized API response wrapper

#### Utils
Helper functions and utilities for data operations.

---

### 2. **Presentation Layer** (`lib/presentation/`)

Handles all UI components and user interactions.

#### Screens (24+ files)
Main app screens/pages:
- **Authentication:** `login_screen.dart`, `change_password_screen.dart`
- **Navigation:** `splash_screen.dart`, `navbar_screen.dart`, `home_screen.dart`
- **Courses:** `courses_screen.dart`, `available_batches_screen.dart`, `batch_details_screen.dart`
- **Exams:** `open_exam_list_screen.dart`, `subject_wise_preparation_screen.dart`
- **Profile:** `profile_section_screen.dart`, `edit_profile_screen.dart`
- **Payments:** `payment_screen.dart`, `payment_history_screen.dart`, `manual_payment_screen.dart`
- **Features:** `easy_finder_screen.dart`, `notice_screen.dart`, `batch_schedule_screen.dart`
- **Utilities:** `invoice_webview.dart`, `make_customize_question_screen.dart`

#### Controllers (1+ files)
GetX state management controllers:
- `background_settings_controller.dart` - Manages background settings

#### Widgets (60+ files)
Reusable UI components:

**Layout & Navigation:**
- `common_scaffold.dart` - Standard app scaffold
- `custom_drawer.dart` - Navigation drawer
- `custom_nav_bar.dart` - Bottom navigation bar
- `custom_glass_card.dart` - Glassmorphism card

**Question & Answer Display:**
- `mcq_question_tile.dart` - MCQ question display
- `sba_question_tile.dart` - Short answer question display
- `mcq_answer_review_tile.dart` - MCQ answer review
- `sba_answer_review_tile.dart` - SBA answer review
- `question_action_row.dart` - Action buttons for questions
- `question_explaination_button.dart` - Explanation viewer

**Cards & Lists:**
- `available_course_card_widget.dart` - Course listing
- `enrolled_courses_card_widget.dart` - Student courses
- `session_wise_batch_card.dart` - Batch display
- `notice_card_widget.dart` - Notice display
- `easy_finder_card.dart` - Search result cards
- `exam_list_section.dart` - Exam listing

**Dialogs & Modals:**
- `exam_overview_dialog.dart` - Exam details modal
- `payment_success_dialog.dart` - Payment confirmation
- `free_exam_notify_dialog.dart` - Notification dialog
- `enrollment_dialog.dart` - Course enrollment modal
- `units_vs_questions_dialog.dart` - Unit/question selector

**Exam Features:**
- `exam_timer.dart` - Countdown timer
- `exam_finish_feedback_dialog.dart` - Feedback collection
- `exam_solve_links_section.dart` - Solve links

**Animations & Effects:**
- `animated_gradient_button.dart` - Animated button
- `animated_container_widget.dart` - Container animation
- `animated_text_widget.dart` - Text animation
- `shimmer_loading.dart` - Skeleton loader
- `loading_widget.dart` - Loading indicator

**Visual Components:**
- `app_background.dart` - Default background
- `custom_blob_background.dart` - Blob design
- `custom_background.dart` - Custom backgrounds
- `fancy_card_background.dart` - Card backgrounds
- `hero_header_with_image.dart` - Hero animation
- `image_slider_banner.dart` - Carousel banner

**Utilities & Helpers:**
- `floating_customer_care.dart` - FAB for support
- `print_button_widget.dart` - Print functionality
- `notification_bell.dart` - Notification icon
- `date_formatter_widget.dart` - Date display
- `date_section.dart` - Date section header
- `helpers/` - Additional widget helpers

#### Utils
Presentation layer utilities for formatting, validation, and helpers.

---

### 3. **Root Level Dart Files** (`lib/`)

- **`main.dart`** - Application entry point, initializes app
- **`app.dart`** - Root widget, app configuration, routing
- **`app_theme.dart`** - Theme configuration, colors, typography, spacing
- **`controller_binder.dart`** - GetX dependency injection setup

---

### 4. **Assets** (`assets/`)

Static resources organized by type:

**Icons:** SVG icons for branding and UI (bKash, Nagad, Visa logos, etc.)  
**Images:** Logo images, payment provider logos, placeholders

---

### 5. **Platform-Specific Code**

- **`android/`** - Android app configuration, signing, build files
- **`ios/`** - iOS app configuration, CocoaPods setup
- **`web/`** - Web app configuration, PWA manifest
- **`windows/`** - Windows desktop app configuration
- **`linux/`** - Linux desktop app configuration
- **`macos/`** - macOS desktop app configuration

---

### 6. **Configuration Files**

- **`pubspec.yaml`** - Project metadata and dependencies
- **`pubspec.lock`** - Locked dependency versions
- **`analysis_options.yaml`** - Dart linter rules
- **`devtools_options.yaml`** - DevTools configuration

---

## Key Dependencies

### UI & Theming
- `flutter_svg: ^2.0.17` - SVG rendering
- `font_awesome_flutter: ^10.9.0` - Icon library
- `cupertino_icons: ^1.0.8` - iOS-style icons

### State Management & Navigation
- `get: ^4.6.6` - GetX for state management and routing

### Internationalization
- `intl: ^0.20.1` - Multi-language support

### Device & System
- `device_info_plus: ^11.3.0` - Device information
- `package_info_plus: ^8.3.0` - App information
- `connectivity_plus: ^6.1.2` - Network connectivity
- `android_id: ^0.4.0` - Unique device ID
- `path_provider: ^2.1.5` - File system paths

### Data & Storage
- `shared_preferences: ^2.3.5` - Local storage
- `sqflite_android` - SQLite database (Android)

### Networking & Files
- `http: ^1.3.0` - HTTP requests
- `file_picker: ^9.1.0` - File selection
- `image_picker: ^1.1.2` - Image selection
- `url_launcher: ^6.3.1` - URL launching
- `open_file: ^3.5.10` - File opening

### Media & Display
- `cached_network_image: ^3.4.1` - Image caching
- `video_player_android` - Video playback
- `carousel_slider: ^5.1.1` - Image carousel
- `flutter_html: ^3.0.0` - HTML rendering
- `flutter_inappwebview: ^6.1.5` - WebView
- `webview_flutter: ^4.4.2` - Alternative WebView

### Utilities
- `table_calendar: ^3.2.0` - Calendar widget
- `loading_animation_widget: ^1.3.0` - Loading animations
- `circle_nav_bar: ^2.2.0` - Circular navigation bar
- `slide_to_act: ^2.0.1` - Slide-to-action button
- `logger: ^2.5.0` - Logging utility
- `universal_html: ^2.2.4` - HTML compatibility
- `html_unescape: ^2.0.0` - HTML entity decoding
- `universal_io: ^2.2.2` - IO compatibility

### Features
- `in_app_update: ^4.2.3` - In-app updates
- `printing` - PDF printing

---

## Architecture Pattern

The project follows a **Layered Architecture Pattern**:

```
Presentation Layer (UI)
    ↓
Data Layer (Services & Models)
    ↓
Network Layer (HTTP Calls)
```

### Component Responsibilities

| Component | Responsibility |
|-----------|-----------------|
| **Screens** | Display UI and handle user interactions |
| **Widgets** | Reusable UI components |
| **Controllers** | State management using GetX |
| **Services** | API communication |
| **Models** | Data structures and serialization |
| **Network Caller** | HTTP client abstraction |

---

## Key Features

1. **Exam Management** - Create, solve, and review exams
2. **Course Management** - Browse and enroll in courses
3. **Progress Analytics** - Track exam performance
4. **Payment Integration** - Multiple payment gateways
5. **User Authentication** - Secure login system
6. **Notifications** - Real-time exam updates
7. **Search & Discovery** - Easy finder for questions
8. **Offline Support** - Local storage capabilities
9. **Multi-language** - Internationalization support
10. **Responsive Design** - Cross-platform compatibility

---

## Development Guidelines

### Adding a New Feature

1. **Create Model** - Add data model in `lib/data/models/`
2. **Create Service** - Add API service in `lib/data/services/`
3. **Create Screen** - Add UI screen in `lib/presentation/screens/`
4. **Create Widgets** - Reusable components in `lib/presentation/widgets/`
5. **Create Controller** - Add GetX controller if needed for state management
6. **Add Assets** - Include icons/images in `assets/`

### Code Organization
- Keep related functionality grouped together
- Use meaningful file and class names
- Follow Dart naming conventions
- Separate concerns between layers

---

## Version Information

- **Current Version:** 1.5.1+14
- **Dart SDK:** ^3.6.1
- **Latest Update:** As of project structure documentation

---

## Notes

- The app uses **GetX** for state management and routing
- API communication is centralized through `NetworkCaller`
- All HTTP calls are wrapped with `NetworkResponse`
- Extensive use of GetX dependency injection via `controller_binder.dart`
- UI components are highly modular and reusable
- The project supports multiple platforms (Android, iOS, Web, Windows, macOS, Linux)


