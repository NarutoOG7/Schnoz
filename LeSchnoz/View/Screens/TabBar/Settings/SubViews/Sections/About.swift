//
//  About.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/14/22.
//

import SwiftUI

struct About: View {
    
    
    @ObservedObject  var settingsVM = SettingsVM.instance
    let oceanBlue = K.Colors.OceanBlue.self
    
    var body: some View {
        VStack {
            SettingsHeader(settingType: .about)
            List {
                tutorials
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                
                privacyPolicy
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                termsOfUse
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                    .padding(.bottom)
            }
            .listStyle(.plain)
            .frame(minHeight: 150)
            .modifier(DisabledScroll())
            .modifier(ClearListBackgroundMod())
        }

    }
    
    private var tutorials: some View {
        Button {
            settingsVM.showsTutorial = true
        } label: {
            Text("Show Tutorials")
                .font(.avenirNext(size: 18))
                .foregroundColor(oceanBlue.white)
        }

    }
    
    private var privacyPolicy: some View {
        let view: AnyView
        if let url = URL(string: "https://doc-hosting.flycricket.io/schnoz-privacy-policy/4dc19f06-dfde-4b12-8989-896ef2e80db8/privacy") {
            view = AnyView(
                Link(destination: url, label: {
                    Text("Privacy Policy")
                        .font(.avenirNext(size: 18))
                        .foregroundColor(oceanBlue.white)
                })
            )
        } else {
            view = AnyView(EmptyView())
        }
        return view
    }
    
    private var termsOfUse: some View {
        let view: AnyView
        if let url = URL(string: "https://doc-hosting.flycricket.io/schnoz-terms-of-use/cd5ec802-dae9-44b0-bf2e-3366837462dc/terms") {
            view = AnyView(
                Link(destination: url, label: {
                    Text("Terms Of Use")
                        .font(.avenirNext(size: 18))
                        .foregroundColor(oceanBlue.white)
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
