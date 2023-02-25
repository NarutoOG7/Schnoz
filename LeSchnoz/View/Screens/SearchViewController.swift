//
//  SearchViewController.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 2/21/23.
//

import UIKit
import GooglePlaces

class SearchViewController: UIViewController {
    
    private var tableView: UITableView!
    
    private var tableDataSource: GMSAutocompleteTableDataSource?
    
    private var exploreVM = ExploreViewModel.instance
    
    private var currentBar: SearchBarType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableDataSource = GMSAutocompleteTableDataSource()
        tableDataSource?.delegate = self
        
        setUpGoogleResults(controller: tableDataSource)
        
        let searchView = UIKitDoubleSearchView(frame: CGRect(x: 0, y: 65, width: view.bounds.width, height: 100))
        searchView.delegate = self
        view.addSubview(searchView)
        
        tableView = UITableView(frame: CGRect(x: 0, y: 264, width: self.view.frame.size.width, height: self.view.frame.size.height - 44))
        tableView.delegate = tableDataSource
        tableView.dataSource = tableDataSource
        
        view.addSubview(tableView)
    }
    
    
    func setUpGoogleResults(controller: GMSAutocompleteTableDataSource?) {
        
        if let controller = controller {
            
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
            filter.types = ["food", "bar", "bowling_alley", "movie_theater"]
            
            controller.autocompleteFilter = filter
            controller.placeFields = fields
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

extension SearchViewController: GMSAutocompleteTableDataSourceDelegate {
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn the network activity indicator off.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        // Reload table data.
        tableView.reloadData()
    }
    
    func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn the network activity indicator on.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        // Reload table data.
        tableView.reloadData()
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        // Do something with the selected place.
        if currentBar == .place {
            
        } else {
            
        }
        
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
        // Handle the error.
        print("Error: \(error.localizedDescription)")
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        return true
    }
}


extension SearchViewController: DoubleSearchDelegate {
    
    func placeSourceTextChanged(_ text: String) {
        setUpGoogleResults(controller: tableDataSource)
        tableDataSource?.sourceTextHasChanged(text)
    }
    
    func areaSearchTextChanged(_ text: String) {
        let newFilter = GMSAutocompleteFilter()
        newFilter.types = ["locality"]
        tableDataSource?.autocompleteFilter = newFilter
        tableDataSource?.sourceTextHasChanged(text)
    }
    
    func currentBar(bar: SearchBarType) {
        self.currentBar = bar
    }
}

