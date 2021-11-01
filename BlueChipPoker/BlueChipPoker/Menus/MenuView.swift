//
//  MenuView.swift
//  BlueChipPoker
//
//  Created by Ameer Mubarez on 10/31/21.
//

import SwiftUI

struct MenuView: View {
    @State private var isPresenting = false
    var body: some View {
        ZStack{
            Image("menuBackground")
                .resizable()
                .scaledToFit()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            HStack{
                Button(action:{
                    isPresenting.toggle()
                }) {
                    Text("Create Game")
                        .padding()
                        .background(Color("MenuButtonColors"))
                        .foregroundColor(Color.white)
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.12), radius: 4, x: 2, y: 2)
                }.sheet(isPresented: $isPresenting){
                    GameMenuView(isPresented: $isPresenting)
                }
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}

