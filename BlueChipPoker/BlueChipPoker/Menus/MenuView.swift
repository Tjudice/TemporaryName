//
//  MenuView.swift
//  BlueChipPoker
//
//  Created by Ameer Mubarez on 10/31/21.
//

import SwiftUI

struct MenuView: View {
    //@EnvironmentObject var nearbyConnections : P2PSession
   // @ObservedObject var menuViewModel = MenuViewModel()
    @EnvironmentObject var mpSesh : MultiPeerViewModel
    var body: some View {
        ZStack{
            bgView()
            VStack{
                navBarView(isPresented: .constant(false))
                    .environmentObject(mpSesh)
                    .padding(.bottom, 30)
                HStack{
                    Image("Logo")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.12), radius: 4, x: 2, y: 2)
                        .padding(.leading, 10)
                        //.clipped()
                    Spacer()
                    MenuButtons()
                        .environmentObject(mpSesh)
                    Spacer()
                    tablesNearbyView()
                        .environmentObject(mpSesh)
                } //HStack
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading) // VStack
        } // ZStack
    } // body
} // MenuView


struct MenuButtons : View{
    @State private var isPresentingGameMenu : Bool = false
    @State private var isPresentingBalanceMenu : Bool = false
    //@State private var isPresentingSettings : Bool = false
    //@EnvironmentObject var nearbyConnections : P2PSession
    @EnvironmentObject var mpSesh : MultiPeerViewModel
    var body: some View{
        VStack(spacing: 40){
            Button("Create Game", action:{
                print("Game")
                mpSesh.host_game()
                isPresentingGameMenu.toggle()
            }).buttonStyle(MenuButtonStyle())
                .sheet(isPresented: $isPresentingGameMenu){
                    GameMenuView(isPresented: $isPresentingGameMenu)
                        .environmentObject(mpSesh)
                }
                .contentShape(Rectangle())
            Button("User Settings", action:{
                print("Balance")
                isPresentingBalanceMenu.toggle()
            }).buttonStyle(MenuButtonStyle())
                .sheet(isPresented: $isPresentingBalanceMenu){
                    BalanceMenuView(isPresented: $isPresentingBalanceMenu)
                }
                .contentShape(Rectangle())
            Button("How to Play", action:{
                print("User")
                mpSesh.linkToPoker()
            }).buttonStyle(MenuButtonStyle())
        } // VStack
        //.offset(x: 50)
        .padding(.leading, 15)
    }
}


// Standard custom style for all Main Menu Buttons
struct MenuButtonStyle : ButtonStyle{
    public func makeBody(configuration: MenuButtonStyle.Configuration) -> some View {
        MenuButton(configuration: configuration)
    }
    
    struct MenuButton: View {
        let configuration: MenuButtonStyle.Configuration
        var body: some View {
            configuration.label
                .padding()
                .frame(minWidth: 250)
                .background(Color("MenuButtonColors"))
                .foregroundColor(Color.white)
                .cornerRadius(14)
                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 2, y: 2)
            //.contentShape(RoundedRectangle())
        }
    }
}

// Connections Table Element
struct tablesNearbyView : View{
    //@ObservedObject var gameMenuViewModel : GameMenuViewModel
    @EnvironmentObject var mpSesh : MultiPeerViewModel
    var body: some View{
        VStack{
            // Create list to load nearby connections
            Text("Join Nearby Tables: ")
                .padding()
                .foregroundColor(Color.white)
            ScrollView(){
                let peers = mpSesh.results
                ForEach(peers.indices, id: \.self) { peer in
                    tablesNearbyRowView(userID : peers[peer])
                }
            }/*.onAppear {
                nearbyConnections.findPlayers()
            }*/
        }
        .frame(width: 300, height: 250)
        .background(Color.black.opacity(0.78))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.12), radius: 4, x: 2, y: 2)
        .padding(.leading)
        //.offset(x: 10)
        // VStack
    }
}

struct tablesNearbyRowView : View {
    @State private var isPresentingGame : Bool = false
    var userID : String
    var body: some View{
        HStack{
            Text(userID)
                .foregroundColor(Color.white)
                .frame(width: 175, alignment: .leading)
                .padding()
            Button("Join", action:{
                print("Join Table")
                isPresentingGame.toggle()
            }).sheet(isPresented: $isPresentingGame){
                GameView(isPresented: $isPresentingGame)
            }
            .frame(width: 50, alignment: .leading)
        }
    }
}


// Preview function used for development
struct MenuView_Previews: PreviewProvider {
    static let mpSesh : MultiPeerViewModel = MultiPeerViewModel()
    static let userInfo = UserInfo()
     static var previews: some View {
        MenuView()
            .previewInterfaceOrientation(.landscapeRight)
            .environmentObject(mpSesh)
            .environmentObject(userInfo)
    }
}
