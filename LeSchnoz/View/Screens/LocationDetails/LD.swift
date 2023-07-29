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
    
    @State var showReviewSortActionSheet = false
    
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var firebaseManager = FirebaseManager.instance
    @ObservedObject var errorManager = ErrorManager.instance
    @ObservedObject var ldvm = LDVM.instance
    @ObservedObject var listResultsVM = ListResultsVM.instance
    
    let imageMaxHeight = UIScreen.main.bounds.height * 0.3
    let collapsedImageHeight: CGFloat = 10
    
    private let images = K.Images.self
    private let oceanBlue = K.Colors.OceanBlue.self
    
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                    ZStack {
                        VStack(alignment: .leading, spacing: 7) {
                            title
                            address
                            avgRatingDisplay
                            sortReviewsButton
                            listOfReviews
                            Spacer(minLength: ldvm.reviews.count == 0 ? 500 : 300)
                        }
                        .padding(.horizontal)
                        .clipped()
                        .padding(.top, imageMaxHeight + 36.0)
                        
                        image
                        backButton
                    }
                }
            }
            
            .edgesIgnoringSafeArea(.vertical)
//            .navigationBarHidden(true)
            
            .actionSheet(isPresented: $showReviewSortActionSheet) {
                ActionSheet(
                    title: Text("Sort Options"),
                    buttons: [
                        .default(Text(ReviewSortingOption.newest.rawValue), action: {
                            ldvm.sortingOption = .newest
                        }),
                        .default(Text(ReviewSortingOption.oldest.rawValue), action: {
                            ldvm.sortingOption = .oldest
                        }),
                        .default(Text(ReviewSortingOption.best.rawValue), action: {
                            ldvm.sortingOption = .best
                        }),
                        .default(Text(ReviewSortingOption.worst.rawValue), action: {
                            ldvm.sortingOption = .worst
                        }),
                        .cancel()
                        
                    ]
                )
            }
        
            .fullScreenCover(isPresented: $ldvm.shouldShowLeaveAReviewView) {
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
            }

            .alert(isPresented: $showGuestAlert) {
                Alert(title: Text("Sign In First"), message: Text("You must be signed in to leave reviews"), primaryButton: .default(Text("Sign In"), action: {
                    UserDefaults.standard.set(false, forKey: "signedIn")
                    userStore.isSignedIn = false
                    userStore.user = User()
                    UserDefaults.standard.set(false, forKey: K.UserDefaults.isGuest)
                }), secondaryButton: .cancel())
            }
            
    }
    
    
    //MARK: - SubViews
    
    private var header: some View {
        HStack {
            backButton
                .frame(width: 30, height: 30)
                .padding(.leading)
                .offset(y: imageMaxHeight / 6)
                .padding(.top, 50)


            headerText
                .padding(.leading, -40)
                .padding(.trailing)
                .offset(y: imageMaxHeight / 4)

        }
        .padding(.top, 25)
        
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
            ZStack {
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
//                header/
//              .opacity(self.getBlurRadiusForImage(geo) - 0.35)

            }
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
            .lineLimit(1)

    }
    
    private var avgRatingDisplay: some View {
        let total = ldvm.selectedLocation?.averageRating?.numberOfReviews ?? 0
        let textEnding = total == 1 ? "" : "s"
        let avg = ldvm.selectedLocation?.averageRating?.avgRating ?? 0
//        let avg = SchnozPlace.example.averageRating?.avgRating ?? 0
        
        let rating = (avg / 5) * 100
        return
            VStack(alignment: .leading, spacing: 7) {
                GradientStars(fillPercent: .constant(rating), starSize: 0.007, spacing: -40)
                    .frame(height: 40)
                    .offset(x: -25)
//                GradientStars(fillPercent: .constant(Float(ldvm.selectedLocation?.averageRating?.avgRating ?? 0)), starSize: 30)
//                SlidingStarsGradient(fillPercent: .constant(Float(ldvm.selectedLocation?.averageRating?.avgRating ?? 0)), frame: (100, 60))
                //            Stars(color: oceanBlue.yellow,
                //                  rating: .constant(ldvm.selectedLocation?.averageRating?.avgRating ?? 0))
                //
                Text("(\(total) review\(textEnding))")
                    .font(.avenirNextRegular(size: 17))
                    .foregroundColor(oceanBlue.lightBlue)
                if userStore.isGuest {
                    leaveAReviewGuestButton
                } else {
                    leaveAReviewLink
                }
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
            Spacer(minLength: 200)
        }
    }
    
    private var leaveAReviewLink: some View {

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
    }
    
    private var leaveAReviewGuestButton: some View {
        Button(action: leaveAReviewTapped) {
            Text("Leave A Review")
                .font(.avenirNextRegular(size: 17))
                .foregroundColor(oceanBlue.lightBlue)
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
                ReviewCell(review: review, isShowingLocationName: false, needsToHandleColorScheme: true)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .onAppear {
                        let isLast = ldvm.reviews.last == review
                        ldvm.listHasScrolledToBottom = isLast
                    }
            }
        .padding(.horizontal, -20)
            .listStyle(.plain)
            .frame(minHeight: 250 * CGFloat(ldvm.reviews.count))
//            .scrollDisabled(true)
//            .frame(height: 250 * CGFloat(ldvm.reviews.count))
                .modifier(ClearListBackgroundMod())
            .task {
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
            Spacer()

        }
    }
    
    private var sortReviewsButton: some View {
        HStack {
            Spacer()
            Text("Sort by:")
                .font(.caption)
                .foregroundColor(oceanBlue.blue)
            Button(action: sortReviewsTapped) {
                Text(ldvm.sortingOption.rawValue)
                    .font(.caption)
                    .foregroundColor(oceanBlue.lightBlue)
            }
        }
        .opacity(ldvm.reviews.count > 1 ? 1 : 0)
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
        self.presentationMode.wrappedValue.dismiss()
        listResultsVM.shouldShowPlaceDetails = false
    }
    
    private func sortReviewsTapped() {
        showReviewSortActionSheet = true
    }
    
//    private func fetchFirebaseReviews() {
//        firebaseManager.fetchLatestTenReviewsForLocation(self.location?.placeID ?? "") { reviews in
//            // Actually removed limit, fetches all
//            self.location?.schnozReviews = reviews
//            self.reviews = reviews
//        }
//    }
    
    private func leaveAReviewTapped() {
//        if userStore.isGuest {
            self.showGuestAlert = true
//        } else {
//            ldvm.shouldShowLeaveAReviewView = true
//        }
    }
    
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

