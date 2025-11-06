# track_my_bus

A Flutter application for real-time bus tracking.

## Features

- **Login Interface**  
  Users can securely log in to access the app.

- **Admin Panel**  
  - Register users  
  - Add buses  
  - View bus list  

- **User Registration**  
  Allows new users to sign up and create an account.

- **Add Bus and List**  
  Admin can add buses with details and view all buses in a list.

- **Error Handling**  
  Shows appropriate error messages for invalid inputs.

- **Forget Password**  
  Users can reset their password using the forget password page.

- **Real-Time Bus Tracking**  
  - Track buses in real-time using a **GPS module**.  
  - Displays live bus locations on a map.  
  - Collects and updates location data continuously for accurate tracking.

## Screenshots

**Login Interface**  
<img width="2560" height="1600" alt="Login Interface" src="https://github.com/user-attachments/assets/d5faa6f3-5b25-49f2-8880-1ab14540c747" />

**Admin Panel - User Registration**  
<img width="2560" height="1600" alt="User Registration" src="https://github.com/user-attachments/assets/d7d04adb-574a-4459-b08f-ea2f795c31b8" />

**Add Bus and List**  
<img width="2560" height="1600" alt="Add Bus and List" src="https://github.com/user-attachments/assets/3b6f63f5-104f-482c-97bb-1629d476456a" />

**Error Handling**  
<img width="2560" height="1600" alt="Invalid Input Error" src="https://github.com/user-attachments/assets/e0862bf5-421c-4428-81cf-a5054e37479d" />

**Forget Password Page**  
<img width="2560" height="1600" alt="Forget Password" src="https://github.com/user-attachments/assets/e3eda0e8-19b9-4f7e-bab5-783e2e4fd237" />

## Getting Started

If this is your first Flutter project, here are some useful resources:  

- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)  
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)  
- [Official Flutter Documentation](https://docs.flutter.dev/)

## Technical Details (GPS Tracking)

- **Packages Used:**  
  - `geolocator`: For getting the device’s current location.  
  - `google_maps_flutter`: To display the map and markers for buses.  
  - `cloud_firestore`: To store and fetch real-time bus location data.

- **How It Works:**  
  1. Each bus has a GPS module that sends location data to Firebase Firestore.  
  2. The Flutter app fetches the latest location of all buses in real-time.  
  3. The bus locations are displayed as markers on Google Maps inside the app.  
  4. Location updates are continuous, ensuring accurate tracking.

---

**Author:** Shah Abdul Mazid  
**Email:** shahabdulmazid.ezan@yahoo.com  
**GitHub:** [Shah-Abdul-Mazid](https://github.com/Shah-Abdul-Mazid)  
**LinkedIn:** [linkedin.com/in/shahabdulmazid](https://www.linkedin.com/in/shahabdulmazid/)  
**Location:** Dhaka, Bangladesh
