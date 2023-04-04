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

class AppDelegate: NSObject, UIApplicationDelegate {
    
    private var signedInUser = UserDefaults.standard.data(forKey: K.UserDefaults.user)
    private var isGuest = UserDefaults.standard.data(forKey: K.UserDefaults.isGuest)
    
    @ObservedObject var locationManager = UserLocationManager.instance
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var errorManager = ErrorManager.instance
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        GMSPlacesClient.provideAPIKey("AIzaSyBPTme7RzG4HL4VglZEZW96f1BXMb3CT_4")
     
        locationManager.checkIfLocationServicesIsEnabled()

        getUserIfSignedIn()
        
        checkIfIsGuest()

        return true
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
    

}
