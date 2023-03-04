//
//  ExploreByListVM.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import MapKit
import Contacts
import GooglePlaces

class ExploreViewModel: ObservableObject {
    
    static let instance = ExploreViewModel()
    
    @Published var showSearchTableView = false

    
    @Published var showingLocationList = false
    @Published var showingSearchLocations = false
    
    @Published var searchedLocations: [LocationModel] = []
    @Published var searchRegion = MapDetails.defaultRegion
    
    @Published var showingSearchController = false

    @Published var selectedPlace: GMSPlace?

    @ObservedObject var locationStore = LocationStore.instance
    @ObservedObject var userLocManager = UserLocationManager.instance
    @ObservedObject var errorManager = ErrorManager.instance
    
    func locServiceIsEnabled() -> Bool {
        userLocManager.locationServicesEnabled
    }
    
    //MARK: - Greeting Logic
    
    func greetingLogic() -> String {
        
      let hour = Calendar.current.component(.hour, from: Date())
      
      let morning = 0
      let noon = 12
      let sunset = 18
      let midnight = 24
      
      var greetingText = "Hello"
        
      switch hour {
          
      case morning..<noon:
          greetingText = "Good Morning"
          
      case noon..<sunset:
          greetingText = "Good Afternoon"
          
      case sunset..<midnight:
          greetingText = "Good Evening"

      default:
          _ = "Hello"
      }
      
      return greetingText
    }
    
    //MARK: - Swipe Locations List
    
    enum SwipeDirection {
        case backward, forward
    }
}
