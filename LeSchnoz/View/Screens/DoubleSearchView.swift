//
//  DoubleSearchView.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 2/18/23.
//

import SwiftUI

struct DoubleSearchView: View {
    
    @State var placeSearchInput = ""
    @State var searchAreaInput = ""
    
    @ObservedObject var exploreVM: ExploreViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            gobackButton

            VStack(spacing: 2) {
                textField(searchCase: .place,
                          input: $placeSearchInput)
                textField(searchCase: .searchArea,
                          input: $searchAreaInput)
            }
            
            .onChange(of: placeSearchInput) { newValue in
//                <#code#>
            }
        }
        .padding(.horizontal)
    }
    
    private func textField(searchCase: SearchTextCase, input: Binding<String>) -> some View {
        HStack {
            Image(systemName: searchCase.iconName)
                .resizable()
                .frame(width: 15, height: 15)
                .foregroundColor(.black.opacity(0.6))
                .padding(.leading, 7)
            TextField("", text: input)
                .padding(.vertical, 7)
                .placeholder(when: input.wrappedValue.isEmpty) {
                    Text(searchCase.title)
                        .font(.avenirNext(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            cancelText(searchCase: searchCase, text: input.wrappedValue)
        }
//        .padding(7)
        .background(.white)
        .cornerRadius(10)
    }
    
    private func cancelText(searchCase: SearchTextCase, text: String) -> some View {
        Button {
            cancelTextTapped(searchCase: searchCase)
        } label: {
            Text("Cancel")
                .font(.avenirNext(size: 15))
        }
        .opacity(text.isEmpty ? 0 : 1)
        .padding()
    }
    
    
    private var gobackButton: some View {
        Button(action: gobackTapped) {
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 25, height: 25)                .foregroundColor(.black)
        }
    }
    
    
    private func cancelTextTapped(searchCase: SearchTextCase) {
        switch searchCase {
        case .place:
            self.placeSearchInput = ""
        case .searchArea:
            self.searchAreaInput = ""
        }
    }
    
    
    private func gobackTapped() {
        exploreVM.showingSearchController = false
    }

    
    //MARK: - SearchTextCase
    
    enum SearchTextCase {
        case place,
             searchArea
        
        var title: String {
            switch self {
                
            case .place:
                return "What are you looking for?"
            case .searchArea:
                return "Near Me"
            }
        }
        
        var iconName: String {
            switch self {
                
            case .place:
                return "magnifyingglass"
            case .searchArea:
                return "safari"
            }
        }
    }

}

struct DoubleSearchView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.red
            DoubleSearchView(exploreVM: ExploreViewModel())
        }
    }
}


