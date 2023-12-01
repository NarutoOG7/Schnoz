//
//  MapViewUI.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 11/24/23.
//

import SwiftUI
import MapKit

struct MapViewUI: UIViewRepresentable {
    
    var mapView = MKMapView()
    
    @ObservedObject var userLocManager = UserLocationManager.instance

    func makeUIView(context: Context) ->  MKMapView {
        mapView.setRegion(userLocManager.region, animated: true)
        mapView.mapType = .standard
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        
        addAnnotations(to: mapView)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        addAnnotations(to: mapView)
    }
    
    func addAnnotations(to mapView: MKMapView) {
        mapView.addAnnotations(userLocManager.annotations)
    }
}

#Preview {
    MapViewUI()
}
