# Royal Badminton Club iOS App

Welcome to the **Royal Badminton Club** app! This application provides a premium, "Liquid Design" experience for badminton enthusiasts to book courts, join drop-in sessions, and manage their activities.

## 📱 Features

### 1. **Liquid Design System**
The app is built using a custom "Royal Liquid" design language, featuring:
-   **Glassmorphism**: Translucent cards with blur effects.
-   **Vibrant Gradients**: Custom Royal Blue and Green gradients.
-   **Haptic Feedback**: Subtle vibrations for tactile interaction.
-   **Fluid Animations**: Smooth transitions between states.

### 2. **Court Booking**
A streamlined flow to find and book courts.
-   **Dashboard**: Personalized greeting with live club status (Active Courts, Weather).
-   **Smart Scheduling**: Slots organized by **Morning**, **Afternoon**, and **Evening**.
-   **Dynamic Pricing**: Rates adjust automatically based on Weekdays vs. Weekends and Time of Day.
-   **Real-Time Checks**: Tap any slot to instantly check server availability.
-   **Simulated Payments**: Integrated Stripe-style checkout for booking confirmation.

### 3. **Drop-In Sessions**
Join casual play groups without booking a full court.
-   **Fixed Slots**: Daily sessions (e.g., 5-7 PM, 8-10 PM).
-   **Activation Logic**: Sessions remain "Open" until **6 players** join. Once filled, the system automatically books the required courts.
-   **Payment Holds**: Authorize a $15 hold that captures only when the session activates.
-   **Transparency**: Tap any session card to see the list of joined players and their status.

## 🛠 Tech Stack
-   **Language**: Swift 5
-   **Framework**: SwiftUI
-   **Architecture**: MVVM (Model-View-ViewModel)
-   **Networking**: Combine Framework (simulated API calls)
-   **Payment**: Simulated Stripe integration

## 🧪 How to Test

### Booking a Court
1.  Navigate to the **Book** tab.
2.  Swipe the date strip to choose a day.
3.  Tap any **"Available"** (Green) slot.
4.  If available, the Payment Sheet appears. Enter details and pay.
5.  If full, an alert will notify you.

### Testing Drop-In Logic
1.  Navigate to the **Drop-In** tab.
2.  **View Players**: Tap the white area of any card to see who is joined.
3.  **Simulate Traffic**: Tap the small **Orange Person Icon** (Debug button) to instantly add 5 dummy players.
4.  **Join**: Tap the blue **"Join"** button. enter your name.
5.  **Trigger**: As the 6th player, you will trigger the "Activation" logic, changing the status to "Confirmed" (Green) if courts are available.

## 📍 Locations
-   **Main Location**: McLaughlin
-   **Secondary**: Mayfield
-   Switch locations using the dropdown in the main header.

---
*Developed for Royal Badminton Club.*
