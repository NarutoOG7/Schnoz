//
//  LocationAnnotationModel.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/25/22.
//

import SwiftUI
import MapKit

class LocationAnnotationModel: NSObject, Identifiable, MKAnnotation {

    var coordinate = CLLocationCoordinate2D()
    var id: String
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, locationID: String, title: String) {
        self.coordinate = coordinate
        self.id = locationID
        self.title = title
    }
}

