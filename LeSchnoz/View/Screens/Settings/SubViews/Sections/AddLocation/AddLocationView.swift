//
//  AddLocationView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/19/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct AddLocationView: View {
    
    @State var nameInput = ""
    
    @State var addressInput = ""
    @State var cityInput = ""
    @State var stateInput = ""
    @State var countryInput = ""
    @State var zipCodeInput = ""
    
    @State var showingImagePicker = false
    @State var inputImage: UIImage?
    @State var imageToDisplay: Image?
    
    @State var imageSourceInput = ""
    
    @State var descriptionInput = ""
    
    @State var moreInfoLinkInput = ""
        
    @State var shouldDisplayOwnershipQuestionAlert = false
    @State var shouldDisplayImageUnavailableWithoutRightsAlert = false
    @State var shouldDipslayLocationSubmitConfirmationAlert = false
    
    @State var shouldShowLocationNameError = false
    @State var shouldShowCityErrorMessage = false
    @State var shouldShowCountryErrorMessage = false
    
    
    //MARK: - Focused Text Field
    @FocusState private var focusedField: Field?
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let weenyWitch = K.Colors.OceanBlue.self
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                imagePicker
                if imageToDisplay != nil {
                    imageSource
                }
                name
                address
                description
                moreInfoLinkView
                submitButton
                    .padding(.vertical, 30)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .alert("STOP", isPresented: $shouldDisplayOwnershipQuestionAlert, actions: {
            Button("YES", role: .cancel, action: {})
            Button("NO", role: .destructive, action: { self.shouldDisplayImageUnavailableWithoutRightsAlert = true })
        }, message: {
            Text("Do you own this image or have permission to upload?")
        })
        
        .alert("Image Unavailable", isPresented: $shouldDisplayImageUnavailableWithoutRightsAlert, actions: {
            Button("OK", role: .cancel, action: { self.imageToDisplay = nil })
        }, message: {
            Text("Apologies, but we cannot use images we don't have permission for.")
        })
        
        .alert("Location Submitted!", isPresented: $shouldDipslayLocationSubmitConfirmationAlert, actions: {
            Button("Awesome!", role: .cancel, action: { self.submitConfirmed() })
            Button("Whoops, UNDO", role: .destructive, action: {})
        })
        
        .onSubmit {
            switch focusedField {
            case .imageSource:
                focusedField = .locationName
            case .locationName:
                focusedField = .streetAddress
            case .streetAddress:
                focusedField = .city
            case .city:
                focusedField = .state
            case .state:
                focusedField = .country
            case .country:
                focusedField = .zipCode
            case .zipCode:
                focusedField = .description
            case .description:
                focusedField = .moreInfoLink
            default: break
            }
        }
        
        .background(K.Colors.OceanBlue.black)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var imagePicker: some View {
        let screen = UIScreen.main.bounds.size
        return Button {
            self.showingImagePicker = true
        } label: {
            if imageToDisplay != nil {
                imageToDisplay?
            .resizable()
            .frame(width: screen.width, height: screen.height / 4)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .tint(weenyWitch.yellow)
                    .frame(width: screen.width / 2, height: screen.height / 6)
                    .padding()
            }
        }
        .onChange(of: inputImage) { _ in
            loadImage()
        }

    }
    
    private var imageSource: some View {
         UserInputCellWithIcon(
            input: $imageSourceInput,
            shouldShowErrorMessage: .constant(false),
            isSecured: .constant(false),
            primaryColor: weenyWitch.yellow,
            accentColor: weenyWitch.white,
            icon: nil,
            placeholderText: "Photographer Name (optional)",
            errorMessage: "")
         .focused($focusedField, equals: .imageSource)
         .submitLabel(.next)
     
    }
    
    private var name: some View {
         UserInputCellWithIcon(
            input: $nameInput,
            shouldShowErrorMessage: $shouldShowLocationNameError,
            isSecured: .constant(false),
            primaryColor: weenyWitch.yellow,
            accentColor: weenyWitch.white,
            icon: nil,
            placeholderText: "Location Name",
            errorMessage: "Please provide a name for this place.")
        .focused($focusedField, equals: .locationName)
        .submitLabel(.next)
    }

    //MARK: - Address
    private var address: some View {
        VStack {
            streetAddress
            cityAddress
            stateAddress
            countryAddress
            zipCodeView
        }
    }
    
    private var streetAddress: some View {
         UserInputCellWithIcon(
            input: $addressInput,
            shouldShowErrorMessage: .constant(false),
            isSecured: .constant(false),
            primaryColor: weenyWitch.yellow,
            accentColor: weenyWitch.white,
            icon: nil,
            placeholderText: "Street Address (optional)",
            errorMessage: "")
         .focused($focusedField, equals: .streetAddress)
         .submitLabel(.next)
        
    }
    private var cityAddress: some View {
        UserInputCellWithIcon(
            input: $cityInput,
            shouldShowErrorMessage: $shouldShowCityErrorMessage,
            isSecured: .constant(false),
            primaryColor: weenyWitch.yellow,
            accentColor: weenyWitch.white,
            icon: nil,
            placeholderText: "City",
            errorMessage: "Please provide a city.")
        .focused($focusedField, equals: .city)
        .submitLabel(.next)
    }
    private var stateAddress: some View {
        UserInputCellWithIcon(
            input: $stateInput,
            shouldShowErrorMessage: .constant(false),
            isSecured: .constant(false),
            primaryColor: weenyWitch.yellow,
            accentColor: weenyWitch.white,
            icon: nil,
            placeholderText: "State (optional)",
            errorMessage: "")
        .focused($focusedField, equals: .state)
        .submitLabel(.next)
    }
    private var countryAddress: some View {
        UserInputCellWithIcon(
            input: $countryInput,
            shouldShowErrorMessage: $shouldShowCountryErrorMessage,
            isSecured: .constant(false),
            primaryColor: weenyWitch.yellow,
            accentColor: weenyWitch.white,
            icon: nil,
            placeholderText: "Country",
            errorMessage: "Please provide a country.")
        .focused($focusedField, equals: .country)
        .submitLabel(.next)
    }
    private var zipCodeView: some View {
        UserInputCellWithIcon(
            input: $zipCodeInput,
            shouldShowErrorMessage: .constant(false),
            isSecured: .constant(false),
            primaryColor: weenyWitch.yellow,
            accentColor: weenyWitch.white,
            icon: nil,
            placeholderText: "Zip Code (optional)",
            errorMessage: "")
        .keyboardType(.numberPad)

    }
    
    
    var description: some View {
        TextEditor(text: $descriptionInput)
            .clearTextEditorBackground()
            .placeholder(when: descriptionInput.isEmpty, alignment: .topLeading, placeholder: {
                Text("Description (optional)")
                    .foregroundColor(weenyWitch.white)
                    .padding(.top, 7)
                    .padding(.leading, 5)
            })
            .tint(weenyWitch.yellow)
            .font(.avenirNext(size: 18))
            .padding()
            .frame(height: 250)
            .foregroundColor(weenyWitch.yellow)
            .focused($focusedField, equals: .description)
            .submitLabel(.next)
            .overlay(
                
            RoundedRectangle(cornerRadius: 16)
                .stroke(weenyWitch.yellow, lineWidth: 0.5)
            ).padding()
            .padding(.top, 20)

    }
    
    var moreInfoLinkView: some View {
         UserInputCellWithIcon(
            input: $moreInfoLinkInput,
            shouldShowErrorMessage: .constant(false),
            isSecured: .constant(false),
            primaryColor: weenyWitch.yellow,
            accentColor: weenyWitch.white,
            icon: nil,
            placeholderText: "More Info Link (optional)",
            errorMessage: "")
         .focused($focusedField, equals: .moreInfoLink)
         .submitLabel(.done)
    }
    
    //MARK: - Submit Button
    
    var submitButton: some View {
         Button(action: submitTapped) {
            Capsule()
                .fill(weenyWitch.yellow)
                .frame(width: 150, height: 45)
                .overlay(Text("Submit")
                    .font(.avenirNext(size: 18))
                    .foregroundColor(weenyWitch.blue))
            
        }
    }
    
    //MARK: - Methods
    
    func submitTapped() {
        
        checkRequiredFields()
        
        if requisiteFieldsAreFilled() {
            
            self.shouldDipslayLocationSubmitConfirmationAlert = true
        }
    }

    func submitConfirmed() {
        let address = Address(address: addressInput, city: cityInput, state: stateInput, zipCode: zipCodeInput, country: countryInput)
        let location = LocationData(id: 0, name: nameInput, address: address, description: descriptionInput, moreInfoLink: moreInfoLinkInput, locationType: nil, tours: nil, imageName: nil, distanceToUser: nil, price: nil)
        
        FirebaseManager.instance.addUserCreatedLocationToBucket(location, inputImage)
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func loadImage() {
        guard let inputImage = inputImage else {
            return
        }
        imageToDisplay = Image(uiImage: inputImage)
        self.shouldDisplayOwnershipQuestionAlert = true
    }
    
    func requisiteFieldsAreFilled() -> Bool {
        return nameInput != ""
        && cityInput != ""
        && countryInput != ""
    }
    
    func checkRequiredFields() {
        
        if nameInput == "" {
            self.shouldShowLocationNameError = true
        } else {
            self.shouldShowLocationNameError = false
        }
        
        if cityInput == "" {
            self.shouldShowCityErrorMessage = true
        } else {
            self.shouldShowCityErrorMessage = false
        }
        
        if countryInput == "" {
            self.shouldShowCountryErrorMessage = true
        } else {
            self.shouldShowCountryErrorMessage = false
        }
    }
    
    //MARK: - Field
    enum Field {
        case imageSource,
        locationName,
        streetAddress,
        city,
        state,
        country,
        zipCode,
        description,
        moreInfoLink
    }
}

//MARK: - Preview
struct AddLocationView_Previews: PreviewProvider {
    static var previews: some View {
        AddLocationView()
    }
}


