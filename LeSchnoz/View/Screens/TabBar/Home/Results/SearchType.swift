//
//  SearchType.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 3/31/23.
//

import SwiftUI
import GooglePlaces

enum SearchType: String, CaseIterable {
    case all, breakfast, lunch, dinner
    
    var field: GMSPlaceField {
        switch self {
        case .all:
            return .dineIn
        case .breakfast:
            return .servesBreakfast
        case .lunch:
            return .servesLunch
        case .dinner:
            return .servesDinner
        }
    }
    
    var image: Image {
        let images = K.Images.SearchTypes.self
        switch self {
            case .all:
            return images.blueAll
        case .breakfast:
            return images.blueBreakfast
        case .lunch:
            return images.blueLunch
        case .dinner:
            return images.blueDinner
        }
    }
    
    var hasEmptyBucket: Bool {
        let listResultsVM = ListResultsVM.instance
        switch self {
        case .all:
            return listResultsVM.nearbyPlaces.isEmpty
        case .breakfast:
            return listResultsVM.breakfastPlaces.isEmpty
        case .lunch:
            return listResultsVM.lunchPlaces.isEmpty
        case .dinner:
            return listResultsVM.dinnerPlaces.isEmpty
        }
    }
    
    var places: [SchnozPlace] {
        let listResultsVM = ListResultsVM.instance
        switch self {
        case .all:
            return listResultsVM.nearbyPlaces
        case .breakfast:
            return listResultsVM.breakfastPlaces
        case .lunch:
            return listResultsVM.lunchPlaces
        case .dinner:
            return listResultsVM.dinnerPlaces
        }
    }
    
    func addPlacesToBucket(_ places: [SchnozPlace]) {
        let listResultsVM = ListResultsVM.instance
        switch self {
        case .all:
            listResultsVM.nearbyPlaces = places
        case .breakfast:
            listResultsVM.breakfastPlaces = places
        case .lunch:
            listResultsVM.lunchPlaces = places
        case .dinner:
            listResultsVM.dinnerPlaces = places
        }
    }
}
