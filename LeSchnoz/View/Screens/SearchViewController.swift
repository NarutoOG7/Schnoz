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
                    
            switch currentBar {
                
            case .place:
                placeSelected(place)
            case .area:
                areaPlaceSelected(place)
            case .none:
                placeSelected(place)
            }
    }
    
    func placeSelected(_ place: GMSPlace) {
        
        // Fetch reviews from FIREBASE
        FirebaseManager.instance.getReviewsForLocation(place) { reviews in
            let schnozPlace = SchnozPlace(gmsPlace: place)
            schnozPlace.schnozReviews = reviews
            
            // Do something with the selected place.
            let hostingVC = UIHostingController(rootView: LD(location: schnozPlace))
            self.present(hostingVC, animated: true)
            
            self.tableView?.reloadData()
        }
        

    }
    
    func areaPlaceSelected(_ place: GMSPlace) {
        searchVM.placeSearchText = place.name ?? ""
        setUpGoogleResults(controller: tableDataSource)
        delegate?.placeSelected(name: place.name ?? "", selectedBar: .area)
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

class SchnozPlace {
    
    init(gmsPlace: GMSPlace?) {
        if let gmsPlace = gmsPlace {
            self.gmsPlace = gmsPlace
        }
    }
    
    var gmsPlace: GMSPlace?
    
    var schnozReviews: [ReviewModel] = [] {
        willSet {
            avgRating = self.getAvgRatingIntAndString().number
            print(avgRating)
        }
    }
    
    var avgRating: Int {
        get {
            self.getAvgRatingIntAndString().number
        }
        set { }
    }
    
    func getAvgRatingIntAndString() -> (number: Int, string: String) {
        
        var avgRatingString = ""
        var avgRatingNum = 0
        
        var totalRatingNumber = 0
        var totalReviewCount = 0
        
        for review in schnozReviews {
            
            totalRatingNumber += review.rating
            totalReviewCount += 1
        }
        if totalReviewCount > 0 {
        avgRatingNum = totalRatingNumber / totalReviewCount
            avgRatingString = String(format: "%g", avgRatingNum)
            
            if avgRatingString == "" {
                avgRatingString = "(No Reviews Yet)"
            }
        }
        return (avgRatingNum , avgRatingString)
    }
    
}
