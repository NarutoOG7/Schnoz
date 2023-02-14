//
//  SearchBar.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct SearchBar: View {
    
    @ObservedObject var exploreVM: ExploreViewModel
    
    @ObservedObject var locationStore: LocationStore
    @ObservedObject var userStore: UserStore
    @ObservedObject var firebaseManager: FirebaseManager
    @ObservedObject var errorManager: ErrorManager
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    var body: some View {
        VStack {
            HStack {
                HStack(spacing: -20) {
                    magGlass
                    searchField
                }
                cancelButton
            }
            if exploreVM.searchText != "" {
                searchResults
            }
        }
        
        .background(background)
        
    }
    
    //MARK: - SubViews
    private var magGlass: some View {
        Image(systemName: "magnifyingglass")
            .padding()
            .foregroundColor(oceanBlue.yellow)
    }
    
    private var searchField: some View {
        TextField("", text: $exploreVM.searchText)
            .placeholder(when: exploreVM.searchText == "", placeholder: {
                Text("Hotel, City, or State")
                    .font(.avenirNext(size: 16))
                    .fontWeight(.light)
                    .foregroundColor(oceanBlue.white)
            })
        .padding()
        .font(.avenirNext(size: 18))
        .foregroundColor(oceanBlue.white)
        .accentColor(oceanBlue.yellow)
        
    }
    
    private var searchResults: some View {
        let listHasMoreThanTenItems = exploreVM.searchedLocations.count > 10
        let listHasNoItems = exploreVM.searchedLocations.count == 0
        let screenHeight = UIScreen.main.bounds.height
        let listHeight = listHasMoreThanTenItems ? (screenHeight / 3) : (CGFloat(exploreVM.searchedLocations.count) * 45)
        return List {
            ForEach(0..<exploreVM.searchedLocations.count, id: \.self) { index in
                NavigationLink {
                    LD(location: $exploreVM.searchedLocations[index],
                       userStore: userStore,
                       firebaseManager: firebaseManager,
                       errorManager: errorManager)
                } label: {
                    Text(exploreVM.searchedLocations[index].location.name)
                        .foregroundColor(oceanBlue.white)
                        .font(.avenirNext(size: 18))
                }
                .foregroundColor(oceanBlue.white)
                .listRowBackground(Color.clear)
            }
            
        }
        .modifier(ClearListBackgroundMod())
        .frame(height: listHasNoItems ? 0 : listHeight)
        .listStyle(.inset)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(oceanBlue.lightBlue)
            .padding(2)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(oceanBlue.blue))
    }
    
    //MARK: - Buttons
    private var cancelButton: some View {
        Button(action: cancelSearchTapped) {
            Text("Cancel")
                .font(.avenirNext(size: 15))
                .foregroundColor(oceanBlue.white)
        }
        .opacity(exploreVM.searchText.isEmpty ? 0 : 1)
        .padding()
    }
    
    
    //MARK: - Methods
    private func cancelSearchTapped() {
        DispatchQueue.main.async {
            exploreVM.searchText = ""
            exploreVM.searchedLocations = []
        }
        
    }
}


//MARK: - Preview

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(exploreVM: ExploreViewModel(),
                  locationStore: LocationStore(),
                  userStore: UserStore(),
                  firebaseManager: FirebaseManager(),
                  errorManager: ErrorManager())
    }
}
