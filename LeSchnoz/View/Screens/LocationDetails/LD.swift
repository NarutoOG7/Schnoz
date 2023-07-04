//
//  LD.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/27/22.
//

import SwiftUI
import GooglePlaces

struct LD: View {
    
//    @State var location: SchnozPlace?
    
    @State private var imageURL = URL(string: "")
    @State private var isSharing = false
    @State private var isCreatingNewReview = false
    @State private var isShowingMoreReviews = false
        
    @State var shouldShowFirebaseError = false
    @State var shouldShowSuccessMessage = false
    @State var firebaseErrorMessage = ""
//    @State var reviews: [ReviewModel] = []
    
    @State var showGuestAlert = false
    
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
                    listOfReviews
//                    reviewHelper
                }
                .clipped()
                .padding(.horizontal)
                .padding(.vertical, imageMaxHeight + 36.0)
                
                image
                backButton
            }
        }
        .edgesIgnoringSafeArea(.vertical)
        .navigationBarHidden(true)
        
        
//        .alert(isPresented: $showGuestAlert) {
//                  Alert(title: Text("Sign In First"), message: Text("You must be signed in to leave reviews"), primaryButton: .default(Text("Sign In"), action: {
//                      UserDefaults.standard.set(false, forKey: "signedIn")
//                      userStore.isSignedIn = false
//                      userStore.user = User()
//                      UserDefaults.standard.set(false, forKey: K.UserDefaults.isGuest)
//                  }), secondaryButton: .cancel())
//              }
        

    }
    
    
    //MARK: - SubViews
    
    private var header: some View {
        HStack {
            backButton
                .frame(width: 30, height: 30)
                .padding(.leading)
                .offset(y: imageMaxHeight / 6)

            headerText
                .padding(.leading, -40)
                .padding(.trailing)
                .offset(y: imageMaxHeight / 4)

        }
        
    }
    
    private var headerText: some View {
        Text(ldvm.selectedLocation?.primaryText ?? "")
            .font(.avenirNext(size: 20))
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
    }
    
    private var image: some View {
        GeometryReader { geo in
                listResultsVM.placeImage
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
    
    private var title:  some View {
        Text(ldvm.selectedLocation?.primaryText ?? "")
            .font(.avenirNext(size: 34))
            .fontWeight(.medium)
            .foregroundColor(oceanBlue.blue)
        
    }
    
    
    private var address: some View {
        Text(ldvm.selectedLocation?.secondaryText ?? "")
            .font(.avenirNextRegular(size: 19))
            .lineLimit(nil)
            .foregroundColor(oceanBlue.blue)
    }
    
    private var avgRatingDisplay: some View {
        let total = ldvm.selectedLocation?.averageRating?.numberOfReviews ?? 0
        let textEnding = total == 1 ? "" : "s"
        return VStack(alignment: .leading, spacing: 7) {
            Stars(color: oceanBlue.yellow,
                  rating: .constant(ldvm.selectedLocation?.averageRating?.avgRating ?? 0))
            
            Button(action: moreReviewsTapped) {
                Text("(\(total) review\(textEnding))")
                    .font(.avenirNextRegular(size: 17))
                    .foregroundColor(oceanBlue.lightBlue)
            }.disabled(total == 0)
            leaveAReviewView
            
        }
    }
    
    private var reviewHelper: some View {
         VStack(alignment: .leading) {
             if ldvm.reviews.isEmpty {
                Text("No Reviews")
                    .font(.avenirNext(size: 17))
                    .foregroundColor(oceanBlue.blue)
            } else {
                if let last = ldvm.reviews.last {
                    ReviewCard(review: last)
                }
            }
            HStack {
                if ldvm.reviews.count > 1 {
                    moreReviewsButton
                }
            }
                .padding(.vertical, 30)
            Spacer(minLength: 200)
        }
    }
    
    private var leaveAReviewView: some View {
        
        NavigationLink {
            LocationReviewView(
                isPresented: $isCreatingNewReview,
                review: .constant(nil),
                location: $ldvm.selectedLocation,
                reviews: $ldvm.reviews,
                isUpdatingReview: false,
                userStore: userStore,
                firebaseManager: firebaseManager,
                errorManager: errorManager
            )
        } label: {
            Text("Leave A Review")
                .font(.avenirNextRegular(size: 17))
                .foregroundColor(oceanBlue.lightBlue)
        }
        .onTapGesture {
            if userStore.isGuest {
                self.showGuestAlert = true
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
    
    
    private var listOfReviews: some View {
            List(ldvm.reviews) { review in
                ReviewCell(review: review, isShowingLocationName: false)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .onAppear {
                        let isLast = ldvm.reviews.last == review
                        ldvm.listHasScrolledToBottom = isLast
                    }
            }
            .scrollDisabled(true)
            .frame(height: 250 * CGFloat(ldvm.reviews.count))
                .modifier(ClearListBackgroundMod())
            .onAppear {
                ldvm.batchFirstCall()
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
        VStack {
            HStack {
                
                Button(action: backButtonTapped) {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(width: 25, height: 35)
                        .tint(oceanBlue.yellow)
                }
                Spacer()
            }
            .padding(.horizontal)
                .padding(.top, 60)
            Spacer()

        }
//        .frame(width: 25, height: 35)


    }
    
    
    //MARK: - Methods
    
    private func directionsTapped() {

        var addressString: String {
            
            ldvm.selectedLocation?.gmsPlace?.name?.replacingOccurrences(of: " ", with: "+") ?? ""
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
        let searchLogic = SearchLogic.instance
        self.presentationMode.wrappedValue.dismiss()
//        listResultsVM.selectedPlace = nil
//        ldvm.selectedLocation = nil
//        listResultsVM.resetPlaceImage()
        listResultsVM.shouldShowPlaceDetails = false
//        searchLogic.placeSearchText = ""
//        searchLogic.areaSearchText = ""
    }
    
    private func moreReviewsTapped() {
        self.isShowingMoreReviews = true
    }
    
//    private func fetchFirebaseReviews() {
//        firebaseManager.fetchLatestTenReviewsForLocation(self.location?.placeID ?? "") { reviews in
//            // Actually removed limit, fetches all
//            self.location?.schnozReviews = reviews
//            self.reviews = reviews
//        }
//    }
}

//MARK: - Previews
struct LD_Previews: PreviewProvider {
    static var previews: some View {
        LD()
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

