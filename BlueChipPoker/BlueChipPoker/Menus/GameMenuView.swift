//
//  GameMenuView.swift
//  BlueChipPoker
//
//  Created by Ameer Mubarez on 10/31/21.
//

import SwiftUI

struct GameMenuView: View {
    @Binding var isPresented: Bool
    var body: some View {
        ZStack{
            Image("menuBackground")
                .resizable()
                .scaledToFit()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 0){
                Text("Establishing Player as Host and searching for connections nearby")
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, alignment: .center)
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            HStack(spacing: 40){
                VStack{
                    // Create list to load nearby connections
                    Text("Connections Nearby: ")
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.black.opacity(0.78))
                        .shadow(color: Color.black.opacity(0.12), radius: 4, x: 2, y: 2)
                        .cornerRadius(14)
                } // VStack
                VStack{
                    // Update number of players added as players join
                    Text("Players added: ")
                        .foregroundColor(Color.white)
                    Button(action:{
                        print("Start Game")
                    }) {
                        Text("Start Game")
                            .padding()
                            .background(Color("MenuButtonColors"))
                            .foregroundColor(Color.white)
                            .cornerRadius(14)
                            .shadow(color: Color.black.opacity(0.12), radius: 4, x: 2, y: 2)
                    }
                } // VStack
            } // HStack
        } // ZStack
    } // body
} // GameMenuView

/*struct GameMenuView_Previews: PreviewProvider {
    static var previews: some View {
        GameMenuView(true)
    }
}
*/
