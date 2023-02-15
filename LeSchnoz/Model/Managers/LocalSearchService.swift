//
//  LocalSearchService.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import Combine
import MapKit
import Contacts

class LocalSearchService: ObservableObject {
    
    static let instance = LocalSearchService()
    
    @Published var locationsList: [MKMapItem] = []
    
    @ObservedObject var errorManager = ErrorManager.instance
    
    func performSearch(from text: String, withCompletion completion: @escaping ((_ item: MKMapItem) -> (Void))) {
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        searchRequest.pointOfInterestFilter = .includingAll
        searchRequest.resultTypes = .pointOfInterest
        
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { (response, error) in
            
            if let error = error {
                if error.localizedDescription.contains("network") {
                    print(error.localizedDescription)
                    self.errorManager.message = "Connection issues. Please try again."
                    self.errorManager.shouldDisplay = true
                }
            }
            
            guard let response = response else { return }
            
            for item in response.mapItems {
                
                completion(item)
                
            }
        }
    }
}

