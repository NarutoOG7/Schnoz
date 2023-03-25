//
//  HomeDisplayView.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 3/22/23.
//

import SwiftUI

struct HomeDisplayView: View {
    
    @ObservedObject var userStore: UserStore
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    let defaultReview = ReviewModel(id: "01", rating: 7, review: "Super cool staff, and the place was decent. Air was a little stale.", title: "Stale Air, Friendly Staff", username: "SlowMoJo", locationID: "Bobs01", locationName: "Bob's Burgers")
    
    var body: some View {
        GeometryReader { geo in
                ZStack {
                    backgroundImage(geo)
                searchStack(geo)
            }
//                .frame(width: geo.size.width, height: geo.size.height * 0.531, alignment: .center)
//            }
        }
    }
    
    private func searchStack(_ geo: GeometryProxy) -> some View {
        VStack(spacing: 30) {
            Spacer(minLength: geo.size.height * 0.3)
            searchView(geo)
            HStack(spacing: geo.size.width / 15) {
                ForEach(SearchType.allCases.indices, id: \.self) { index in
                    searchTypeOptionView(SearchType.allCases[index], geo)
                    if index != SearchType.allCases.indices.last {
                        Divider().frame(height: 80)
                    }
                    }.listStyle(.insetGrouped)
                }
            latestReviews(geo)
                .padding(.top, -20)
            Spacer()
        }
      
    }
    
    private func schnozTitle(_ geo: GeometryProxy) -> some View {
        Text("SCHNOZ")
            .font(.system(size: 30, weight: .black))
            .foregroundColor(oceanBlue.blue)
            .padding(9)
            .background(Rectangle().foregroundColor(.white))
            .offset(y: -100)
    }
    
    private func backgroundImage(_ geo: GeometryProxy) -> some View {
        VStack {
            ZStack {
                Image("restaraunt")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.top)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.white]),
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        //                    .opacity(0.99)
                    )
                schnozTitle(geo)
            }
            .frame(width: geo.size.width, height: geo.size.height * 0.4)
            Spacer()
        }
    }
    
    private func searchView(_ geo: GeometryProxy) -> some View {
            
            Button(action: searchTapped) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .frame(width: 20, alignment: .leading)
                        .foregroundColor(oceanBlue.grayPurp)
                        .font(.subheadline)
                    
                    Text("What are you looking for, \(userStore.user.name)?")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(oceanBlue.blue)
                        .font(.subheadline)
                    
                    
                }
                
            }
            .frame(width: geo.size.width - 60)
            .padding()
            .background(         RoundedRectangle(cornerRadius: 10)
                .fill(oceanBlue.white)
                .frame(height: 36)
                .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 5)
            )
//            .padding()
            .shadow(color: .white, radius: 10)
    }
    
    private func latestReviews(_ geo: GeometryProxy) -> some View {
        VStack(alignment: .leading) {
            Text("Latest Review")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.vertical)
            ReviewCard(review: defaultReview)
                .frame(width:  geo.size.width - 60)
        }
//        .padding(.top)
    }
    
    private func searchTypeOptionView(_ searchType: SearchType, _ geo: GeometryProxy) -> some View {
        Button {
            searchTypeTapped(searchType)
        } label: {
            VStack {
                searchType.image
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: geo.size.width / 6)
                Text(searchType.rawValue.capitalized)
                    .font(.footnote)
                    .foregroundColor(oceanBlue.lightBlue)
                    .lineLimit(1)
                    .padding(.leading, searchType == .breakfast ? -15 : 0)
                    .offset(x: searchType == .breakfast ? 6 : 0)
            }
        }

    }
    
    //MARK: - Methods
    
    private func searchTapped() {
        
    }
    
    private func searchTypeTapped(_ searchType: SearchType) {
        
    }
}

struct HomeDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        HomeDisplayView(userStore: UserStore())
    }
}

// Photo by <a href="https://unsplash.com/@tamarushphotos?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Tamara Malaniy</a> on <a href="https://unsplash.com/photos/nQWT-aeqVMQ?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>

