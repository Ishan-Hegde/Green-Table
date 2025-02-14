**Green Table**

Green Table is a SaaS application designed to reduce food wastage by connecting sources of surplus food with individuals and organizations in need. The platform facilitates the listing of leftover food, coordinates mediator pickups, and utilizes geolocation to streamline food distribution between producers and consumers. Users receive real-time updates and notifications about food availability and pickup schedules.
Features

    Food Listing: Users can list surplus food items available for donation or sale.
    Mediator Coordination: The app connects donors with mediators who facilitate the pickup and delivery of food items.
    Geolocation Integration: Utilizes geolocation to match donors and recipients based on proximity, ensuring efficient distribution.
    Real-Time Updates: Provides instant notifications about food availability, pickup schedules, and delivery statuses.
    User Authentication: Secure login and registration system for all users.
    Profile Management: Allows users to manage their profiles, including contact information and preferences.
    History Tracking: Users can view their past donations, pickups, and received items.
**
Getting Started
Prerequisites**

    Flutter SDK: Ensure that Flutter is installed on your system. You can download it from the official Flutter website.
    Dart SDK: Dart comes bundled with Flutter, but ensure it's up to date.
    Integrated Development Environment (IDE): It's recommended to use Android Studio or Visual Studio Code with Flutter and Dart plugins installed.

Installation

    Clone the Repository:

git clone https://github.com/Ishan-Hegde/Green-Table.git
cd Green-Table

Install Dependencies:

Run the following command to install the necessary packages:

flutter pub get

Run the Application:

Connect your device or start an emulator, then execute:

    flutter run

Usage

Green Table is designed for users who either have surplus food to donate/sell or are seeking to acquire such food. The application serves as a bridge between these users, ensuring efficient and timely distribution of food resources.
For Donors:

    Sign Up / Log In: Create an account or log in to your existing account.
    List Surplus Food: Navigate to the "Add Listing" section and provide details about the food items you wish to donate or sell, including quantity, description, and pickup location.
    Manage Listings: View, edit, or delete your active listings as needed.
    Coordinate with Mediators: Once a mediator is assigned, communicate with them to arrange pickup details.
    Track Donations: Monitor the status of your listed items and receive notifications upon successful pickups.

For Recipients:

    Sign Up / Log In: Create an account or log in to your existing account.
    Browse Available Listings: View a list of available food items based on your location.
    Request Items: Select desired items and send a request to the donor.
    Coordinate Pickup: Once approved, coordinate with the mediator or donor for pickup details.
    Provide Feedback: After receiving the items, provide feedback to help improve the platform.

Project Structure

The project follows a structured directory layout:

    lib/: Contains the main source code.
        main.dart: Entry point of the application.
        models/: Data models used throughout the app.
        screens/: UI screens for different parts of the app.
        services/: Backend services like authentication, database interactions, etc.
        widgets/: Reusable UI components.
    assets/: Contains images, fonts, and other assets.
    test/: Contains unit and widget tests.

Contributing

We welcome contributions to enhance Green Table. To contribute:

    Fork the Repository: Click on the 'Fork' button at the top right of the repository page.

    Create a New Branch: Use a descriptive name for your branch.

git checkout -b feature/YourFeatureName

Make Changes: Implement your feature or fix.

Commit Changes: Write clear and concise commit messages.

git commit -m 'Description of your feature or fix'

Push to Branch:

    git push origin feature/YourFeatureName

    Create a Pull Request: Navigate to the original repository and open a pull request with a detailed description of your changes.

License

This project is licensed under the MIT License. See the LICENSE file for more details.
