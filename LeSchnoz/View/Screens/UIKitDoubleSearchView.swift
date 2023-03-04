//
//  UIKitDoubleSearchView.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 2/20/23.
//

import UIKit
import SwiftUI
import CoreLocation
import CoreLocationUI

class SearchVM: ObservableObject {
    static let instance = SearchVM()
    
    @Published var shouldShowSearchView = false
    @Published var placeSearchText = ""
    @Published var areaSearchText = ""
    
    func getDefaultSearchTextFromCurrentLocation(onCompletion: @escaping(String) -> Void) {
        if let coordinates = UserStore.instance.currentLocation?.coordinate {
            FirebaseManager.instance.getAddressFrom(coordinates: coordinates) { address in
                onCompletion(address.city)
            }
        }
    }
}

class UIKitDoubleSearchView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var placeSearchBar: UISearchBar!
    @IBOutlet weak var areaSearchBar: UISearchBar!
    @IBOutlet weak var backButton: UIButton!
    
    private var currentBar: SearchBarType?
    
    var delegate: DoubleSearchDelegate?
    
    var parent: SearchViewController?
    
    var width: CGFloat?
    
    let searchVM = SearchVM.instance
    let exploreVM = ExploreViewModel.instance
    let userLocManager = UserLocationManager.instance
        
    init(parent: SearchViewController, frame: CGRect) {
//        let frame = CGRect(x: 0, y: 65, width: width, height: 100)
        super.init(frame: frame)
        self.parent = parent
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    
    private func commonInit() {
        Bundle.main.loadNibNamed("UIKitDoubleSearchView", owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        placeSearchBar.delegate = self
        areaSearchBar.delegate = self
        parent?.delegate = self
        
       searchVM.getDefaultSearchTextFromCurrentLocation(onCompletion: { text in
           self.searchVM.areaSearchText = text
           self.delegate?.placeSourceTextChanged()
        })
    }
    
    //MARK: - IBAction
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        withAnimation {
            exploreVM.showSearchTableView = false
        }
    }
}

extension UIKitDoubleSearchView: UISearchBarDelegate {
    
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      
      if searchBar == placeSearchBar {
          searchVM.placeSearchText = searchText
          delegate?.placeSourceTextChanged()
          
      } else {
          delegate?.areaSearchTextChanged(searchText)
          
          /*   Acts As Cancel Tapped   */
            searchVM.areaSearchText = ""
          
          if searchText == "" {
              searchVM.getDefaultSearchTextFromCurrentLocation { text in
                  self.searchVM.placeSearchText = text
                  self.delegate?.placeSourceTextChanged()
              }
          }

      }
  }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar == placeSearchBar {
            delegate?.currentBar(bar: .place)
        } else if searchBar == areaSearchBar {
            delegate?.currentBar(bar: .area)
        }
    }
     
}

extension UIKitDoubleSearchView: SearchControllerDelegate {
    
    func placeSelected(name: String, selectedBar: SearchBarType) {
        if selectedBar == .place {
            placeSearchBar.text = name
            searchVM.placeSearchText = name
        } else {
            searchVM.areaSearchText = name
            areaSearchBar.text = name
            areaSearchBar.endEditing(true)
            delegate?.currentBar(bar: .place)
            delegate?.placeSourceTextChanged()
        }
    }
}


protocol DoubleSearchDelegate {
    func placeSourceTextChanged()
    func areaSearchTextChanged(_ text: String)
    func currentBar(bar: SearchBarType)
}

enum SearchBarType {
    case place, area
}
