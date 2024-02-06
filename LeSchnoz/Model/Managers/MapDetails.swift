//
//  MapDetails.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/11/22.
//

import MapKit

enum MapDetails {
    static let startingLocation = CLLocation(latitude: 45.677, longitude: -111.0429)
    static let startingLocationName = "Bozeman"
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
    static let defaultRegion = MKCoordinateRegion(center: startingLocation.coordinate, span: defaultSpan)
}
