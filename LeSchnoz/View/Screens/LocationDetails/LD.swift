//
//  LD.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/27/22.
//

import SwiftUI
import GooglePlaces

struct LD: View {
    
    @State var location: SchnozPlace
    
    @State private var imageURL = URL(string: "")
    @State private var isSharing = false
    @State private var isCreatingNewReview = false
    @State private var isShowingMoreReviews = false
    
    @State private var placeImage: Image = K.Images.placeholder
    
    @State var shouldShowFirebaseError = false
    @State var shouldShowSuccessMessage = false
    @State var firebaseErrorMessage = ""
    
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var firebaseManager = FirebaseManager.instance
    @ObservedObject var errorManager = ErrorManager.instance
    @ObservedObject var ldvm = LDVM.instance
    @ObservedObject var listResultsVM = ListResultsVM.instance
    
    let imageMaxHeight = UIScreen.main.bounds.height * 0.38
    let collapsedImageHeight: CGFloat = 10
    
    private let images = K.Images.self
    private let oceanBlue = K.Colors.OceanBlue.self
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack {
                VStack(alignment: .leading, spacing: 7) {
                    title
                    address
                    avgRatingDisplay
                    buttons
                    Divider()
                    moreInfoLink
                    Spacer()
                    reviewHelper
                }
                .clipped()
                .padding(.horizontal)
                .padding(.vertical, imageMaxHeight + 36.0)
                
                
                image
                
                VStack {
                    HStack {
                        backButton
                        Spacer()
                    }.padding(.horizontal)
                        .padding(.top, 60)
                    Spacer()
                }
                
                .sheet(isPresented: $isSharing) {
                    ShareActivitySheet(itemsToShare: [location])
                }
                
                .sheet(isPresented: $isShowingMoreReviews) {
                    MoreReviewsSheet(reviews: location.schnozReviews)
                }
            }
        }
        .edgesIgnoringSafeArea(.vertical)
        .navigationBarHidden(true)
        
        .task {
            GooglePlacesManager.instance.getPhotoForPlaceID(self.location.placeID) { uiImage, error in
                if let error = error {
                    self.errorManager.message = error.localizedDescription
                    self.errorManager.shouldDisplay = true
                }
                if let uiImage = uiImage {
                    self.placeImage = Image(uiImage: uiImage)
                }
            }
        }
    }
    
    //MARK: - SubViews
    
    private var header: some View {
        HStack {
            backButton
                .padding(.horizontal)
            Spacer()
            headerText
                .padding(.horizontal)
            Spacer()
            Spacer()
        }
        .offset(y: 80)
        
    }
    
    private var headerText: some View {
        Text(location.primaryText ?? "")
            .font(.avenirNext(size: 20))
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
    
    private var image: some View {
        GeometryReader { geo in
            placeImage
                    .resizable()
                    .aspectRatio(1.75, contentMode: .fill)
                    .blur(radius: self.getBlurRadiusForImage(geo))
                    .shadow(radius: self.calculateShadow(geo))
                    .overlay(header
                        .opacity(self.getBlurRadiusForImage(geo) - 0.35))
                    .frame(width: geo.size.width,
                           height: self.calculateHeight(minHeight: collapsedImageHeight,
                                                        maxHeight: imageMaxHeight,
                                                        yOffset: geo.frame(in: .global).origin.y))
                    .offset(y: geo.frame(in: .global).origin.y < 0
                            ? abs(geo.frame(in: .global).origin.y)
                            : -geo.frame(in: .global).origin.y)
        }
    }
    
    private var title: some View {
        Text(location.primaryText ?? "")
            .font(.avenirNext(size: 34))
            .fontWeight(.medium)
            .foregroundColor(oceanBlue.blue)
    }
    
    
    private var address: some View {
        Text(location.secondaryText ?? "")
            .font(.avenirNextRegular(size: 19))
            .lineLimit(nil)
            .foregroundColor(oceanBlue.blue)
    }
    
    private var avgRatingDisplay: some View {
        let reviewCount = location.schnozReviews.count
        let textEnding = reviewCount == 1 ? "" : "s"
        return VStack(alignment: .leading) {
            Stars(count: 10,
                color: oceanBlue.yellow,
                rating: $location.avgRating)
            
            Text("(\(reviewCount) review\(textEnding))")
                .font(.avenirNextRegular(size: 17))
                .foregroundColor(oceanBlue.blue)
        }
    }
    

//    private var description: some View {
//        Text(location.)
//            .font(.avenirNext(size: 17))
//            .lineLimit(nil)
//            .foregroundColor(oceanBlue.blue)
//    }
    
    private var reviewHelper: some View {
         VStack(alignment: .leading) {
            if location.schnozReviews.isEmpty {
                Divider()
                Text("No Reviews")
                    .font(.avenirNext(size: 17))
                    .foregroundColor(oceanBlue.blue)
            } else {
                if let last = location.schnozReviews.last {
                    ReviewCard(review: last)
                    
                }
            }
            HStack {
                leaveAReviewView
                if location.schnozReviews.count > 1 {
                    moreReviewsButton
                }
            }
                .padding(.vertical, 30)
            Spacer(minLength: 200)
        }
//         .sheet(isPresented: $isCreatingNewReview, onDismiss: {
//             if let recentlyPublishedReview = ldvm.recentlyPublishedReview {
//                 self.location.schnozReviews.append(recentlyPublishedReview)
//                 ldvm.recentlyPublishedReview = nil
//             }
//         }, content: {
//
//             LocationReviewView(
//                isPresented: $isCreatingNewReview,
//                review: .constant(nil),
//                location: $location,
//                nameInput: userStore.user.name,
//                userStore: userStore,
//                firebaseManager: firebaseManager,
//                errorManager: errorManager
//             )
//         })
//
        

    }
    
    private var moreInfoLink: some View {
        
        let view: AnyView
        
        if let url = location.gmsPlace?.website {
            
            view = AnyView(
                HStack {
                    Spacer()
                    Link(destination: url, label: {
                        Text("Get More Info")
                            .underline()
                            .foregroundColor(oceanBlue.lightBlue)
                            .font(.avenirNextRegular(size: 17))
                    })
                }
            )
        } else {
            view = AnyView(EmptyView())
        }
        return view
    }
    
    private var leaveAReviewView: some View {
        
        VStack(alignment: .leading) {
            Text("Been here before?")
                .italic()
                .font(.avenirNextRegular(size: 17))
                .foregroundColor(oceanBlue.blue)
            NavigationLink {
                LocationReviewView(
                    isPresented: $isCreatingNewReview,
                    review: .constant(nil),
                    location: $location,
                    isUpdatingReview: false,
                    userStore: userStore,
                    firebaseManager: firebaseManager,
                    errorManager: errorManager
                )
            } label: {
                Text("Leave A Review")
                    .underline()
                    .font(.avenirNextRegular(size: 17))
                    .foregroundColor(oceanBlue.lightBlue)
            }
        }
    }
    
    private var firebaseErrorBanner: some View {

            NotificationBanner(message: $firebaseErrorMessage,
                               isVisible: $shouldShowFirebaseError,
                               errorManager: errorManager)
            .task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                    self.shouldShowFirebaseError = false
                }
            }
    }
    
    //MARK: - Buttons
    
    var buttons: some View {
        HStack(alignment: .top) {
            Spacer()
            directionsButton
            shareButton
            Spacer()
        }.padding(.top)
            .frame(height: 150)
    }
    
    
    private var directionsButton: some View {
        CircleButton(
            size: .medium,
            image: Image(systemName: "arrow.triangle.turn.up.right.diamond"),
            mainColor: oceanBlue.lightBlue,
            accentColor: oceanBlue.white,
            title: "Directions",
            clicked: directionsTapped)
    }
    
    private var shareButton: some View {
        CircleButton(
            size: .medium,
            image: images.share,
            mainColor: oceanBlue.lightBlue,
            accentColor: oceanBlue.white,
            title: "Share",
            clicked: shareTapped)
    }
    
    private var moreReviewsButton: some View {
        HStack {
            Spacer()
            Button(action: moreReviewsTapped) {
                Text("More Reviews")
                    .font(.avenirNextRegular(size: 17))
                    .fontWeight(.medium)
                    .foregroundColor(oceanBlue.blue)
            }
        }.padding(.vertical)
    }
    
    private var backButton: some View {
        Button(action: backButtonTapped) {
            Image(systemName: "chevron.left")
                .resizable()
                .frame(width: 25, height: 35)
                .tint(oceanBlue.yellow)
        }
    }
    
    
    //MARK: - Methods
    
    private func directionsTapped() {

        var addressString: String {
            
            location.gmsPlace?.name?.replacingOccurrences(of: " ", with: "+") ?? ""
        }
        
        guard let url = URL(string: "maps://?daddr=\(addressString)") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func shareTapped() {
        self.isSharing = true
    }
    
    private func backButtonTapped() {
//        self.presentationMode.wrappedValue.dismiss()
        listResultsVM.selectedPlace = nil
        listResultsVM.shouldShowPlaceDetails = false
    }
    
    private func moreReviewsTapped() {
        self.isShowingMoreReviews = true
    }
    
}

//MARK: - Previews
struct LD_Previews: PreviewProvider {
    static var previews: some View {
        LD(location: SchnozPlace(placeID: "PLace01"),
           userStore: UserStore(),
           firebaseManager: FirebaseManager(),
           errorManager: ErrorManager())
    }
}



//MARK: - Sticky Header Helpers

extension LD {
    
    private func calculateHeight(minHeight: CGFloat, maxHeight: CGFloat, yOffset: CGFloat) -> CGFloat {
        /// If scrolling up, yOffset will be a negative number
        if maxHeight + yOffset < minHeight {
            /// SCROLLING UP
            /// Never go smaller than our minimum height
            return minHeight
        }
        /// SCROLLING DOWN
        return maxHeight + yOffset
    }
    
    func calculateShadow(_ geo: GeometryProxy) -> Double {
        self.calculateHeight(
            minHeight: collapsedImageHeight,
            maxHeight: imageMaxHeight,
            yOffset: geo.frame(in: .global).origin.y) < 140 ? 8 : 0
    }
    
    func getBlurRadiusForImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = geometry.frame(in: .global).maxY
        
        let height = geometry.size.height
        let blur = (height - max(offset, 0)) / height
        
        return blur * 6
    }
}

