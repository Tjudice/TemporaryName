//
//  BalanceMenuView.swift
//  BlueChipPoker
//
//  Created by Ameer Mubarez on 11/24/21.
//

import SwiftUI

struct BalanceMenuView : View{
    @Binding var isPresented: Bool
    @State private var balance = ""
    @EnvironmentObject var userInfo : UserInfo

    var body: some View{
        VStack{
            Text("Enter your new balance:")
            TextField("", text: $balance)
                .keyboardType(.numberPad)
                .padding(10)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .gray, radius: 10)
                .frame(width: 200)
                .padding()
            HStack{
                Button("Submit"){
                    userInfo.balance += Int(balance) ?? 0
                    //print(userBalance)
                    isPresented.toggle()
                }
                .padding()
                Button("Cancel"){
                    balance = "0"
                    isPresented.toggle()
                }
                .padding()
            }
        } .frame(width: 300, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
} // body

/* Preview function used for development
struct BalanceMenuView_Previews: PreviewProvider {
    @ObservedObject var userBalance = UserInfo()
    static var previews: some View {
        BalanceMenuView(isPresented: .constant(true), userBalance: userBalance)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
*/
