# Application Architecture

This document outlines the scaffolded application structure, which follows the MVVM (Model-View-ViewModel) pattern.

```
wishi_app/
└── lib/
    ├── main.dart              # App entry point, initializes Firebase and Riverpod.
    │
    ├── data/                  # (The 'Model' part of MVVM)
    │   ├── models/
    │   │   ├── category.dart    # Data model for a menu category.
    │   │   └── menu_item.dart   # Data model for a single menu item.
    │   │
    │   └── repositories/      # (Placeholder for data source abstractions).
    │
    ├── application/           # Core business logic, independent of UI.
    │   └── services/
    │       ├── analytics_service.dart # Handles sending analytics events.
    │       └── firestore_service.dart # Handles all communication with the database.
    │
    └── presentation/          # (The 'View' and 'ViewModel' parts of MVVM)
        ├── views/
        │   └── home_screen.dart   # UI for the home screen (a 'View').
        │
        ├── viewmodels/
        │   └── home_viewmodel.dart # State and business logic for the HomeScreen (a 'ViewModel').
        │
        └── widgets/             # (Placeholder for reusable UI components, e.g., custom containers).
```

### Explanation of Layers:

*   **`data`**: This layer holds your data models (the structure of your data) and repositories (which will fetch/send data). It is the "Model".
*   **`application`**: This layer contains services that perform specific tasks, like talking to Firebase.
*   **`presentation`**: This layer is responsible for everything the user sees and interacts with.
    *   **`views`**: The UI screens. They are kept simple and only react to state changes.
    *   **`viewmodels`**: They hold the state and business logic for the views. When a user taps a button in a `View`, the `ViewModel` does the work and updates the state, causing the `View` to rebuild.
