//
//  PlacesViewControllerBridge.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 2/14/23.
//

import SwiftUI
import GooglePlaces

struct PlacesViewControllerBridge: UIViewControllerRepresentable {
    
    @ObservedObject var exploreVM = ExploreViewModel.instance
    
    var onPlaceSelected: (GMSPlace) -> ()
    //var selectedPlaceByFilter: GMSPlace
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PlacesViewControllerBridge>) -> GMSAutocompleteViewController {
     let uiViewControllerPlaces = GMSAutocompleteViewController()
        
        uiViewControllerPlaces.navigationController?.navigationBar.tintColor = UIColor.yellow
        uiViewControllerPlaces.delegate = context.coordinator
        
        let fields: GMSPlaceField = GMSPlaceField(rawValue:UInt(GMSPlaceField.name.rawValue) |
                    UInt(GMSPlaceField.placeID.rawValue) |
                    UInt(GMSPlaceField.coordinate.rawValue) |
                    GMSPlaceField.addressComponents.rawValue |
                    GMSPlaceField.formattedAddress.rawValue |
                    GMSPlaceField.types.rawValue)
        
        let filter = GMSAutocompleteFilter()
        
        let location = exploreVM.searchLocation
        self.geocodeAddressToCoordinates(location) { coordinates in
            filter.locationBias = GMSPlaceRectangularLocationOption(coordinates, coordinates)
        } onError: { error in
            if let error = error {
                // TODO: handle error
            }
        }

//        let neBounds = CLLocationCoordinate2D(latitude: 45.54100, longitude: -111.09229)
//        filter.locationBias = GMSPlaceRectangularLocationOption(neBounds, neBounds)
        
        filter.types = ["food", "bar", "bowling_alley", "movie_theater"]

//        
        uiViewControllerPlaces.autocompleteFilter = filter
        
        uiViewControllerPlaces.placeFields = fields
//        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
//                                                  UInt(GMSPlaceField.placeID.rawValue))
        return uiViewControllerPlaces
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }
    
    func makeCoordinator() -> PlacesViewAutoCompleteCoordinator {
        return PlacesViewAutoCompleteCoordinator(placesViewControllerBridge: self)
    }
    
    final class PlacesViewAutoCompleteCoordinator: NSObject, GMSAutocompleteViewControllerDelegate {

        var placesViewControllerBridge: PlacesViewControllerBridge
        
        init(placesViewControllerBridge: PlacesViewControllerBridge) {
            self.placesViewControllerBridge = placesViewControllerBridge
        }
        
        func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace)
        {
            print("Place name: \(place.name ?? "Default Place")")
            print("Place ID: \(place.placeID ?? "Default PlaceID")")
            print("Place attributions: \(String(describing: place.attributions))")
            viewController.dismiss(animated: true)
            self.placesViewControllerBridge.onPlaceSelected(place)
        }
        
        func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error)
        {
            print("Error: ", error.localizedDescription)
        }
        
        func wasCancelled(_ viewController: GMSAutocompleteViewController) {
            print("Place prediction window cancelled")
            viewController.dismiss(animated: true)
        }
        
        func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
    }
    
    func geocodeAddressToCoordinates(_ address: String,
                                     withCompletion completion: @escaping(CLLocationCoordinate2D) -> Void,
                                     onError: @escaping(Error?) -> Void) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                // handle no location found
                onError(error)
                return
            }
            
            // Use location
            completion(location.coordinate)

        }
    }
}
