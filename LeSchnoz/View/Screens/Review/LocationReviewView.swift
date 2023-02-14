//
//  LocationReviewView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/18/22.
//

import SwiftUI

struct LocationReviewView: View {
    
    @Binding var location: LocationModel
    @Binding var isPresented: Bool
    @Binding var review: ReviewModel?
    
    @State var titleInput: String = ""
    @State var pickerSelection: Int = 0
    @State var descriptionInput: String = ""
    @State var isAnonymous: Bool = false
    @State var nameInput: String = ""
    
    @State var shouldShowTitleErrorMessage = false
    @State var shouldShowDescriptionErrorMessage = false
    @State var shouldShowFirebaseError = false
    @State var shouldShowSuccessMessage = false
    
    @State var firebaseErrorMessage = ""
    
    //MARK: - Focused Text Field
    @FocusState private var focusedField: Field?
    
    @ObservedObject var userStore: UserStore
    @ObservedObject var firebaseManager: FirebaseManager
    @ObservedObject var errorManager: ErrorManager
    
    @Environment(\.presentationMode) var presentationMode
        
    let weenyWitch = K.Colors.WeenyWitch.self
    
    var body: some View {
        ZStack {
            weenyWitch.black
                .edgesIgnoringSafeArea(.vertical)
        
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
            .navigationTitle(location.location.name)
            
            firebaseErrorBanner

        }
        .alert("Success", isPresented: $shouldShowSuccessMessage, actions: {
            Button("OK", role: .cancel, action: { self.presentationMode.wrappedValue.dismiss() })
        })
        
        .onSubmit {
            switch focusedField {
            case .title:
                focusedField = .description
            case .description:
                focusedField = .username
            default: break
            }
        }
    }
    
    private var title: some View {
        UserInputCellWithIcon(
            input: $titleInput,
            shouldShowErrorMessage: $shouldShowTitleErrorMessage,
            isSecured: .constant(false),
            primaryColor: weenyWitch.orange,
            accentColor: weenyWitch.light,
            icon: nil,
            placeholderText: "Title",
            errorMessage: "Please add a title.")
        .focused($focusedField, equals: .title)
        .submitLabel(.next)
    }
    
    private var stars: some View {
        HStack {
            FiveStars(isEditable: true,
                      color: K.Colors.WeenyWitch.orange,
                      rating: $pickerSelection)
        }
    }
    
    private var description: some View {
         UserInputCellWithIcon(
            input: $descriptionInput,
            shouldShowErrorMessage: $shouldShowDescriptionErrorMessage,
            isSecured: .constant(false),
            primaryColor: weenyWitch.orange,
            accentColor: weenyWitch.light,
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
                    input: $nameInput,
                    shouldShowErrorMessage: .constant(false),
                    isSecured: .constant(false),
                    primaryColor: weenyWitch.orange,
                    accentColor: weenyWitch.light,
                    icon: nil,
                    placeholderText: userStore.user.name,
                    errorMessage: "")
                .focused($focusedField, equals: .username)
                .submitLabel(.done)
            }
            Toggle(isOn: $isAnonymous) {
                Text("Leave Review Anonymously?")
                    .italic()
                    .font(.avenirNextRegular(size: 17))
                    .foregroundColor(weenyWitch.lighter)
            }.padding(.horizontal)
                .tint(weenyWitch.orange)
        }
    }
    //MARK: - Error Banner
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
    
    private var submitButton: some View {
        let isReview = review != nil
        let isDisabled = !requisiteFieldsAreFilled() || !isUpdated()
        let color = isDisabled ? weenyWitch.lighter.opacity(0.1) : weenyWitch.orange
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
            
            let name = nameInput == "" ? userStore.user.name : nameInput
            let rev = ReviewModel(
                id: "",
                rating: pickerSelection,
                review: descriptionInput,
                title: titleInput,
                username: isAnonymous ? "Anonymous" : name,
                locationID: "\(location.location.id)",
                locationName: location.location.name)
            
            if self.review != nil && isUpdated() {
                
                firebaseManager.updateReviewInFirestore(rev, forID: self.review?.id ?? rev.id) { error in
                    
                    if let error = error {
                        self.firebaseErrorMessage = error.rawValue
                        self.shouldShowFirebaseError = true
                    }
                    
                    self.location.reviews.append(rev)
                    LocationStore.instance.switchNewLocationIntoAllBucketsIfExists(location)
                    self.shouldShowSuccessMessage = true
                }
            } else {
                
                firebaseManager.addReviewToFirestoreBucket(rev, location: location.location) { error in
                    
                    if let error = error {
                        self.firebaseErrorMessage = error.rawValue
                        self.shouldShowFirebaseError = true
                    }
                    
                    self.location.reviews.append(rev)
                    LocationStore.instance.switchNewLocationIntoAllBucketsIfExists(location)
                    self.shouldShowSuccessMessage = true
                }
            }
        }
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
        pickerSelection != review?.rating ||
        nameInput != review?.username
    }
    
    //MARK: - Field
    enum Field {
        case title, description, username
    }
}

struct LocationReviewView_Previews: PreviewProvider {
    static var previews: some View {
        LocationReviewView(location: .constant(LocationModel(location: .example,
                                                             imageURLs: [],
                                                             reviews: [])),
                           isPresented: .constant(true),
                           review: .constant(nil),
                           userStore: UserStore(),
                           firebaseManager: FirebaseManager(),
                           errorManager: ErrorManager())
    }
}

