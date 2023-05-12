//
//  SplashScreen.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/13/22.
//

import SwiftUI

struct SplashScreen: View {
    
    @ObservedObject var contentViewVM: ContentViewVM
    
    private let oceanBlue = K.Colors.OceanBlue.self
    
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                K.Colors.OceanBlue.blue
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 80) {
                    
                    headline
                        .padding(.bottom, 20)
                    badReviewView
                    goodReviewView
                        .padding(.bottom, 30)
                    continueButton
                }

            }
        }
    }
    
    private var headline: some View {
        Text("This app is to rate establishment's **ventilation** quality.")
            .foregroundColor(oceanBlue.white)
            .font(.avenirNext(size: 21))
            .multilineTextAlignment(.center)
            .italic()
            .padding(.horizontal, 20)
            
    }
    
    private var badReviewView: some View {
        reviewView(rating: 1,
                   message: Text("1 star means your clothes _**smelled like the restaraunt**_ when you left."))
//            .foregroundColor(oceanBlue.white)
//            .font(.avenirNext(size: 20))
//            .fontWeight(.semibold))
    }
    
    private var goodReviewView: some View {
        reviewView(rating: 5,
                   message:
            Text("5 stars mean your clothes _**smelled the same**_ as when you walked in."))

    }

    private func reviewView(rating: Int, message: Text) -> some View {
        VStack(spacing: 10) {
            Stars(color: oceanBlue.yellow,
                  rating: .constant(rating))
            message
                .foregroundColor(oceanBlue.white)
                .font(.avenirNext(size: 20))
                .fontWeight(.regular)
                    }.padding(.horizontal, 30)
//        }
    }
    
    private var continueButton: some View {
        HStack {
            Spacer()
            
            Button(action: continueTapped) {
                Text("Continue")
                    .foregroundColor(oceanBlue.white)
                    .font(.avenirNext(size: 21))
                    .fontWeight(.semibold)
            }
        }
        .padding(.trailing, 20)
    }
    
    private func continueTapped() {
        contentViewVM.showTutorial = false
        SettingsVM.instance.showsTutorial = false
    }
}




//MARK: - Preview
struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen(contentViewVM: ContentViewVM())
            .previewInterfaceOrientation(.portrait)
    }
}


