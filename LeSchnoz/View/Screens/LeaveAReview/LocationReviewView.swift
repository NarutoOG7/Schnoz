//
//  LocationReviewView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/18/22.
//

import SwiftUI
import Firebase

struct LocationReviewView: View {
    
    @Binding var isPresented: Bool
    @Binding var review: ReviewModel?
    @Binding var location: SchnozPlace?
    @Binding var reviews: [ReviewModel]
    
    @State var oldReview: ReviewModel?
    @State var isUpdatingReview: Bool
    @State var titleInput: String = ""
    @State var pickerSelection: CGFloat = 0
    @State var descriptionInput: String = ""
    @State var isAnonymous: Bool = false
    //    @State var nameInput: String = ""
    
    @State var shouldShowTitleErrorMessage = false
    @State var shouldShowDescriptionErrorMessage = false
    @State var shouldShowSuccessMessage = false
    
    //MARK: - Focused Text Field
    @FocusState private var focusedField: Field?
    
    @ObservedObject var userStore: UserStore
    @ObservedObject var firebaseManager = FirebaseManager.instance
    @ObservedObject var errorManager: ErrorManager
    @ObservedObject var ldvm = LDVM.instance
    
    @Environment(\.presentationMode) var presentationMode
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    var body: some View {
        ZStack {
            oceanBlue.blue
                .edgesIgnoringSafeArea(.vertical)
            
            //            if userStore.isGuest {
            //                Text("Sign in to write reviews")
            //                    .foregroundColor(oceanBlue.white)
            //            } else {
            VStack(spacing: 20) {
                GradientStars(isEditable: true, fillPercent: $pickerSelection, starSize: 0.01, spacing: -15)
                //                    CustomStarRating(currentValue: $pickerSelection, starSize: (200,40))
                //                        .frame(width: 200)
                //                    GradientStars(fillPercent: $picker Selection, starSize: 40)
                    .padding(.horizontal)
                    .frame(height: 70)
                //                        SlidingStarsGradient(fillPercent: $pickerSelection, frame: (100, 60))
                //                            .frame(height: 60)
                //                            .padding(.vertical, 20)
                starScore
                title
                description
                anonymousOption
                submitButton
                    .padding(.top, 35)
                //                    }
            }
            .padding()
            .navigationTitle(review?.locationName ?? location?.primaryText ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButton
                }
                
            }
            
            .task {
                self.oldReview = review
                if self.location?.gmsPlace == nil {
                    GooglePlacesManager.instance.getPlaceDetails(location?.placeID ?? "") { gmsPlace, error in
                        if let gmsplace = gmsPlace {
                            self.location?.gmsPlace = gmsplace
                        }
                    }
                }
                if self.location?.averageRating == nil {
                    firebaseManager.getAverageRatingForLocation(location?.placeID ?? "") { avg in
                        if let avg = avg {
                            self.location?.averageRating = avg
                        }
                    }
                }
            }
            
            
            //            }
        }
        .alert("Success", isPresented: $shouldShowSuccessMessage, actions: {
            Button("OK", role: .cancel, action: { self.presentationMode.wrappedValue.dismiss() })
        })
        
