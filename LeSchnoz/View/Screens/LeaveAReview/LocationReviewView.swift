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
    
    @State var isUpdatingReview: Bool
    @State var titleInput: String = ""
    @State var pickerSelection: Int = 0
    @State var descriptionInput: String = ""
    @State var isAnonymous: Bool = false
//    @State var nameInput: String = ""
    
    @State var shouldShowTitleErrorMessage = false
    @State var shouldShowDescriptionErrorMessage = false
    @State var shouldShowSuccessMessage = false
    
    //MARK: - Focused Text Field
    @FocusState private var focusedField: Field?
    
    @ObservedObject var userStore: UserStore
    @ObservedObject var firebaseManager: FirebaseManager
    @ObservedObject var errorManager: ErrorManager
    
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
                    stars
                        .padding(.vertical, 20)
                    title
                    description
                    anonymousOption
                    submitButton
                        .padding(.top, 35)
                }
                .padding()
                .navigationTitle(review?.locationName ?? location?.primaryText ?? "")
                .navigationBarTitleDisplayMode(.inline)
                
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
    
    private var stars: some View {
        HStack {
            Stars(isEditable: true,
                  color: K.Colors.OceanBlue.yellow,
                  rating: $pickerSelection)
        }
    }
    
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
    
    private func reviewModel() -> ReviewModel {
//        let name = nameInput == "" ? userStore.user.name : nameInput
        let userName = userStore.user.name
        let name = userName == "" ? "Anonymous" : userName
        return ReviewModel(
            id: review?.id ?? UUID().uuidString,
            rating: pickerSelection,
            review: descriptionInput,
            title: titleInput,
            username: isAnonymous ? "Anonymous" : name,
            locationID:  review?.locationID ?? location?.placeID ?? "",
            locationName: review?.locationName ?? location?.primaryText ?? "")
    }
    
    private func update(_ rev: ReviewModel) {
        self.location?.placeID = review?.locationID ?? ""
        var oldReview = ReviewModel()
        
        firebaseManager.updateReviewInFirestore(rev) { error in
            if let error = error {
                self.errorManager.message = error.rawValue
                self.errorManager.shouldDisplay = true
            }
            if let oldReviewIndex = self.location?.schnozReviews.firstIndex(where: { $0.id == review?.id }) {
                self.location?.schnozReviews[oldReviewIndex] = rev
            }
            if let reviewIndex = self.reviews.firstIndex(where: { $0.id == rev.id }) {
                oldReview = self.reviews[reviewIndex]
                self.reviews[reviewIndex] = rev
            }
            ListResultsVM.instance.refreshData(review: rev, averageRating: updatedAverageRating(rev), placeID: location?.placeID ?? review?.locationID ?? "", isRemoving: false, isAddingNew: false)
            var firestoreUser = FirestoreUser(user: userStore.user)
            firestoreUser.handleUpdateOfReview(oldReview: oldReview, newReview: rev)
            self.shouldShowSuccessMessage = true
        }
    }
    
    private func add(_ rev: ReviewModel) {
        if let location = location {
            firebaseManager.addReviewToFirestoreBucket(rev, location: location) { error in
                if let error = error {
                    self.errorManager.message = error.rawValue
                    self.errorManager.shouldDisplay = true
                }
                
                //            if !self.location.schnozReviews.contains(rev) {
                //                self.location.schnozReviews.append(rev)
                //            }
                self.reviews.append(rev)
                self.location?.schnozReviews.append(rev)
                ListResultsVM.instance.refreshData(
                    review: rev,
                    averageRating: updatedAverageRating(rev),
                    placeID: location.placeID,
                    isRemoving: false,
                    isAddingNew: true)
                var firestoreUser = FirestoreUser(user: userStore.user)
                firestoreUser.handleAdditionOfReview(rev)
                self.shouldShowSuccessMessage = true
            }
        }
    }
    
    func updatedAverageRating(_ rev: ReviewModel) -> AverageRating {
        let placeID = location?.placeID ?? review?.locationID ?? ""
        let preExistingAVG = self.location?.averageRating
        let newAverageRating = AverageRating(placeID: placeID,
                                             totalStarCount: 0,
                                             numberOfReviews: 0)

        var returnableAVG = preExistingAVG ?? newAverageRating
            returnableAVG.totalStarCount += rev.rating
            returnableAVG.numberOfReviews += 1
//        returnableAVG.avgRating = returnableAVG.totalStarCount / newValue
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
        pickerSelection != review?.rating 
//        nameInput != review?.username
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
                           firebaseManager: FirebaseManager(),
                           errorManager: ErrorManager())
    }
}


class LDVM: ObservableObject {
    static let instance = LDVM()
    
    @ObservedObject var firebaseManager = FirebaseManager.instance
    
    @Published var selectedLocation: SchnozPlace? 
    @Published var reviews: [ReviewModel] = []
    @Published var isFetchInProgress = false
    @Published var lastDocumentOfLocationReviews: DocumentSnapshot?
    
    @Published var errorMessage = ""
    @Published var shouldShowError = false
    
    @Published var sortingOption: ReviewSortingOption = .newest {
        didSet {
            if oldValue != sortingOption {
                self.reviews = []
                self.batchFirstCall()
            }
        }
    }
    
    @Published var listHasScrolledToBottom = false {
        willSet {
            if newValue == true {
                self.batchSubsequentCall()
            }
        }
    }
    
    func batchFirstCall() {
        if let selectedLocation = selectedLocation {
            firebaseManager.batchFirstLocationsReviews(location: selectedLocation, sortingOption, withCompletion: { reviews, error in
                self.handleReviewsCompletionWithError(reviews: reviews, error: error)
            })
        }
    }
    
    func batchSubsequentCall() {
        if let selectedLocation = selectedLocation {
            firebaseManager.nextPageLocationsReviews(location: selectedLocation, sortingOption, withCompletion: { reviews, error in
                self.handleReviewsCompletionWithError(reviews: reviews, error: error)
            })
        }
    }

    func handleReviewsCompletionWithError(reviews: [ReviewModel]?, error: Error?) {
        DispatchQueue.main.async {
            if let reviews = reviews {
                for review in reviews {
                    self.reviews.append(review)
//                    self.location.schnozReviews.append(review)
                }
            }
            
            if let error = error {
                self.handleError(error)
            }
        }
    }
    
    func handleError(_ error: Error) {
        self.errorMessage = error.localizedDescription
        self.shouldShowError = true
    }
}
