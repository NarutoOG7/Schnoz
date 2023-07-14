//
//  OtherSniffersView.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 6/24/23.
//

import SwiftUI

struct TopSniffers: View {
    let oceanBlue = K.Colors.OceanBlue.self
    
    @ObservedObject var viewModel = TopSniffersVM.instance
    @ObservedObject var userDetailsVM = UserDetailsVM.instance
    
    @State var showActionSheet = false
    
    var body: some View {
            
            ZStack {
                background
                VStack {
                    listOfUsers
                }
            }
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(
                    title: Text("Sort Options"),
                    buttons: [
                        .default(Text(SniffersSortingOption.mostReviews.rawValue), action: {
                            viewModel.sortingOption = .mostReviews
                        }),
                        .default(Text(SniffersSortingOption.harshestCritic.rawValue), action: {
                            viewModel.sortingOption = .harshestCritic
                        }),
                        .default(Text(SniffersSortingOption.topSupporters.rawValue), action: {
                            viewModel.sortingOption = .topSupporters
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
    
    private var listOfUsers: some View {
        List(viewModel.users) { user in

            NavigationLink {
                UserDetailsView(user: user)
            } label: {
                SocialCell(user: user)
                    .onAppear {
                        let isLast = viewModel.users.last == user
                        viewModel.listHasScrolledToBottom = isLast
                    }
            }
            .padding(.trailing, -30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(oceanBlue.lightBlue, lineWidth: 1)
                            )

            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

        }
        .modifier(ClearListBackgroundMod())
        .task {
                viewModel.batchFirstCall()
            
        }

    }
    
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
    
    
    
    private func sortTapped() {
        showActionSheet = true
    }
}

struct OtherSniffersView_Previews: PreviewProvider {
    static var previews: some View {
        TopSniffers()
    }
}

//struct SocialCell: View {
//    let user: User
//
//    let oceanBlue = K.Colors.OceanBlue.self
//    var body: some View {
//        return HStack {
//            VStack(alignment: .leading, spacing: 8) {
//                username
//                totalReviews
//                totalStars
//                averageStars
//                Divider().overlay(oceanBlue.lightBlue)
//                    .padding(.top)
//
//            }
//            Image(systemName: "chevron.right")
//                .foregroundColor(oceanBlue.white)
//        }
//    }
//
//    private var username: some View {
//        Text(user.name)
//            .font(.avenirNext(size: 18))
//            .fontWeight(.bold)
//            .foregroundColor(oceanBlue.white)
//    }
//
//    private var totalReviews: some View {
//        HStack {
//            Text("Total Reviews: ")
//                .font(.avenirNext(size: 16))
//                .fontWeight(.bold)
//                .foregroundColor(oceanBlue.lightBlue)
//                .italic()
//            Text("\(user.reviewCount ?? 0)")
//                .font(.avenirNext(size: 16))
//                .fontWeight(.bold)
//                .foregroundColor(oceanBlue.white)
//                .italic()
//        }
//    }
//
//    private var totalStars: some View {
//        let userHasNoStars = user.totalStarsGiven == 0
//        let starsCount = userHasNoStars ? 0 : 1
//        return HStack {
//            Text("Total Stars Given: ")
//                .font(.avenirNext(size: 16))
//                .fontWeight(.bold)
//                .foregroundColor(oceanBlue.lightBlue)
//                .italic()
//            Stars(count: starsCount, isEditable: false, color: oceanBlue.yellow, rating: .constant(user.totalStarsGiven ?? 0))
//            Text("\(user.totalStarsGiven ?? 0)")
//                .font(.avenirNext(size: 16))
//                .fontWeight(.bold)
//                .foregroundColor(oceanBlue.white)
//                .italic()
//        }
//    }
//
//    private var averageStars: some View {
//        HStack {
//            Text("Average Rating: ")
//                .font(.avenirNext(size: 16))
//                .fontWeight(.bold)
//                .foregroundColor(oceanBlue.lightBlue)
//                .italic()
//            Text("\(user.averageStarsGiven ?? 0)")
//                .font(.avenirNext(size: 16))
//                .fontWeight(.bold)
//                .foregroundColor(oceanBlue.white)
//                .italic()
//
//        }
//    }
//}

struct FullRectangleButtonStyle: ButtonStyle {
    let text: String
    let image: Image?
    let color: Color
    var textColor: Color = .white
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(color)
                .frame(height: 65)
            HStack(spacing: 12) {
                image
                Text(text)
                    .foregroundColor(textColor)
                    .font(.avenirNext(size: 20))
                    .fontWeight(.bold)
            }
        }
    }
}
