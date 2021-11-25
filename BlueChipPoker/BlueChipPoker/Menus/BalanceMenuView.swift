//
//  BalanceMenuView.swift
//  BlueChipPoker
//
//  Created by Ameer Mubarez on 11/24/21.
//

import SwiftUI

struct BalanceMenuView : View{
    @Binding var isPresented: Bool
    @State private var balance = "0"
    var body: some View{
        ZStack{
            Image("menuBackground")
                .resizable()
                .scaledToFit()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack{
                TextField("Enter your name", text: $balance)
                    .keyboardType(.numberPad)
                    .frame(width: 300, height: 200)
                    .padding(10)
                    .background()
                    .cornerRadius(20)
                    .shadow(color: .gray, radius: 10)
            }
        } // ZStack
    } // body
}

// Preview function used for development
struct BalanceMenuView_Previews: PreviewProvider {
    static var previews: some View {
        BalanceMenuView(isPresented: .constant(true))
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
