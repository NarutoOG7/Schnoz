//
//  Constants.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/23/22.
//

import SwiftUI


//MARK: - K for Constant
enum K {
    
    //MARK: - Colors
    enum Colors {
        
        enum OceanBlue {
            static let lightBlue = Color("OceanBlue/LightBlue")
            static let white = Color("OceanBlue/White")
            static let blue = Color("OceanBlue/Blue")
            static let yellow = Color("OceanBlue/Yellow")
            static let black = Color("OceanBlue/Black")
            static let grayPurp = Color("OceanBlue/GrayPurp")
        }
        
    }
    
    //MARK: - Error Messages
    
    enum ErrorHelper {

        enum ErrorType {
            case email, username, password, confirmPassword, firebase
        }
            
            enum Errors {
                case usernameTaken
                case unrecognizedEmail
                case incorrectEmail
                case insufficientPassword
                case emailInUse
                case emailIsBadlyFormatted
                case incorrectPassword
                case passwordsDontMatch
                case troubleConnectingToFirebase
                case firebaseTrouble
                case failedToSaveUser
        
                func message() -> String {
                    let authMessages = K.ErrorHelper.Messages.Auth.self
                    let networkMessages = K.ErrorHelper.Messages.Network.self
                    switch self {
                        
                    case .usernameTaken:
                        return authMessages.usernameExists.rawValue
                        
                    case .unrecognizedEmail:
                        return authMessages.unrecognizedEmail.rawValue
                        
                    case .incorrectEmail:
                        return authMessages.incorrectEmail.rawValue
                        
                    case .insufficientPassword:
                        return authMessages.insufficientPassword.rawValue
                        
                    case .emailInUse:
                        return authMessages.emailInUse.rawValue
                        
                    case .emailIsBadlyFormatted:
                        return authMessages.emailIsBadlyFormatted.rawValue
                        
                    case .incorrectPassword:
                        return authMessages.incorrectPassword.rawValue
                        
                    case .passwordsDontMatch:
                        return authMessages.passwordsDontMatch.rawValue
                        
                    case .troubleConnectingToFirebase:
                        return networkMessages.troubleConnectingToFirebase.rawValue
                        
                    case .firebaseTrouble:
                        return networkMessages.firebaseTrouble.rawValue
                        
                    case .failedToSaveUser:
                        return authMessages.failedToSaveUser.rawValue
                        
                    }
                }
        }
        
        struct Messages {
            
            enum Review: String {
                case savingReview = "There was an error saving your review. Please check your connection and try again."
                case updatingReview = "There was an error updating the review. Please check your connection and try again."
            }
            enum Auth: String {
                case usernameBlank = "Please provide a name."
                case usernameExists = "Username already exists."
                case failToSignOut = "There was an error signing out of your account. Check your connection and try again."
                case failedToSaveUser = "There was a problem saving the user"
                
                case emailBlank = "Please provide an email address."
                case unrecognizedEmail = "This email isn't recognized."
                case incorrectEmail = "Email is invalid."
                case emailIsBadlyFormatted = "This is not recognized as an email."
                case emailInUse = "This email is already in use."
                
                case passwordBlank = "Please provide a password."
                case incorrectPassword = "Password is incorrect."
                case insufficientPassword = "Password must be at least 6 characters long."
                case passwordsDontMatch = "Passwords DO NOT match"
                
            }
            enum Network: String {
                case troubleConnectingToFirebase = "There seems to be an issue with the connection to firebase."
                case firebaseTrouble = "There was an issue creating your account."
                case firebaseConnection = "There was an error with firebase. Check your connection and try again."
            }
        }
    }
    
    
    //MARK: - Images
    
    enum Images {
        
        enum Login {
            static let email = Image(systemName: "envelope.fill")
            static let eyeWithSlash = Image(systemName: "eye.slash.fill")
            static let eye = Image(systemName: "eye")
        }
        
        enum SearchTypes {
            static let breakfast = Image("breakfast")
            static let lunch = Image("lunch")
            static let dinner = Image("dinner")
            static let blueBreakfast = Image("blueBreakfast")
            static let blueLunch = Image("blueLunch")
            static let blueDinner = Image("blueDinner")
        }
        
        static let splashOne = Image("SplashOne")
        static let splashTwo = Image("SplashTwo")
        static let logo = Image("Logo")
        static let share = Image(systemName: "square.and.arrow.up")
        static let placeholder = Image(systemName: "photo")
        static let simpleLogo = Image("SchnozLogoOutline")
        
    }
    
    //MARK: - UserDefaults
    
    enum UserDefaults {
        static let user = "user"
        static let isGuest = "isGuest"
        static let showTutorial = "shouldShowTutorial"
    }
    
    enum GhostKeys {
        static let file = "GhostKeys"
    }
}
