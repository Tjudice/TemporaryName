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
    @EnvironmentObject var nearbyConnections: P2PSession
    var body: some View {
        ZStack{
            Image("menuBackground")
                .resizable()
                .scaledToFit()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 0){
                navBarView(isPresented: $isPresented)
                HStack{
                    Text("Establishing Player as Host and searching for connections nearby")
                        .foregroundColor(Color.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            HStack(spacing: 40){
                connectionsNearbyView()
                    .environmentObject(self.nearbyConnections)
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

// Navigation Bar Element
struct navBarView : View {
    @Binding var isPresented: Bool
    var body: some View{
        HStack{
            Button(action:{
                isPresented.toggle()
            }){
                Image(systemName: "chevron.backward.circle.fill")
                    .foregroundColor(Color("MenuButtonColors"))
            }
            
            Spacer()
            Text("Welcome Username!")
                .foregroundColor(Color.white)
                .frame(alignment: .center)
            Spacer()
            Text("Balance $100")
                .foregroundColor(Color.white)
                .frame(alignment: .trailing)
        } .frame(maxWidth: .infinity, maxHeight: 40)
            .background(Color.black)
    }
}

// Connections Table Element
struct connectionsNearbyView : View{
    @EnvironmentObject var nearbyConnections : P2PSession
    var body: some View{
        VStack{
            // Create list to load nearby connections
            Text("Connections Nearby: ")
                .padding()
                .foregroundColor(Color.white)
            ScrollView(){
                let peers = nearbyConnections.playersFound
                ForEach(peers.indices, id: \.self) { peer in
                    connectionRowView(userID : peers[peer].info["name"]!)
                }
            }.onAppear {
                nearbyConnections.findPlayers()
             }
        }
        .frame(width: 400, height: 300)
        .background(Color.black.opacity(0.78))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.12), radius: 4, x: 2, y: 2)
        .offset(x: -100, y: 40)
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

/*struct GameMenuView_Previews: PreviewProvider {
    static var nearbyConnectionsPrvw : P2PSession
    static var previews: some View {
        GameMenuView(isPresented: .constant(true), nearbyConnections: nearbyConnectionsPrvw)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}*/

