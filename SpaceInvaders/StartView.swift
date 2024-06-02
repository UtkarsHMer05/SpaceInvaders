//
//  StartView.swift
//  SpaceInvaders
//
//  Created by utkarsh khajuria on 30/01/24.
//

import SwiftUI
import SpriteKit


var shipChoice = UserDefaults.standard

struct StartView: View {
    var body: some View {
        NavigationView{
            ZStack{
                VStack{
                    Spacer()
                    
                    Text("Space Shooter")
                        .font(.custom("Chalkduster", size: 45))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Spacer()
                    NavigationLink{
                        ContentView().navigationBarBackButtonHidden(true).navigationBarBackButtonHidden(true)
                    }
                label:{
                    Text("START GAME")
                        .font(.custom("Chalkduster",size: 30))
                        .foregroundColor(.red)
                }
                    Spacer()
                    HStack{
                        Button{
                            makePlayerChoice()
                        }label: {
                            Text("Ship 1")
                                .foregroundColor(.red)
                                .font(.custom("Consolas",size: 25))
                        }
                        .padding()
                        Button{
                             makePlayerChoice2()
                            
                        }label: {
                            Text("Ship 2")
                                .foregroundColor(.red)
                                .font(.custom("Consolas",size: 25))
                        }
                        .padding()
                        Button{
                            makePlayerChoice3()
                        }label: {
                            Text("Ship 3")
                                .foregroundColor(.red)
                                .font(.custom("Consolas",size: 25))
                        }
                       
                        .padding()
                       
                        
                    }
                    Spacer()
                }
            }
            .frame(width: 500,height: 1000,alignment: .center)
            .background(Image("Background-2"))
            .ignoresSafeArea()
        }
        
    }
    func makePlayerChoice(){
        shipChoice.set(1, forKey: "playerChoice")
        
    } 
    func makePlayerChoice2(){
        shipChoice.set(2 , forKey: "playerChoice")
    }
    func makePlayerChoice3(){
        shipChoice.set(3, forKey: "playerChoice")
    }
    
}

#Preview {
    StartView()
}
