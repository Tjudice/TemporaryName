//
//  MenuView.swift
//  BlueChipPoker
//
//  Created by Ameer Mubarez on 10/31/21.
//

import SwiftUI

struct MenuView: View {
    @State private var isPresenting = false
    @EnvironmentObject var nearbyConnections : P2PSession
    var body: some View {
        ZStack{
            Image("menuBackground")
                .resizable()
                .scaledToFit()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            HStack{
                VStack(spacing: 40){
                    Button("Create Game", action:{
                        print("Game")
                        isPresenting.toggle()
                    }).buttonStyle(MenuButtonStyle())
                        .sheet(isPresented: $isPresenting){
                            GameMenuView(isPresented: $isPresenting)
                                .environmentObject(self.nearbyConnections)
                        }
                        .contentShape(Rectangle())
                    Button("Add Balance", action:{
                        print("Balance")
                        isPresenting.toggle()
                    }).buttonStyle(MenuButtonStyle())
                        .sheet(isPresented: $isPresenting){
                            BalanceMenuView(isPresented: $isPresenting)
                        }
                        .contentShape(Rectangle())
                    Button("User Settings", action:{
                        isPresenting.toggle()
                        print("User")
                    }).buttonStyle(MenuButtonStyle())
                        /*.sheet(isPresented: $isPresenting){
                            GameMenuView(isPresented: $isPresenting)
                        }*/
                }
                .offset(x: 50)
                List{
                    Text("Join Nearby Tables")
                        .background(Color.black)
                }
                .frame(width: 220, height: 300, alignment: .leading)
                .offset(x: 70, y: 0)
                .padding(.trailing, -100)
            }
        }
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



/* Preview function used for development
struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
            .previewInterfaceOrientation(.landscapeRight)
    }
}
*/
