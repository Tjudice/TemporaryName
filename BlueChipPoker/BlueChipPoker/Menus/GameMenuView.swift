//
//  GameMenuView.swift
//  BlueChipPoker
//
//  Created by Ameer Mubarez on 10/31/21.
//

import SwiftUI

struct GameMenuView: View {
    @Binding var isPresented: Bool
    @State private var startGame = false
    @State private var isPresentingGame : Bool = false
    //@EnvironmentObject var nearbyConnections: P2PSession
    //@ObservedObject var gameMenuViewModel = GameMenuViewModel()
    @EnvironmentObject var mpSesh : MultiPeerViewModel
    
    
    var body: some View {
        ZStack{
            bgView()
            VStack(alignment: .leading, spacing: 0){
                navBarView(isPresented: $isPresented, inGameMenu: true)
                HStack{
                    Text("Establishing Player as Host and searching for connections nearby")
                        .foregroundColor(Color.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                HStack(spacing: 40){
                    connectionsNearbyView()
                        .environmentObject(mpSesh)
                    VStack{
                        // Update number of players added as players join
                        Text("Players added: ")
                            .foregroundColor(Color.white)
                        Button(action:{
                            print("Start Game")
                            isPresentingGame.toggle()
                        }) {
                            Text("Start Game")
                                .padding()
                                .background(Color("MenuButtonColors"))
                                .foregroundColor(Color.white)
                                .cornerRadius(14)
                                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 2, y: 2)
                        }.sheet(isPresented: $isPresentingGame){
                            GameView(isPresented: $isPresentingGame)
                        }
                    } // VStack
                } // HStack
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading) // VStack
        } // ZStack
    } // body
} // GameMenuView



// Connections Table Element
struct connectionsNearbyView : View{
    //@ObservedObject var gameMenuViewModel : GameMenuViewModel
    @EnvironmentObject var mpSesh : MultiPeerViewModel
    var body: some View{
        VStack{
            // Create list to load nearby connections
            Text("Connections Nearby: ")
                .padding()
                .foregroundColor(Color.white)
            ScrollView(){
                let peers = mpSesh.results
                ForEach(peers.indices, id: \.self) { peer in
                    connectionRowView(userID : peers[peer])
                }
            }/*.onAppear {
                nearbyConnections.findPlayers()
            }*/
        }
        .frame(width: 400, height: 250)
        .background(Color.black.opacity(0.78))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.12), radius: 4, x: 2, y: 2)
        .padding(.leading)
        //.offset(x: 10)
        // VStack
    }
}

struct connectionRowView : View {
    var userID : String
    var body: some View{
        HStack{
            Text(userID)
                .foregroundColor(Color.white)
                .frame(width: 250, alignment: .leading)
                .padding()
            Button(action:{
                print("Invite Player")
            }){
                Text("Invite")
            }
            .frame(width: 50, alignment: .leading)
        }
    }
}

struct GameMenuView_Previews: PreviewProvider {
    static var previews: some View {
        GameMenuView(isPresented: .constant(true))
            .environmentObject(P2PSession())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

