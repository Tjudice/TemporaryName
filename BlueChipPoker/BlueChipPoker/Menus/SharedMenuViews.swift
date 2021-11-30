//
//  SharedMenuViews.swift
//  BlueChipPoker
//
//  Created by Ameer Mubarez on 11/25/21.
//

import SwiftUI

struct bgView : View{
    var body: some View{
        Image("menuBackground")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: UIScreen.main.bounds.size.width, maxHeight: .infinity)
            .ignoresSafeArea(.all)
    }
}

// Navigation Bar Element
struct navBarView : View {
    @Binding var isPresented: Bool
    @EnvironmentObject var userInfo : UserInfo
    @EnvironmentObject var mpSesh : MultiPeerViewModel
    var inGameMenu : Bool = false
    var body: some View{
        HStack{
            if isPresented != false{
                Button(action:{
                    if inGameMenu{
                        mpSesh.return_to_menu()
                    }
                    isPresented.toggle()
                }){
                    Image(systemName: "chevron.backward.circle.fill")
                        .foregroundColor(Color("MenuButtonColors"))
                }.frame(alignment: .center)
                    .padding()
                Spacer()
            } // if
            Text("Welcome " + userInfo.username + "!")
                .foregroundColor(Color.white)
                .frame(alignment: .center)
            Spacer()
            Text("Balance: $" + String(userInfo.balance))
                .foregroundColor(Color.white)
                .frame(alignment: .trailing)
                .padding()
        } .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
            .background(Color.black)
    }
}
