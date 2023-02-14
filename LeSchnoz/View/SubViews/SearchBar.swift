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
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
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
            .foregroundColor(weenyWitch.orange)
    }
    
    private var searchField: some View {
        TextField("", text: $exploreVM.searchText)
            .placeholder(when: exploreVM.searchText == "", placeholder: {
                Text("Hotel, City, or State")
                    .font(.avenirNext(size: 16))
                    .fontWeight(.thin)
            })
        .padding()
        .font(.avenirNext(size: 18))
        .foregroundColor(weenyWitch.brown)
        .accentColor(weenyWitch.orange)
        
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
                        .foregroundColor(weenyWitch.brown)
                        .font(.avenirNext(size: 18))
                }
                .listRowBackground(Color.clear)
            }
            
        }
        .modifier(ClearListBackgroundMod())
        .frame(height: listHasNoItems ? 0 : listHeight)
        .listStyle(.inset)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(weenyWitch.lightest)
            .padding(2)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(weenyWitch.brown))
    }
    
    //MARK: - Buttons
    private var cancelButton: some View {
        Button(action: cancelSearchTapped) {
            Text("Cancel")
                .font(.avenirNext(size: 18))
                .foregroundColor(weenyWitch.brown)
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
