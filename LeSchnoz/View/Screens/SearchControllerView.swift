//
//  SearchControllerView.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 2/18/23.
//

import SwiftUI

struct SearchControllerView: View {
    
    @ObservedObject var exploreVM: ExploreViewModel
    
    var body: some View {
        
        VStack {
            DoubleSearchView(exploreVM: exploreVM)
            PlacesResultsViewControllerBridge { place in
                Text("Demitroff")
            }
        }
    }
    
}

struct SearchControllerView_Previews: PreviewProvider {
    static var previews: some View {
        SearchControllerView(exploreVM: ExploreViewModel())
        
    }
}
