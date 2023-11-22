//
//  Map.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 11/20/23.
//

import SwiftUI
import _MapKit_SwiftUI

struct MapView: View {
    
    @StateObject var manager = UserLocationManager.instance

    
    var body: some View {
//        Map(coordinateRegion: $manager.region, showsUserLocation: true)
//            .edgesIgnoringSafeArea(.all)  
        
        VStack {
            Button("Request Permission") {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("All set!")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }

            Button("Schedule Notification") {
                let content = UNMutableNotificationContent()
                content.title = "Are you dining at Jimmy Johns?"
                content.subtitle = "Would you like to leave a review?"
                content.sound = UNNotificationSound.default

                // show this notification five seconds from now
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                // choose a random identifier
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                // add our notification request
                UNUserNotificationCenter.current().add(request)            }
        }
    }
}

#Preview {
    MapView()
}
