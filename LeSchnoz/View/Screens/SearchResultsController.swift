//
//  SearchResultsController.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 2/18/23.
//

import UIKit
import GooglePlaces
import SwiftUI

class SearchResultsController: UIViewController {
    
    var resultsController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
//    var resultsView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsController = GMSAutocompleteResultsViewController()
        resultsController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsController)
        searchController?.searchResultsUpdater = resultsController
        
//        let subView = UIView(frame: CGRect(x: 0, y: 65, width: 350, height: 45))
//        subView.addSubview((searchController?.searchBar)!)
        
//        let subView = UIHostingController(rootView: DoubleSearchView(exploreVM: ExploreViewModel.instance))
//        addChild(subView)
//        subView.view.frame = view.bounds
        
        let subView = UIKitDoubleSearchView(frame: CGRect(x: 0, y: 65, width: view.bounds.width, height: 200))
        subView.delegate = self
        view.addSubview(subView)
        
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false

//        navigationItem.titleView = searchController?.searchBar
        
        
        
        navigationController?.navigationBar.isTranslucent = false
        searchController?.hidesNavigationBarDuringPresentation = false

        // This makes the view area include the nav bar even though it is opaque.
        // Adjust the view placement down.
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = .top
        
        // When UISearchController presents the results view, present it in this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
    }
    
}


//MARK: - GMSAutocomplet Results Delegate
extension SearchResultsController: GMSAutocompleteResultsViewControllerDelegate {
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // TODO: do something with selected place
    }
    
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle error
    }
    
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        // TODO: this is deprecated, use new network manager
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        // TODO: this is deprecated, use new network manager
    }
}

extension SearchResultsController: DoubleSearchDelegate {
    func currentBar(bar: SearchBarType) {
//        <#code#>
    }
    
    func placeSourceTextChanged(_ text: String) {
//        <#code#>
    }
    
    func areaSearchTextChanged(_ text: String) {
//        <#code#>
    }
    
    
    func sourceTextHasChanged(_ text: String) {
//        resultsController?.
    }
    
}
