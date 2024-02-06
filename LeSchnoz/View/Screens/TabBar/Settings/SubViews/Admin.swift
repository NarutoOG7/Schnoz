//
//  Admin.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 7/10/23.
//

import SwiftUI

struct Admin: View {
    
    @ObservedObject var adminVM = AdminVM.instance
    
    @State var searchInput = ""
    @State var searchResults = [String]()
    
    var body: some View {
        VStack {
            searchField
            list
        }
        
            .onChange(of: searchInput) { newValue in
                getLocationName(newValue)
            }
    }
    
    private var searchField: some View {
        VStack {
            TextField("Search", text: $searchInput)
            List(searchResults, id: \.self) { result in
                Text(result)
            }
            .frame(height: CGFloat(searchResults.count) * 50)
        }
    }
    
    private var list: some View {
        List(adminVM.adminAverages.sorted(by: { $0.locationName < $1.locationName }), id: \.self) { average in
            VStack(alignment: .leading) {
                    Text(average.locationName)
                
                Text("number of reviews: \(average.average.numberOfReviews)")
                    .font(.subheadline)

                Text("total stars: \(average.average.totalStarCount)")
                    .font(.subheadline)

                Text(average.average.id)
                    .font(.subheadline)
            }
        }
        
        .onAppear {
            getAllAverageRatings { adminAverages in
                adminVM.adminAverages = adminAverages
            }
        }
    }
    private func converIDStringsToLocatioName() {
        
    }
    
    private func getAllAverageRatings(withCompletion completion: @escaping ([AdminAverage]) -> Void) {
        var adminAverages = [AdminAverage]()
        let group = DispatchGroup()
        group.enter()
        FirebaseManager.instance.getAllAverageRatings { averages in
            for average in averages ?? [] {
                group.enter()
                GooglePlacesManager.instance.getPlaceDetails(average.id) { place, error in
                    defer {
                        group.leave()
                    }
                    if let place = place {
                        let adminAverage = AdminAverage(average: average, locationName: place.name ?? "")
                        adminAverages.append(adminAverage)
                    } else if let error = error {
                        // Handle the error appropriately, such as logging or reporting it
                        print("Error fetching place: \(error)")
                    }
                }
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(adminAverages)
        }
    }

    
    private func getLocationName(_ searchText: String) {
        GooglePlacesManager.instance.getPlaceDetails(searchText) { place, error in
            if let place = place {
                self.searchResults.append(place.name ?? "" + " " + (place.formattedAddress ?? ""))
            }
        }
    }
}

struct Admin_Previews: PreviewProvider {
    static var previews: some View {
        Admin()
    }
}

class AdminVM: ObservableObject {
    static let instance = AdminVM()
    
    @Published var averageRatings: [AverageRating] = []
    @Published var adminAverages: [AdminAverage] = []
}

struct AdminAverage: Hashable {
    static func == (lhs: AdminAverage, rhs: AdminAverage) -> Bool {
        lhs.locationName == rhs.locationName
    }
    
    let average: AverageRating
    let locationName: String
    
    init(average: AverageRating, locationName: String) {
        self.average = average
        self.locationName = locationName
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(locationName)
    }

}
