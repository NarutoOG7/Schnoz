//
//  NewsFeedView.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 6/21/23.
//

import SwiftUI


enum ReviewSortingOption: String {
    case newest = "Newest First"
    case oldest = "Oldest First"
    case best = "Highest Rated"
    case worst = "Lowest Rated"
    
    var sortingQuery: (query: String, descending: Bool) {
        switch self {
            
        case .newest:
            return ("timestamp", true)
        case .oldest:
            return ("timestamp", false)
        case .best:
            return ("rating", true)
        case .worst:
            return ("rating", false)

        }
    }
}


struct NewsFeedView: View {
    
    let oceanBlue = K.Colors.OceanBlue.self
        
    @ObservedObject var viewModel = NewsFeedVM.instance
    
    @State var showActionSheet = false
    
    var body: some View {
        ZStack {
            background
            VStack {
//                sortByButton
                listOfReviews
            }
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("Sort Options"),
                buttons: [
                    .default(Text(ReviewSortingOption.newest.rawValue), action: {
                        viewModel.sortingOption = .newest
                    }),
                    .default(Text(ReviewSortingOption.oldest.rawValue), action: {
                        viewModel.sortingOption = .oldest
                    }),
                    .default(Text(ReviewSortingOption.best.rawValue), action: {
                        viewModel.sortingOption = .best
                    }),
                    .default(Text(ReviewSortingOption.worst.rawValue), action: {
                        viewModel.sortingOption = .worst
                    }),
                    
                        .cancel()
                    
                ]
            )
        }
        .toolbar {
            sortByButton
        }
    }
    
    private var background: some View {
        oceanBlue.blue
            .edgesIgnoringSafeArea(.all)
    }
    
    private var listOfReviews: some View {
            List(viewModel.reviews) { review in
                ReviewCell(review: review)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .onAppear {
                        let isLast = viewModel.reviews.last == review
                        viewModel.listHasScrolledToBottom = isLast
                    }
            }
                .modifier(ClearListBackgroundMod())
            .onAppear {
                viewModel.batchFirstCall()
            }
    }
    
//    private var sortByButton: some View {
//        HStack {
//            HStack(spacing: 8) {
//                Text("Sort by:")
//                    .foregroundColor(oceanBlue.white)
//                    .font(.avenirNext(size: 17))
//
//                Button(action: sortTapped) {
//                    HStack {
//                        Text("\(sortingOption.rawValue)")
//                            .underline()
//                            .foregroundColor(oceanBlue.white)
//                            .fontWeight(.medium)
//                            .font(.avenirNext(size: 17))
//                        Image(systemName: "chevron.down")
//                            .foregroundColor(oceanBlue.yellow)
//                            .font(.caption)
//
//                    }
//                }
//            }
//            .padding(.horizontal)
//            Spacer()
//        }
//    }
    
    
    private var sortByButton: some View {
        HStack {
            Spacer()
            
            Button(action: sortTapped) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(oceanBlue.yellow)
                    .font(.title3)
            }
        }
    }
  
    
//    private var sortButton: some View {
//            Picker("Sort By", selection: $sortingOption) {
//                Text("Newest First").tag(SortingOption.newest)
//                Text("Oldest First").tag(SortingOption.oldest)
//                Text("Highest Rated").tag(SortingOption.best)
//                Text("Lowest Rated").tag(SortingOption.worst)
//
//            }
////            .frame(width: 200)
//            .foregroundColor(oceanBlue.blue)
//            .padding(.horizontal)
//            .background(
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(oceanBlue.white)
//            )
//
//    }
    

//    private func cellForReview(_ review: ReviewModel) -> some View {
//        let nameIsBlank = review.username == ""
//        return VStack(alignment: .leading) {
//            Text(nameIsBlank ? "Anonymous" : review.username)
//                .font(.avenirNext(size: 19))
//                .fontWeight(.bold)
//                .foregroundColor(.red)
//
//            Text(review.locationName)
//            Stars(count: 5, isEditable: false, color: .green, rating: .constant(review.rating))
//            Text(review.title)
//                .fontWeight(.bold)
//            Text(review.review)
//        }
//    }
    
    private func sortTapped() {
        showActionSheet = true
    }
}

struct NewsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        NewsFeedView()
    }
}

