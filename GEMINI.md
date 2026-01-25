# Application Architecture

This document outlines the scaffolded application structure, which follows the MVVM (Model-View-ViewModel) pattern.
 
 ```
 wishi_app/
 └── lib/
     ├── main.dart              # App entry point, initializes Firebase and Riverpod.
     │
     ├── domain/                # Core business logic and entities. Framework-independent.
     │   ├── entities/          # Plain Dart objects representing business models (e.g., MenuItem, User).
     │   └── repositories/      # Abstract classes defining contracts for data layers (e.g., IMenuRepository).
     │
     ├── application/           # Core business logic, independent of UI.
     │   └── services/
     │       ├── analytics_service.dart # Handles sending analytics events.
     │
     ├── data/                  # Data sources and implementation of domain repositories.
     │   ├── models/            # Data Transfer Objects (DTOs) for serialization (e.g., from Firestore).
     │   └── repositories/      # Concrete implementation of the repository contracts from the domain layer.
     │       └── firestore_service.dart # Handles all communication with Firestore.
     │
     └── presentation/          # (The 'View' and 'ViewModel' parts of MVVM)
         ├── views/
         │   └── home/
         │       └── home_screen.dart   # UI for the home screen (a 'View').
         │
         ├── viewmodels/
         │   └── home_viewmodel.dart  # State and business logic for the HomeScreen (a 'ViewModel').
         │
         └── widgets/               # Reusable UI components shared across multiple views.
 ```

### Explanation of Layers:

*   **`domain`**: This is the core of your application. It contains the business logic and rules.
    *   **`entities`**: These are the plain Dart objects that represent the core concepts of your business (e.g., `MenuItem`, `Order`). They have no knowledge of where the data comes from.
    *   **`repositories`**: These are abstract classes that define a contract for what the data layer must do (e.g., `Future<List<MenuItem>> getMenuItems()`). They allow the domain layer to be independent of the data source.

*   **`data`**: This layer is responsible for providing data to the application. It implements the repository contracts defined in the `domain` layer.
    *   **`models`**: Data Transfer Objects (DTOs) that are specific to a data source, like Firestore. They often include methods for serialization (`fromJson`, `toJson`).
    *   **`repositories`**: The concrete implementations of the repository interfaces from the domain layer. This is where you'll interact with Firebase, APIs, or local databases.

*   **`application`**: This layer contains services that provide cross-cutting functionalities, such as analytics, logging, or notifications.

*   **`presentation`**: This layer is responsible for everything the user sees and interacts with. It depends on the `domain` layer.
    *   **`views`**: The UI screens. They are kept as simple as possible, reacting to state changes from the `ViewModel`.
    *   **`viewmodels`**: They hold the state for the `View` and execute business logic by calling into the `domain` layer. When a user interacts with the UI, the `ViewModel` is notified, performs the necessary work, and updates its state, causing the `View` to rebuild.
    *   **`widgets`**: Reusable UI components that can be shared across different screens.


### Business Description:

* The app will serve a Mexican restaurant that in the day will make traditional mexican bread and during the afternoon and night will sell tacos and lonches.

### Business Requirements:

* THe menu in the home page will dinamically load the items from firebase.
* Users will choose the items and a new window with options for their order will pop up.
* IN the order builder window users will be able to create different individual orders, these orders will require a name.
* These orders will have the capacity to be shared with QR codes or sent with short links.
* Once the orders are ready, users should go to the shopping cart window and begin the payment process.
* First an order validation screen will be displayed and then the firebase with swift process.
* After the order is done, the users should receive their receipt by mail and a window to follow the order status will pop up.
* Once finished, the feedback survey will be sent by mail.
* IN the profile window, the users will be able to setup their users information and view the orders history.
* A chat in a floating button will be available with an AI agent.
* The mobile apps will be able to receive pop up with offers and deep links.
* When clicking in the items from the menu, a dialog will pop up with details about the item and the option to create a new order with that item or add to an existing order.
* Orders will be created in just one screen.
+ In the order builder, the orders saved will be displayed at the top and by clicking on it the users will be able to modify orders.
+ All options will be loaded after clicking on create a new order.