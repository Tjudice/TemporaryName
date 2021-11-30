//
//  BalanceMenuView.swift
//  BlueChipPoker
//
//  Created by Ameer Mubarez and Trevor Judice on 11/24/21.
//

import SwiftUI

struct BalanceMenuView : View{
    @Binding var isPresented: Bool
    @EnvironmentObject var userInfo : UserInfo
    @State private var balance = ""
    @State private var new_username = ""

    var body: some View{
        HStack{
            VStack{
                Text("Enter balance to add:")
                TextField("0", text: $balance)
                    .keyboardType(.numberPad)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .gray, radius: 10)
                    .frame(width: 200)
                    .padding()
                Button("Add Balance"){
                    userInfo.balance += Int(balance) ?? 0
                    balance = ""

                }
                .padding()

                Text("Enter New Username:")
                TextField("Enter Username...", text: $new_username)
                    .keyboardType(.default)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .gray, radius: 10)
                    .frame(width: 200)
                    .padding()
                Button("Change Username"){
                    if (new_username != ""){
                        userInfo.username = new_username
                    }
                    new_username = ""
                }
                .padding()

            } .frame(width: 400, height: 400)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            VStack{
                Text("Username: " + userInfo.username)
                Text("Balance: " + String(userInfo.balance))
                    .padding()
                Button("Back to menu"){
                    balance = ""
                    new_username = ""
                    isPresented.toggle()
                }
            }

        }
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