        .onSubmit {
            switch focusedField {
            case .title:
                focusedField = .description
                //            case .description:
                //                focusedField = .username
            default: break
            }
        }
        .onAppear {
            let isGuest = userStore.isGuest
            let isNameless = userStore.user.name == ""
            self.isAnonymous = isGuest || isNameless
        }
        
    }
    
    private var starScore: some View {
        let score = ((pickerSelection / 100) * 5)
        return Text(String(format: "%.1f", score))
            .fontWeight(.black)
            .font(.title)
            .foregroundColor(
                Double(score).ratingTextColor())
        
    }
    
    
    private var title: some View {
        UserInputCellWithIcon(
            input: $titleInput,
            shouldShowErrorMessage: $shouldShowTitleErrorMessage,
            isSecured: .constant(false),
            primaryColor: oceanBlue.yellow,
            accentColor: oceanBlue.white,
            icon: nil,
            placeholderText: "Title",
            errorMessage: "Please add a title.")
        .focused($focusedField, equals: .title)
        .submitLabel(.next)
    }
    
    //    private var stars: some View {
    //        HStack {
    //            Stars(isEditable: true,
    //                  color: K.Colors.OceanBlue.yellow,
    //                  rating: $pickerSelection)
    //        }
    //    }
    
    private var description: some View {
        UserInputCellWithIcon(
            input: $descriptionInput,
            shouldShowErrorMessage: $shouldShowDescriptionErrorMessage,
            isSecured: .constant(false),
            primaryColor: oceanBlue.yellow,
            accentColor: oceanBlue.white,
            icon: nil,
            placeholderText: "Description",
            errorMessage: "Please add a description.")
        .focused($focusedField, equals: .description)
        .submitLabel(.next)
    }
    
    private var anonymousOption: some View {
        VStack(spacing: 12) {
            if !isAnonymous {
                UserInputCellWithIcon(
                    input: .constant(userStore.user.name),
                    shouldShowErrorMessage: .constant(false),
                    isSecured: .constant(false),
                    primaryColor: oceanBlue.yellow,
                    accentColor: oceanBlue.white,
                    icon: nil,
                    placeholderText: userStore.user.name,
                    errorMessage: "")
                .focused($focusedField, equals: .username)
                .submitLabel(.done)
                .disabled(true)
            }
            Toggle(isOn: $isAnonymous) {
                Text("Leave Review Anonymously?")
                    .italic()
                    .font(.avenirNextRegular(size: 17))
                    .foregroundColor(oceanBlue.yellow)
            }.padding(.horizontal)
                .tint(oceanBlue.yellow)
        }
    }
    
    private var submitButton: some View {
        let isReview = review != nil
        let isDisabled = !requisiteFieldsAreFilled() || !isUpdated()
        let color = isDisabled ? oceanBlue.blue.opacity(0.1) : oceanBlue.yellow
        return Button(action: submitTapped) {
            Text(isReview && isUpdated() ? "Update" : "Submit")
                .foregroundColor(color)
                .font(.avenirNextRegular(size: 20))
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color))
            
        }
        .disabled(isDisabled)
    }
    
    private func submitTapped() {
        checkRequiredFieldsAndAssignErrorMessagesAsNeeded()
        if requisiteFieldsAreFilled() {
            let rev = reviewModel()
            if isUpdatingReview && isUpdated() {
                update(rev)
            } else {
                add(rev)
            }
        }
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
            //            .padding(.horizontal)
            //                .padding(.top, 60)
            Spacer()
            
        }
    }
    
    
    func addressFromSecondaryText(_ secondaryText: String) -> Address {
        var address = Address()
        // Split the address by commas
        let addressComponents = secondaryText.components(separatedBy: ",")
        if addressComponents.count == 4 {
            
            if let streetComponent = addressComponents.first {
                address.address = streetComponent
                print(address.address)
                print(streetComponent)
            }
            let cityCompontent = addressComponents[1]
            address.city = cityCompontent
            
            let stateComponent = addressComponents[2]
            let trimmedComponent = stateComponent.trimmingCharacters(in: .whitespaces)
            if trimmedComponent.rangeOfCharacter(from: .decimalDigits) != nil {
                address.zipCode = trimmedComponent
            } else {
                address.state = trimmedComponent
            }
            
            if let lastComponent = addressComponents.last {
                address.country = lastComponent
            }
        }
        return address
    }
    
    private func reviewModel() -> ReviewModel {
        //        let name = nameInput == "" ? userStore.user.name : nameInput
        let userName = userStore.user.name
        let name = userName == "" ? "Anonymous" : userName
        let secondaryText = location?.secondaryText ?? ""
        let altAddress = addressFromSecondaryText(secondaryText)
        let firstAddressIsEmpty = location?.address == nil
        let address = firstAddressIsEmpty ? altAddress : location?.address
        
        return ReviewModel(
            id: review?.id ?? UUID().uuidString,
            rating: (Double(pickerSelection / 100))*5,
            review: descriptionInput,
            title: titleInput,
            username: isAnonymous ? "Anonymous" : name,
            userID: userStore.user.id,
            locationID:  review?.locationID ?? location?.placeID ?? "",
            locationName: review?.locationName ?? location?.primaryText ?? "",
            timestamp: review?.timeStamp ?? Timestamp(),
            address: review?.address ?? address ?? Address())
    }
    
    private func update(_ newRev: ReviewModel) {
        //        self.location?.placeID = review?.locationID ?? ""
        var oldReview: ReviewModel?
        
        firebaseManager.updateReviewInFirestore(newRev) { error in
            if let error = error {
                self.errorManager.message = error.rawValue
                self.errorManager.shouldDisplay = true
            }
            if let oldReviewIndex = self.location?.schnozReviews.firstIndex(where: { $0.id == review?.id }) {
                self.location?.schnozReviews[oldReviewIndex] = newRev
            }
            //            if let reviewIndex = self.
            //            if let reviewIndex = self.reviews.firstIndex(where: { $0.id == rev.id }) {
            //                oldReview = self.reviews[reviewIndex]
            //                self.reviews[reviewIndex] = rev
            //            }
            ListResultsVM.instance.refreshData(review: newRev,
                                               averageRating: updatedAverageRating(newRev, isUpdating: true),
                                               placeID: location?.placeID ?? review?.locationID ?? "",
                                               refreshType: .update)
            if var firestoreUser = userStore.firestoreUser, var oldReview = self.review {
                self.oldReview = oldReview
                //                let newUser = firestoreUser.handleUpdateOfReview(oldReview: oldReview, newReview: rev)
                let difference = newRev.rating - oldReview.rating
                print(difference)
                firestoreUser.totalStarsGiven? += difference
                firestoreUser.averageStarsGiven = firestoreUser.totalStarsGiven ?? 1 / Double(firestoreUser.reviewCount ?? 1)
                //                userStore.firestoreUser = newUser
                firebaseManager.updateFirestoreUser(firestoreUser)
            }
            self.shouldShowSuccessMessage = true
        }
    }
    
    private func add(_ review: ReviewModel) {
        let rev = review
        firebaseManager.addReviewToFirestoreBucket(rev, location) { error in
            if let error = error {
                self.errorManager.message = error.rawValue
                self.errorManager.shouldDisplay = true
            }
            
            //            if !self.location.schnozReviews.contains(rev) {
            //                self.location.schnozReviews.append(rev)
            //            }
            //                self.reviews.append(rev)
            self.location?.schnozReviews.append(rev)
            ListResultsVM.instance.refreshData(
                review: rev,
                averageRating: updatedAverageRating(rev, isUpdating: false),
                placeID: location?.placeID ?? rev.locationID,
                refreshType: .add)
            if var firestoreUser = userStore.firestoreUser {
                //                    let newUser = firestoreUser.handleAdditionOfReview(rev)
                firestoreUser.totalStarsGiven? += rev.rating
                firestoreUser.reviewCount? += 1
                firestoreUser.averageStarsGiven = firestoreUser.totalStarsGiven ?? 1 / Double(firestoreUser.reviewCount ?? 1)
                //                    userStore.firestoreUser = newUser
                firebaseManager.updateFirestoreUser(firestoreUser)
            }
            self.shouldShowSuccessMessage = true
        }
        
    }
    
    func updatedAverageRating(_ rev: ReviewModel, isUpdating: Bool) -> AverageRating {
        let placeID = location?.placeID ?? review?.locationID ?? ""
        let preExistingAVG = self.location?.averageRating
        let newAverageRating = AverageRating(placeID: placeID)
        let differenceInRating = rev.rating - (oldReview?.rating ?? 0)
        var returnableAVG = preExistingAVG ?? newAverageRating
        returnableAVG.totalStarCount += differenceInRating
        returnableAVG.numberOfReviews += isUpdating ? 0 : 1
        returnableAVG.avgRating = returnableAVG.totalStarCount / Double(returnableAVG.numberOfReviews)

        if ldvm.selectedLocation?.placeID == placeID {
            ldvm.selectedLocation?.averageRating = returnableAVG
        }
        firebaseManager.addAverageRating(returnableAVG)
        return returnableAVG
        
    }
    private func requisiteFieldsAreFilled() -> Bool {
        return titleInput != "" && descriptionInput != ""
    }
    
    private func checkRequiredFieldsAndAssignErrorMessagesAsNeeded() {
        
        if titleInput == "" {
            self.shouldShowTitleErrorMessage = true
        } else {
            self.shouldShowTitleErrorMessage = false
        }
        
        if descriptionInput == "" {
            self.shouldShowDescriptionErrorMessage = true
        } else {
            self.shouldShowDescriptionErrorMessage = false
        }
    }
    
    private func isUpdated() -> Bool {
        titleInput != review?.title ||
        descriptionInput != review?.review ||
        pickerSelection != CGFloat(review?.rating ?? 0)
        //        nameInput != review?.username
    }
    
    private func backButtonTapped() {
        self.presentationMode.wrappedValue.dismiss()
        LDVM.instance.shouldShowLeaveAReviewView = false
    }
    
    //MARK: - Field
    enum Field {
        case title, description, username
    }
}

struct LocationReviewView_Previews: PreviewProvider {
    static var previews: some View {
        LocationReviewView(
            isPresented: .constant(true),
            review: .constant(nil),
            location: .constant(SchnozPlace(placeID: "Place01")),
            reviews: .constant([ReviewModel]()),
            isUpdatingReview: false,
            userStore: UserStore(),
            errorManager: ErrorManager())
    }
}


