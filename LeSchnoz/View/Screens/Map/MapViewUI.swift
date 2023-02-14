//
//  MapViewUI.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/10/22.
//

import SwiftUI
import MapKit
import MapKitGoogleStyler


struct MapViewUI: UIViewRepresentable {
        
    @State var shouldCenterOnCurrentLocation = true
    
    @ObservedObject var exploreVM = ExploreViewModel.instance
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var geoFireManager = GeoFireManager.instance
     
    var mapView = MKMapView()
    
    var mapIsForExplore: Bool
    
    func makeUIView(context: Context) -> MKMapView {
        
        mapView.setRegion(exploreVM.searchRegion, animated: true)
        mapView.mapType = .satellite
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        mapView.delegate = context.coordinator
        
        addCorrectOverlays(to: mapView)
            
        self.configureTileOverlay()
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {

        updateRegion(mapView)
        
        addCorrectOverlays(to: mapView)
        
    }
    
    func updateRegion(_ mapView: MKMapView) {
        
        if shouldCenterOnCurrentLocation {
            
            mapView.setRegion(exploreVM.searchRegion, animated: true)
            
        }
    }
    
    func addCorrectOverlays(to mapView: MKMapView) {
                    
            mapView.addAnnotations(geoFireManager.gfOnMapLocations)
            mapView.region = exploreVM.searchRegion
            addCurrentLocation(to: mapView)
    }
    
    func addCurrentLocation(to view: MKMapView) {
        
        if let currentLocation = userStore.currentLocation {
            
            let plc = StartAnnotation(coordinate: currentLocation.coordinate, locationID: "0")
            
            view.addAnnotation(plc)
        }
    }

    
    func makeCoordinator() -> MapCoordinator {
        .init(parent: self)
    }
    
    func getRegion() -> MKCoordinateRegion {
        mapView.region
    }
    
    func setCurrentLocationRegion() {
        
        let locationServicesEnabled = UserLocationManager.instance.locationServicesEnabled
        
        if locationServicesEnabled,
           let startLoc = userStore.currentLocation {
            
            DispatchQueue.main.async {
                
                
                let span =  MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                
                self.exploreVM.searchRegion = MKCoordinateRegion(center: startLoc.coordinate, span: span)
            }
        }
    }
    
    func selectAnnotation(_ anno: MKAnnotation, animated: Bool) {
        mapView.selectAnnotation(anno, animated: animated)
    }
    
    func deselectAnnotation(_ anno: MKAnnotation, animated: Bool) {
        mapView.deselectAnnotation(anno, animated: animated)
    }
    
    //MARK: - Coordinator
    
    final class MapCoordinator: NSObject, MKMapViewDelegate {
        
        var parent: MapViewUI
        
        @ObservedObject var exploreVM = ExploreViewModel.instance
                
        init(parent: MapViewUI) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            switch annotation {
                
                case let anno as LocationAnnotationModel:
                    
                    let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "SpookySpot") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Spooky Spot")
                    annotationView.canShowCallout = true
                    annotationView.clusteringIdentifier = "cluster"
                    annotationView.markerTintColor = UIColor(K.Colors.OceanBlue.black)
                    annotationView.largeContentTitle = "Spooky Spot"
                    annotationView.titleVisibility = exploreVM.searchRegion.span.latitudeDelta <= 0.02 ? .visible : .hidden

                    annotationView.glyphImage = UIImage(named: "Ghost")
                    
                    return annotationView
    
            case _ as MKClusterAnnotation:
                
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "cluster")
                annotationView.markerTintColor = UIColor(K.Colors.OceanBlue.lightBlue)
                annotationView.titleVisibility = .hidden
                annotationView.subtitleVisibility = .hidden
                return annotationView
                
            default: return nil
                
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            
            let annotation = view.annotation
            
            switch annotation {
                
            case let locAnnotation as LocationAnnotationModel:
                
                exploreVM.showingLocationList = true
                
                exploreVM.highlightedAnnotation = locAnnotation
                
                if let loc = LocationStore.instance.onMapLocations.first(where: { "\($0.location.id)" == locAnnotation.id }) {
                    
                    exploreVM.displayedLocation = loc
                }
                
            case let cluster as MKClusterAnnotation:
                
                let coordinate = cluster.coordinate
                
                let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                
                let newRegion = MKCoordinateRegion(center: coordinate, span: span)
                
                exploreVM.searchRegion = newRegion
                
            default: return
                
            }
        }
        
        func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
            
            for anno in mapView.annotations {
                
                switch anno {
                    
                case let locAnno as LocationAnnotationModel:
                    
                    if locAnno == exploreVM.highlightedAnnotation {
                        
                        mapView.selectAnnotation(locAnno, animated: true)
                    }
                    
                default: return
                    
                }
            }
        }
                        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            
            switch overlay {
                
            case let tileOverlay as MKTileOverlay:
                
                return MKTileOverlayRenderer(tileOverlay: tileOverlay)
                
            default:
                
                return MKOverlayRenderer(overlay: overlay)
            }
        }
    }
    

    //MARK: - MapKit Style
    
    func configureTileOverlay() {
  
            guard let overlayFileURLString = Bundle.main.path(forResource: "overlay", ofType: "json") else { return }
        
            let overlayFileURL = URL(fileURLWithPath: overlayFileURLString)
            
            guard let tileOverlay = try? MapKitGoogleStyler.buildOverlay(with: overlayFileURL) else { return }
        
            tileOverlay.canReplaceMapContent = true
        
            mapView.addOverlay(tileOverlay)
        
    }
    
    

}

class TapGestureRecognizer: UITapGestureRecognizer {
    var map: MKMapView?
}
