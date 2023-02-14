//
//  StartAnnotation.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/12/22.
//

import MapKit

class StartAnnotation: NSObject, Identifiable, MKAnnotation {
    
    var coordinate = CLLocationCoordinate2D()
    var id: String
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, locationID: String) {
        self.coordinate = coordinate
        self.id = locationID
        self.title = "START"
    }
}
