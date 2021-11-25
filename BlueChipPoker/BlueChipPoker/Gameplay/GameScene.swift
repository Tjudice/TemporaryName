//
//  GameScene.swift
//  BlueChipPoker
//
//  Created by Ameer Mubarez on 10/30/21.
//

import SwiftUI

struct GameSceneView: View {
    @Binding var startGame: Bool
    var body: some View {
        ZStack{
            Image("menuBackground")
                .resizable()
                .scaledToFit()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        } // ZStack
    } // body
} // GameSceneView

struct GameSceneView_Previews: PreviewProvider {
    static var previews: some View {
        GameSceneView(startGame: .constant(true))
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

