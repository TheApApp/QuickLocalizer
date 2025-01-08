//
//  WalkThroughtView.swift
//  QuickLocalizer
//
//  Created by Michael Rowe1 on 1/8/25.
//


//
//  WalkThroughtView.swift
//  Greet Keeper
//
//  Created by Michael Rowe1 on 12/29/24.
//

import SwiftData
import SwiftUI

struct WalkThroughtView: View {
    @AppStorage("walkthrough") var walkthrough = 1
    @AppStorage("totalViews") var totalViews = 1
    
    var title: String
    var description: String
    var bgColor: String
    var img: String
    
    var body: some View {
        ZStack{
            VStack{
                HStack {
                    Text("Welcome!")
                        .accessibilityLabel("Welcome!")
                        .fontWeight(.bold)
                    Spacer()
                    Button(
                        action:{
                            walkthrough = (totalViews + 1)
                        },
                        label: {
                            Text("Skip")
                        }
                    )
                }.padding()
                Spacer()
                VStack(alignment: .leading){
                    Image(img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(30)
                        .padding()
                    
                    Text(title)
                        .fontWeight(.semibold)
                        .font(.title)
                        .padding(.top)
                    
                    Text(description)
                        .padding(.top, 5.0)
                    
                }
                
                Spacer(minLength: 0)
                
            }
            .padding()
            .overlay(
                HStack{
                    
                    if walkthrough == 1 {
                        ContainerRelativeShape()
                            .frame(width: 25, height: 5)
                    } else {
                        ContainerRelativeShape()
                            .foregroundColor(.accentColor.opacity(0.5))
                            .frame(width: 25, height: 5)
                    }
                    Spacer()
                    Button(
                        action:{
                            withAnimation(.easeOut) {
                                if walkthrough <= totalViews || walkthrough == 1 {
                                    walkthrough += 1
                                } else if walkthrough == totalViews {
                                    walkthrough = 1
                                }
                            }
                        },
                        label: {
                            Image(systemName: "chevron.right")
//                                .foregroundColor(Color.white)
                                .font(.system(size: 35.0, weight: .semibold))
                                .frame(width: 55, height: 55)
                                .background(Color("BgNextBtn"))
                                .clipShape(Circle())
                                .padding(17)
                                .overlay(
                                    ZStack{
                                        Circle()
                                            .stroke(Color.accentColor.opacity(0.4), lineWidth: 2)
                                            .padding()
                                    }
                                )
                        }
                    )
                }
                    .padding()
                ,alignment: .bottomTrailing
            )
        }
        
        .background(
            LinearGradient(colors: [
                Color(bgColor),Color("BgNextBtn")]
                           ,startPoint: .top, endPoint: .bottom)
        )
    }
}

#Preview {
    WalkThroughtView(title: "WalkThrough", description: "This will show a lot of information", bgColor: "AccentColor", img:"Welcome_todo")
}
