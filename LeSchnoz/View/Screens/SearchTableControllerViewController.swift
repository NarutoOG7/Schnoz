//
//  SearchTableControllerViewController.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 2/20/23.
//

import UIKit
import GooglePlaces

class SearchTableControllerViewController: UIViewController {

      private var tableView: UITableView!
      private var tableDataSource: GMSAutocompleteTableDataSource!

      override func viewDidLoad() {
        super.viewDidLoad()
          

        tableDataSource = GMSAutocompleteTableDataSource()
        tableDataSource.delegate = self

        
        let searchView = UIKitDoubleSearchView(frame: CGRect(x: 0, y: 65, width: view.bounds.width, height: 200))
          searchView.delegate = self
          view.addSubview(searchView)
          
        tableView = UITableView(frame: CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height - 44))
        tableView.delegate = tableDataSource
        tableView.dataSource = tableDataSource

        view.addSubview(tableView)
      }
    }

    extension SearchTableControllerViewController: GMSAutocompleteTableDataSourceDelegate {
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
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
      }

      func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
        // Handle the error.
        print("Error: \(error.localizedDescription)")
      }

      func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        return true
      }
    }


extension SearchTableControllerViewController: DoubleSearchDelegate {
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
        tableDataSource.sourceTextHasChanged(text)
    }
}
