//
//  AppDelegate.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/27/22.
//

import CoreData
import SwiftUI
import Firebase
import GooglePlaces
import UserNotifications



class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

//    private var signedInUser = UserDefaults.standard.data(forKey: K.UserDefaults.user)
//    private var isGuest = UserDefaults.standard.data(forKey: K.UserDefaults.isGuest)

//    @ObservedObject var locationManager = UserLocationManager.instance
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var errorManager = ErrorManager.instance
        
    var window: UIWindow?


    func application(_ application: UIApplication, 
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        /// NEW KEY: AIzaSyBng4dC56JrOJ5Onv4hmzVypskIaHSTneE
        /// OLD KEY: AIzaSyBPTme7RzG4HL4VglZEZW96f1BXMb3CT_4
        GMSPlacesClient.provideAPIKey("AIzaSyDQv-qeylw_j-OM6PEjSRGxWkpJtvx5_JE")
        
        getUserIfSignedIn()

        checkIfIsGuest()
        
        FirebaseApp.configure()
        
        registerForPushNotifications()
        
        launchedFromNotification(launchOptions)
        return true
    }
    
    func launchedFromNotification(_ launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        // Check if launched from notification
        let notificationOption = launchOptions?[.remoteNotification]
        
        if let notification = notificationOption as? [String: AnyObject] {

            if let placeID = notification["placeID"] as? String {
                SchnozPlace.makeSchnozPlace(placeID) { schnozPlace in
                    DispatchQueue.main.async {
                        LDVM.instance.selectedLocation = schnozPlace
                        ListResultsVM.instance.shouldShowPlaceDetails = true

                    }
                    
                }
            }
        }

    }


    func getUserIfSignedIn() {

        if let data = UserDefaults.standard.data(forKey: K.UserDefaults.user) {

            do {
                let decoder = JSONDecoder()

                let user = try decoder.decode(User.self, from: data)

                userStore.user = user
            } catch {
                errorManager.shouldDisplay = true
                errorManager.message = "Error Siging In"
            }
        }
    }

    func checkIfIsGuest() {
        if let data = UserDefaults.standard.data(forKey: K.UserDefaults.isGuest) {

            do {
                let decoder = JSONDecoder()
                let isGuest = try decoder.decode(Bool.self, from: data)
                userStore.isGuest = isGuest
            } catch {
                errorManager.shouldDisplay = true
                errorManager.message = "Error Siging In"
            }
        }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
                
              print("Permission granted: \(granted)")
                
              guard granted else { return }
              self?.getNotificationSettings()
            }
    }

    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
          
          guard settings.authorizationStatus == .authorized else { return }
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
          }
      }
    }
    
    //MARK: - Notifications
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
      let token = tokenParts.joined()
      print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, 
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("Failed to register: \(error)")
    }
    
//    func application(_ application: UIApplication, 
//                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
//                     fetchCompletionHandler completionHandler: @escaping(UIBackgroundFetchResult) -> Void) {
//        
//      guard let aps = userInfo["aps"] as? [String: AnyObject] else {
//        completionHandler(.failed)
//        return
//      }
//        SchnozPlace.makeSchnozPlace(aps) { schnozPlace in
//            DispatchQueue.main.async {
//                LDVM.instance.selectedLocation = schnozPlace
//            }
//        }
//    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.banner)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        
        
        print("Here")
        let userInfo = response.notification.request.content.userInfo

        print(userInfo)
        if let aps = userInfo as? [String: AnyObject],
        let placeID = aps["placeID"] as? String {


                    SchnozPlace.makeSchnozPlace(placeID) { schnozPlace in
                        if let schnozPlace = schnozPlace {
                            DispatchQueue.main.async {
                                LDVM.instance.selectedLocation = schnozPlace
                                ListResultsVM.instance.shouldShowPlaceDetails = true
                            }
                        }
                    }
            }
        completionHandler()
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
         // Perform your background fetch tasks here
         // This is where you can update your data or perform other tasks

         // Call the completion handler when the task is complete
         completionHandler(.newData)
     }
    
}