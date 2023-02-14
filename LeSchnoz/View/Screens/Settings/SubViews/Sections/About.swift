//
//  About.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/14/22.
//

import SwiftUI

struct About: View {
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    var body: some View {
        VStack {
            SettingsHeader(settingType: .about)
            List {

                privacyPolicy
                    .listRowBackground(weenyWitch.black)
                    .listRowSeparator(.hidden)

                termsOfUse
                    .listRowBackground(weenyWitch.black)
                    .listRowSeparator(.hidden)

                    .padding(.bottom)
            }
            .listStyle(.plain)
            .frame(minHeight: 80)
            .modifier(DisabledScroll())
            .modifier(ClearListBackgroundMod())
        }

    }
    
    private var privacyPolicy: some View {
        let view: AnyView
        if let url = URL(string: "https://pages.flycricket.io/spookyspots/privacy.html") {
            view = AnyView(
                Link(destination: url, label: {
                    Text("Privacy Policy")
                        .font(.avenirNext(size: 18))
                        .foregroundColor(weenyWitch.lighter)
                })
            )
        } else {
            view = AnyView(EmptyView())
        }
        return view
    }
    
    private var termsOfUse: some View {
        let view: AnyView
        if let url = URL(string: "https://pages.flycricket.io/spookyspots/terms.html") {
            view = AnyView(
                Link(destination: url, label: {
                    Text("Terms Of Use")
                        .font(.avenirNext(size: 18))
                        .foregroundColor(weenyWitch.lighter)
                })
            )
        } else {
            view = AnyView(EmptyView())
        }
        return view
    }
 
}

struct About_Previews: PreviewProvider {
    static var previews: some View {
        About()
    }
}
