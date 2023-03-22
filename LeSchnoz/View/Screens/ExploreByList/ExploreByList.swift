//
//  ExploreByList.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import GooglePlaces

struct ExploreByList: View {
    
    @Namespace var namespace
    
    @State var searchText = ""
    @State var showingSearchResults = false
    
    @State var googleSheetVisible = false
    
    @Binding var user: User
    
    @ObservedObject var exploreVM: ExploreViewModel
    @ObservedObject var locationStore: LocationStore
    @ObservedObject var userStore: UserStore
    @ObservedObject var firebaseManager: FirebaseManager
    @ObservedObject var errorManager: ErrorManager
    @ObservedObject var googlePlacesManager = GooglePlacesManager.instance
    @ObservedObject var searchVM = SearchVM.instance
    @ObservedObject var listResultsVM = ListResultsVM.instance
    
    
    @Environment(\.managedObjectContext) var moc
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    var googleTable = GoogleDataTable()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack {
                    greeting
                    searchBar
                    divider
                    searchTypeView
                }
            }
            

        }
        
    }
    
    var greeting: some View {
        let nameSizeIsLarge = user.name.count > 10
        return HStack(spacing: -7) {
            Text("\(exploreVM.greetingLogic()),")
                .font(.avenirNext(size: nameSizeIsLarge ? 20 : 27))
                .fontWeight(.thin)
                .padding(.horizontal)
                .foregroundColor(oceanBlue.blue)
                .lineLimit(1)
            Text("\(user.name)")
                .font(.avenirNext(size: nameSizeIsLarge ? 20 : 27))
                .fontWeight(.medium)
                .foregroundColor(oceanBlue.blue)
                .lineLimit(1)
            Spacer()
        }
        .padding(.top, 20)
    }
    
    private var divider: some View {
        Divider()
            .frame(height: 1.5)
            .background(oceanBlue.blue)
            .padding(.top, 12)
            .padding(.bottom, -8)
    }
    
    private var searchBar: some View {
        Button {
            withAnimation {
                exploreVM.showSearchTableView = true
            }
        } label: {
            
            RoundedRectangle(cornerRadius: 20)
                .fill(oceanBlue.lightBlue)
                .padding(2)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(oceanBlue.blue))
                .overlay {
                    Text("Bars, Restaraunts, Breweries, etc.")
                        .foregroundColor(K.Colors.OceanBlue.blue)
                        .padding(.leading, -65)
                }
                .matchedGeometryEffect(id: "bar", in: namespace)
        }
        .padding(.horizontal)
        .frame(height: 40)

    }
    
    private var searchTypeView: some View {
        HStack {
            searchTypeButton(searchType: .breakfast)
            searchTypeButton(searchType: .lunch)
            searchTypeButton(searchType: .dinner)

        }
    }
    
    private func searchTypeButton(searchType: SearchType) -> some View {
        Button {
            searchTypeTapped(searchType)
        } label: {
            Text(searchType.rawValue)
                .foregroundColor(.red)
        }

    }
    
    
    //MARK: - Methods
    
//    private func searchTypeTapped(_ searchType: SearchType) {
//        listResultsVM.searchType = searchType
//        print(searchType.rawValue)
//        GooglePlacesManager.instance.getMealType(searchType: searchType) { results, error in
//            if let error = error {
//                // TODO: Handle Error
//            }
//            if let results = results {
////                    DispatchQueue.main.async {
//
//                    listResultsVM.schnozPlaces = results
////                    }
//            }
//        }
//        ExploreViewModel.instance.showSearchTableView = true
//    }
    
    private func searchTypeTapped(_ searchType: SearchType) {
        listResultsVM.searchType = searchType
        
        NetworkServices.instance.getNearbyLocationsBySearchType(searchType)
        ExploreViewModel.instance.showSearchTableView = true
    }
    
}

struct ExplorePage_Previews: PreviewProvider {
    static var previews: some View {
        ExploreByList(user: .constant(User()),
                      exploreVM: ExploreViewModel(),
                      locationStore: LocationStore(),
                      userStore: UserStore(),
                      firebaseManager: FirebaseManager(),
                      errorManager: ErrorManager())
    }
}

