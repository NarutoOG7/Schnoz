//
//  NotificationManager.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 11/20/23.
//

import Foundation
import UserNotifications

class NotificationManager {
    
    static let instance = NotificationManager()
    
    func notify() {
        let content = UNMutableNotificationContent()
        content.title = "Are you dining at Jimmy Johns?"
        content.subtitle = "Would you like to leave a review?"
        content.sound = UNNotificationSound.default

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)           
    }
}
