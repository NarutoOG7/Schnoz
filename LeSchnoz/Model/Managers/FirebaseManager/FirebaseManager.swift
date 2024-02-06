//
//  FirebaseManager.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import Firebase
import CoreLocation
import MapKit
import GooglePlaces
import Combine

class FirebaseManager: ObservableObject {
    
//    let constantToNeverTouch: Void = FirebaseApp.configure()
    
    static let instance = FirebaseManager()
    
    var listeners: [String: ListenerRegistration] = [:]
    
    @Published var latestReviewPublished = PassthroughSubject<DocumentSnapshot, Never>()
        
    @ObservedObject var errorManager = ErrorManager.instance
    @ObservedObject var userStore = UserStore.instance

    
    var db: Firestore?
    var listener: ListenerRegistration?
    var lastDocument: QueryDocumentSnapshot?
    var userReviewsLastDocument: QueryDocumentSnapshot?
    var locationReviewsLastDocument: QueryDocumentSnapshot?
    
    init() {
        db = Firestore.firestore()
    }
    


    
    //MARK: - Coordinates & Address
    
    func getCoordinatesFromAddress(address: String, withCompletion completion: @escaping (CLLocation) -> Void) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            
            guard
                let placemarks = placemarks,
                let loc = placemarks.first?.location
            else {
                
                self.errorManager.message = "No location found."
                self.errorManager.shouldDisplay = true
                
                print("error on forward geocoding.. getting coordinates from location address: \(address)")
                
                return
            }
            
            let lat = loc.coordinate.latitude.rounded(.up)
            let lon = loc.coordinate.longitude.rounded(.up)
            let newLoc = CLLocation(latitude: lat, longitude: lon)
            
            print(loc)
            completion(newLoc)
        }
    }
    
    
    func getAddressFrom(coordinates: CLLocationCoordinate2D, withCompletion completion: @escaping ((_ address: Address) -> (Void))) {
        
        let location  = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            
            guard
                let placemarks = placemarks,
                let location = placemarks.first
            else {
                
                self.errorManager.message = "Could not get address from these coordinates."
                self.errorManager.shouldDisplay = true
                
                return
            }
            
            if let buildingNumber = location.subThoroughfare,
               let street = location.thoroughfare,
               let city = location.locality,
               let state = location.administrativeArea,
               let zip = location.postalCode,
               let country = location.country {
                
                let address = Address(
                    address: "\(buildingNumber) \(street)",
                    city: city,
                    state: state,
                    zipCode: zip,
                    country: country)
                completion(address)
            }
        }
    }
 
    func writeTime(_ time: Date) {
        guard let db = db else { return }

        let data: [String:Any] = [ "time" : time.formatted(date: .abbreviated, time: .complete) ]
        
        db.collection("Time").document(time.formatted(date: .abbreviated, time: .complete)).setData(data, merge: true) { _ in }
    }
    
    func saveAnnotation(_ anno: MKAnnotation) {
        guard let db = db else { return }

        let data: [String:Any] = [ "latitude" : anno.coordinate.latitude,
                                   "longitude" : anno.coordinate.longitude]
        
        db.collection("Annotations").document(UUID().uuidString).setData(data, merge: true) { _ in }
    }
    
    func getAnnotations(withCompletion completion: @escaping ([MKAnnotation]?) -> (Void)) {
        
        guard let db = db else { return }

        db.collection("Annotations")
            .getDocuments { snapshot, error in
                
                if let error = error {
                    
                    print(error.localizedDescription)
                    self.errorManager.message = "Check your network connection and try again."
                    self.errorManager.shouldDisplay = true
                } else if let snapshot = snapshot {
                    
                    var annotations: [MKAnnotation] = []
                    for doc in snapshot.documents {
                        
                        let dict = doc.data()
                        
                        let latitude = dict["latitude"] as? Double ?? 0
                        let longitude = dict["longitude"] as? Double ?? 0

                        let anno = MKPointAnnotation()
                        anno.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        
                        annotations.append(anno)
                    }
                    completion(annotations)
                }
            }
    }
}

