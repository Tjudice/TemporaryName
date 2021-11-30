//
//  GameScene.swift
//  BlueChipPoker
//
//  Created by Ameer Mubarez on 10/30/21.
//

import SwiftUI

struct GameView: View {
    @Binding var isPresented: Bool
    @ObservedObject var gameViewModel = GameViewModel(segueVar: 1)
    var body: some View {
        ZStack{
            Image("gameBackground")
                .resizable()
                .frame(maxWidth: UIScreen.main.bounds.size.width, maxHeight: .infinity)
            //.scaledToFit()
                .ignoresSafeArea(.all)
            VStack{
                HStack{
                    flopCards(gameViewModel: gameViewModel)
                    //playerCards(pCard1: gameViewModel.$p2card1, pCard2: gameViewModel.$p2card2)
                }.padding(.top)
                Spacer()
                HStack{
                    //playerCards()
                    //playerCards()
                    
                }
                Spacer()
                HStack{
                    playerCards(pCard1: gameViewModel.p3card1, pCard2: gameViewModel.p3card2, playerName: "Player1")
                    Spacer()
                    playerCards(pCard1: gameViewModel.p1card1, pCard2: gameViewModel.p1card2, playerName: "Player2")
                    Spacer()
                    playerCards(pCard1: gameViewModel.p2card1, pCard2: gameViewModel.p2card2, playerName: "Player3")
                }.padding(.bottom, 50)
                bottomBar(pot: gameViewModel.potLabel, gameViewModel: gameViewModel)
                
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center) // VStack
        } // ZStack
    } // body
} // GameSceneView

struct flopCards : View {
    @ObservedObject var gameViewModel : GameViewModel
    var body: some View{
        HStack(spacing: 40){
            card(img: gameViewModel.flop1, width: 80, height: 102)
            card(img: gameViewModel.flop2, width: 80, height: 102)
            card(img: gameViewModel.flop3, width: 80, height: 102)
            card(img: gameViewModel.flop4, width: 80, height: 102)
            card(img: gameViewModel.flop5, width: 80, height: 102)
        }
        .frame(alignment: .center)
    }
}

struct playerCards : View {
    var pCard1 : String
    var pCard2 : String
    var playerName : String
    var body : some View{
        HStack{
            card(img: pCard1, width: 60, height: 82)
            card(img: pCard2, width: 60, height: 82)
                .offset(x: -30, y: -50)
        }
        HStack{
            Text(playerName)
        }.padding()
            .offset(x: -30)
            .foregroundColor(Color.white)
    }
}

struct card : View{
    var img : String
    var width : CGFloat
    var height : CGFloat
    var body : some View{
        let parsed = img.replacingOccurrences(of: ".png", with: "")
        Image(parsed)
            .resizable()
            .frame(width: width, height: height)
    }
}

struct bottomBar : View{
    var pot : String
    @ObservedObject var gameViewModel : GameViewModel
    @State private var showRaiseAlert : Bool = false
    var body: some View{
        HStack{
            Text(pot)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.white)
            button(label: "Fold", function: {gameViewModel.callFold()}, hidden: gameViewModel.foldButtonHidden)
            button(label: "Raise", function: {gameViewModel.callRaise()}, hidden: gameViewModel.raiseButtonHidden)
            button(label: "Check/Call", function: {gameViewModel.callCheck()}, hidden: gameViewModel.checkButtonHidden)
            button(label: "Bet", function: {gameViewModel.callBet()}, hidden: gameViewModel.betButtonHidden)
            
        }.frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct button : View {
    var label : String
    var function: () -> Void
    var hidden : Bool
    var body : some View{
        if !hidden{
            Button(action:{
                print(label)
                self.function()
                //isPresentingGame.toggle()
            }) {
                Text(label)
                    .frame(width: 100, height: 25)
                    //.padding()
                    .background(Color("MenuButtonColors"))
                    .foregroundColor(Color.white)
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.12), radius: 4, x: 2, y: 2)
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    //static let game : GameViewModel = GameViewModel()
    static var previews: some View {
        GameView(isPresented: .constant(true))
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

