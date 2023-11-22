//
//  UserLocationManager.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import MapKit
import SwiftUI
import AVFAudio

class UserLocationManager: NSObject, ObservableObject {
    
    static let instance = UserLocationManager()
        
    @Published var locationServicesEnabled = false
    
    @Published var region = MKCoordinateRegion(
        center: .init(latitude: 37.334_900, longitude: -122.009_020),
        span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var errorManager = ErrorManager.instance
    
    private let locationManager = CLLocationManager()
//    var firebaseManager = FirebaseManager.instance
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = CLLocationDistance(15)
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        self.checkLocationAuthorization()
    }

    
//    func checkIfLocationServicesIsEnabled() {
//        
////        DispatchQueue.global().async {
//            
//            
//            if CLLocationManager.locationServicesEnabled() {
//                
//                //        if locationServicesEnabled {
//                
//                let locManager = CLLocationManager()
//                locManager.activityType = .automotiveNavigation
//                locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//                locManager.delegate = self
//                
//                self.locationManager = locManager
//                
//            } else {
//                self.errorManager.message = "You have denied the app permission to use your location."
//                self.errorManager.shouldDisplay = true
//                self.checkLocationAuthorization()
//            }
////        }
//    }
    
    private func checkLocationAuthorization() {
                
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            print("DEBUG: Not Determined")
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted:
            print("DEBUG: Restricted")
            errorManager.message = "Your location is restricted likely due to parental controls."
            errorManager.shouldDisplay = true
            
            locationServicesEnabled = false
            
        case .denied:
            print("DEBUG: Denied")
            errorManager.message = "You have denied this app location permission. Go into your settings to change it."
            errorManager.shouldDisplay = true
            
            locationServicesEnabled = false
            
        case .authorizedAlways, .authorizedWhenInUse:
            print("DEBUG: Auth when in use")
            
            if let currentLoc = locationManager.location {
                locationManager.startUpdatingLocation()
                locationServicesEnabled = true
                
                userStore.currentLocation = currentLoc

            }
        @unknown default:
            break
        }
    }
    
//    func requestLocation() {
//        locationManager.requestLocation()
//    }
    
}


//MARK: - LocationManagerDelegate

extension UserLocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
//
        print("Paused")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            region = MKCoordinateRegion(
                center: $0.coordinate,
                span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        userStore.currentLocation = locations.last
        ListResultsVM.instance.currentLocationChanged = true
        print(locations.last?.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    //MARK: - Handling user loction choice
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        checkLocationAuthorization()
    }
    
}
