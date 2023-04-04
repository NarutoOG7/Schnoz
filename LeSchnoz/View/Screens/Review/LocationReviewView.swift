//
//  LocationReviewView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/18/22.
//

import SwiftUI

struct LocationReviewView: View {
    
    @Binding var isPresented: Bool
    @Binding var review: ReviewModel?
    @Binding var location: SchnozPlace
    
    @State var isUpdatingReview: Bool
    @State var titleInput: String = ""
    @State var pickerSelection: Int = 0
    @State var descriptionInput: String = ""
    @State var isAnonymous: Bool = false
    @State var nameInput: String = ""
    
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
            .navigationTitle(review?.locationName ?? location.primaryText ?? "")
            .navigationBarTitleDisplayMode(.inline)
            
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
            Stars(count: 10,
                  isEditable: true,
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
                    input: $nameInput,
                    shouldShowErrorMessage: .constant(false),
                    isSecured: .constant(false),
                    primaryColor: oceanBlue.yellow,
                    accentColor: oceanBlue.white,
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
            let name = nameInput == "" ? userStore.user.name : nameInput
            let rev = ReviewModel(
                id: "",
                rating: pickerSelection,
                review: descriptionInput,
                title: titleInput,
                username: isAnonymous ? "Anonymous" : name,
                locationID: review?.locationID ?? "",
                locationName: location.primaryText ?? "")
                        
            if isUpdatingReview && isUpdated() {
                self.location.placeID = review?.locationID ?? ""
                
                firebaseManager.updateReviewInFirestore(rev, forID: self.review?.id ?? rev.id) { error in
                    if let error = error {
                        self.errorManager.message = error.rawValue
                        self.errorManager.shouldDisplay = true
                    }
                    ListResultsVM.instance.refreshData(rev, placeID: location.placeID, isRemoving: false, isAddingNew: false)
                    self.shouldShowSuccessMessage = true
                }
            } else {
                firebaseManager.addReviewToFirestoreBucket(rev, location: location) { error in
                    if let error = error {
                        self.errorManager.message = error.rawValue
                        self.errorManager.shouldDisplay = true
                    }
                    self.shouldShowSuccessMessage = true
//                    LDVM.instance.recentlyPublishedReview = rev
                    ListResultsVM.instance.refreshData(rev, placeID: location.placeID, isRemoving: false, isAddingNew: true)
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
        LocationReviewView(
                           isPresented: .constant(true),
                           review: .constant(nil),
                           location: .constant(SchnozPlace(placeID: "Place01")),
                           isUpdatingReview: false,
                           userStore: UserStore(),
                           firebaseManager: FirebaseManager(),
                           errorManager: ErrorManager())
    }
}


class LDVM: ObservableObject {
    static let instance = LDVM()
    
    @Published var recentlyPublishedReview: ReviewModel?
}
