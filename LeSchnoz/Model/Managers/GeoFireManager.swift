//
//  GeoFireManager.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/27/22.
//

import SwiftUI
import GeoFire


class GeoFireManager: ObservableObject {
    
    static let instance = GeoFireManager()
    
    @Published var gfNearbyLocations: [LocationAnnotationModel] = []
    @Published var gfOnMapLocations: [LocationAnnotationModel] = []
    
    @ObservedObject var firebaseManager = FirebaseManager.instance
    @ObservedObject var locationStore = LocationStore.instance
    
    @EnvironmentObject var exploreVM: ExploreViewModel
    
    lazy var locationRef = Database.database().reference().child("Haunted Hotels")
    
    var locationHandle: DatabaseHandle?
    
    func getNearbyLocations(region: MKCoordinateRegion, radius: Double) {
        
        if UserStore.instance.currentLocation != nil {
            
            let geoLocRef = GeoFire(firebaseRef: locationRef)
            let regionCenter = region.center
            let cllocation = CLLocation(latitude: regionCenter.latitude, longitude: regionCenter.longitude)
            let circleQuery = geoLocRef.query(at: cllocation, withRadius: radius)
            
            circleQuery.observe(.keyEntered, with: { key, loc in
                
                self.firebaseManager.getHotelWithReviews(key) { locModel in
                    
                    let anno = LocationAnnotationModel(coordinate: loc.coordinate, locationID: key, title: "👻")
                    
                    if !self.gfNearbyLocations.contains(where: { $0.id == key }) {
                        
                        self.gfNearbyLocations.append(anno)
                        
                        if !self.locationStore.nearbyLocations.contains(where: { "\($0.location.id)" == key }) {
                            
                            self.locationStore.nearbyLocations.append(locModel)
                        }
                    }
                }
            })
        }
    }
    
    
    //MARK: - Location Listener
    func startLocationListener(region: MKCoordinateRegion) {
        
        let geoLocRef = GeoFire(firebaseRef: locationRef)
        let regionCenter = region.center
        let radius = region.distanceMax() / 2
        let cllocation = CLLocation(latitude: regionCenter.latitude, longitude: regionCenter.longitude)
        let circleQuery = geoLocRef.query(at: cllocation, withRadius: radius)
        
        locationHandle = circleQuery.observe(.keyEntered, with: { key, loc in
            
            self.firebaseManager.getHotelWithReviews(key) { locModel in
                
                let anno = LocationAnnotationModel(coordinate: loc.coordinate, locationID: key, title: locModel.location.name)
                
                if !self.gfOnMapLocations.contains(where: { $0.id == key }) {
                    
                    self.gfOnMapLocations.append(anno)
                    
                    if !self.locationStore.onMapLocations.contains(where: { "\($0.location.id)" == key }) {
                        
                        self.locationStore.onMapLocations.append(locModel)
                    }
                }
            }
        })
    }
    
    func endLocationListener() {
        
        if let locationHandle = locationHandle {
            
            locationRef.removeObserver(withHandle: locationHandle)
        }
    }
    
    
    //MARK: - GeoFire wire into Real Time Database
    
    ///  This should only be accessible by  admin
    func createSpookySpotForLocation(_ location: LocationModel, withCompletion completion: @escaping(Bool) -> Void) {
        
        let geoLocRef = GeoFire(firebaseRef: locationRef)
        
        firebaseManager.getCoordinatesFromAddress(address: location.location.address?.geoCodeAddress() ?? "") { cloc in
            
            geoLocRef.setLocation(cloc, forKey: "\(location.location.id)") { error in
                
                if let error = error {
                    print(error)
                    completion(false)
                }
                
                completion(true)
            }
        }
    }
}

//MARK: - Get map region radius

extension MKCoordinateRegion {
    
    func distanceMax() -> CLLocationDistance {
        
        let furthest = CLLocation(latitude: center.latitude + (span.latitudeDelta/2),
                                  longitude: center.longitude + (span.longitudeDelta/2))
        
        let centerLoc = CLLocation(latitude: center.latitude, longitude: center.longitude)
        
        return (centerLoc.distance(from: furthest) / 1609.344) * 2
    }
}
