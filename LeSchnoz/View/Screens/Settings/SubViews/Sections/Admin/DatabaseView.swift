//
//  DatabaseView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/23/22.
//

import SwiftUI

struct DatabaseView: View {
    
    @ObservedObject var locationStore: LocationStore
    
    @State var failedLocations: [LocationModel] = []
    
    @State var showingMoreAllLocations = false
    @State var showingMoreFailedLocations = false
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    var body: some View {
        VStack {
            ScrollView {
                allLocationsView
                failedLocationsView
                createGeoFireCoordsButton
                    .padding(.vertical)
            }
        }
        .background(oceanBlue.black)
        .navigationTitle("Database")
    }
    
    //MARK: - All Locations View
    
    var allLocationsView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("All Locations")
                    .font(.avenirNext(size: 24))
                    .fontWeight(.thin)
                    .foregroundColor(oceanBlue.lightBlue)
                Spacer()
                allLocationsButton
            }.padding()
            Divider()
            allLocationsList
        }
    }
    
    var allLocationsList: some View {
        VStack(alignment: .leading) {
            ForEach(locationStore.hauntedHotels.prefix(self.showingMoreAllLocations ? .max : 4)) { location in
                Text("\(location.location.id): \(location.location.name)")
                    .foregroundColor(oceanBlue.lightBlue)
                    .font(.avenirNext(size: 18))

            }
        }
        .padding(.horizontal)
            .padding(.vertical, 3)
    }
    

    
    //MARK: - Failed Locations View
    
    var failedLocationsView: some View {
        VStack {
            HStack {
                Text("Failed Locations")
                    .font(.avenirNext(size: 24))
                    .fontWeight(.thin)
                    .foregroundColor(oceanBlue.lightBlue)

                Spacer()
                failedLocationsButton
            }.padding()
            Divider()
            failedLocationsList
        }.padding(.vertical)
    }
    
    var failedLocationsList: some View {
        
        List(failedLocations) { location in
            Text("\(location.location.id): \(location.location.name)")
                .foregroundColor(oceanBlue.lightBlue)

        }
        .modifier(ClearListBackgroundMod())
        .lineLimit(self.showingMoreFailedLocations ? .none : 4)
    }
    
    //MARK: - Buttons
    
    var allLocationsButton: some View {
        Button(action: allTapped) {
            Text(self.showingMoreAllLocations ? "Less" : "More")
                .font(.avenirNext(size: 18))
                .foregroundColor(oceanBlue.yellow)
        }
    }
    
    private var failedLocationsButton: some View {
        Button(action: moreFailedTapped) {
            Text(self.showingMoreFailedLocations ? "Less" : "More")
                .font(.avenirNext(size: 18))
                .foregroundColor(oceanBlue.yellow)
        }
    }
    
    var createGeoFireCoordsButton: some View {
        Button(action: createGFCTapped) {
            Text("Create GeoFire Coordinates")
                .font(.avenirNext(size: 18))
                .fontWeight(.black)
                .foregroundColor(oceanBlue.yellow)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 25)
                    .stroke(oceanBlue.yellow, lineWidth: 3))
        }
    }
    
    
    //MARK: - Methods
    
    private func allTapped() {
        self.showingMoreAllLocations.toggle()
    }
    
    private func moreFailedTapped() {
        self.showingMoreFailedLocations.toggle()
    }
    
    private func createGFCTapped() {
        
        for loc in locationStore.hauntedHotels {
            
            GeoFireManager.instance.createSpookySpotForLocation(loc) { result in
                
                if result == false {
                    self.failedLocations.append(loc)
                } else {
                    self.failedLocations.removeAll(where: { $0.id == loc.id })
                }
            }
        }
    }
}

struct DatabaseView_Previews: PreviewProvider {
    static var previews: some View {
        DatabaseView(locationStore: LocationStore())
    }
}
