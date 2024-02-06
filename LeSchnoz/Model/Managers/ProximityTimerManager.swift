//
//  ProximityTimerManager.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 11/24/23.
//

import Foundation
import NotificationCenter

class ProximityTimerManager {
    static let instance = ProximityTimerManager()
    
    @Published var timer = Timer.publish(every: 1800, on: .main, in: .common).autoconnect()
//    @Published var timer: Timer?
    
    func initializeTimer() {
//        Timer(timeInterval: 10, repeats: false) { timer in
//            self.timer = timer
//        }
        timer = Timer.publish(every: 1800, on: .main, in: .common).autoconnect()
    }
    
    func setupNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleCustomNotification), name: .myCustomNotification, object: nil)
    }

    @objc func handleCustomNotification() {
        // Handle the notification here
        print("Custom notification received!")
    }
    
    func postCustomNotification(_ place: SchnozPlace) {
        let content = UNMutableNotificationContent()
        let placeName = place.primaryText ?? ""
        content.title = "Visiting \(placeName)?"
        content.body = "Write a review and let others know what you think!"
        content.userInfo = ["placeID" : place.placeID]
        
        // Create the trigger as a repeating event.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: trigger)


        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if let error = error {
              // Handle any errors.
               print(error.localizedDescription)
           }
        }
    }
}

extension Notification.Name {
    static let myCustomNotification = Notification.Name("MyCustomNotification")
}
