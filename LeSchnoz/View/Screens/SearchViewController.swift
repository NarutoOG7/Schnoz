//
//  SearchViewController.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 2/21/23.
//

import UIKit
import GooglePlaces
import SwiftUI

//MARK: - Search Protocol
protocol SearchControllerDelegate {
    func placeSelected(name: String, selectedBar: SearchBarType)
}

class SearchViewController: UIViewController {
    
    private var searchContainerView: UIView?
    
    private var tableView: UITableView?
    
    private var tableDataSource: GMSAutocompleteTableDataSource?
    
    private var searchVM = SearchVM.instance
    
    private var currentBar: SearchBarType?
    
    private let userStore = UserStore.instance
            
    var delegate: SearchControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableDataSource = GMSAutocompleteTableDataSource()
        tableDataSource?.delegate = self
        
        setUpGoogleResults(controller: tableDataSource)
        
//        setUpSwiftUIView()
        setUpUIKitView()
        setUpTableView()

    }
    
    func setUpTableView() {
        tableView = UITableView(frame: CGRect(x: 0,
                                              y: 140,
                                              width: self.view.frame.size.width,
                                              height: self.view.frame.size.height))
        if let tableView = tableView {
            tableView.delegate = tableDataSource
            tableView.dataSource = tableDataSource
            view.addSubview(tableView)
        }
    }
    
    func setUpSwiftUIView() {
        searchContainerView = UIView(frame: CGRect(x: 0,
                                                   y: 20,
                                                   width: self.view.frame.size.width,
                                                   height: 120))
        if let searchContainerView = searchContainerView {
            view.addSubview(searchContainerView)


            let searchView = UIHostingController(rootView: SearchView(delegate: self, exploreVM: ExploreViewModel.instance))
            addChild(searchView)
            searchView.view.frame = searchContainerView.bounds
            searchContainerView.addSubview(searchView.view)
            searchView.didMove(toParent: self)
        }
    }
    
    func setUpUIKitView() {
        let searchView = UIKitDoubleSearchView(parent: self,
                                               frame: CGRect(x: 0,
                                                             y: 20,
                                                             width: self.view.frame.size.width,
                                                             height: 100))
        searchView.delegate = self
        view.addSubview(searchView)
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
                        
            filter.types = ["food", "bar", "bowling_alley", "movie_theater"]
                        
            controller.autocompleteFilter = filter
            controller.placeFields = fields
        }
    }
}

extension SearchViewController: GMSAutocompleteTableDataSourceDelegate {
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn the network activity indicator off.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        // Reload table data.
        tableView?.reloadData()
    }
    
    func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn the network activity indicator on.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        // Reload table data.
        tableView?.reloadData()
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        
        
        if currentBar == .place {
            // Do something with the selected place.

        } else {
            if
               let currentBar = self.currentBar,
                let name = place.name {

                searchVM.placeSearchText = name
                setUpGoogleResults(controller: tableDataSource)
                delegate?.placeSelected(name: name, selectedBar: currentBar)
            }
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
    
    func placeSourceTextChanged() {
        setUpGoogleResults(controller: tableDataSource)
        changeSearchText()
    }
    
    func areaSearchTextChanged(_ text: String) {
        let newFilter = GMSAutocompleteFilter()
        newFilter.types = ["locality"]
        tableDataSource?.autocompleteFilter = newFilter
//        changeSearchText()
        tableDataSource?.sourceTextHasChanged(text)
    }
    
    func currentBar(bar: SearchBarType) {
        self.currentBar = bar
    }
    
    func changeSearchText() {
        
        let searchVM = SearchVM.instance
        
        let placeIsEmpty = searchVM.placeSearchText == ""
        let searchIsEmpty = searchVM.areaSearchText == ""
        let bothFieldsEmpty = placeIsEmpty && searchIsEmpty
        
        if bothFieldsEmpty {
            // current location, update tabledatasource
            if let coordinates = userStore.currentLocation?.coordinate {
                FirebaseManager.instance.getAddressFrom(coordinates: coordinates) { address in
                    let text = address.city
                    self.tableDataSource?.sourceTextHasChanged(text)
                }
            }
        } else {
            tableDataSource?.sourceTextHasChanged(searchVM.areaSearchText + " " + searchVM.placeSearchText)
        }
    }
}

extension SearchViewController: SearchViewDelegate {
    func searchInputChanged(searchBar: SearchBarType, text: String) {
        tableDataSource?.sourceTextHasChanged(text)
    }
    
    
}
