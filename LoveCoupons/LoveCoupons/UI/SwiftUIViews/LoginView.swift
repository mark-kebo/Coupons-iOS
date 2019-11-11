//
//  ContentView.swift
//  Test
//
//  Created by Dmitry Vorozhbicki on 11/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        Button(action: {
            print("lol")
        }){
            Text("Login")
                .font(.title)
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color("AppRed"))
                .cornerRadius(40)
        }
    .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
