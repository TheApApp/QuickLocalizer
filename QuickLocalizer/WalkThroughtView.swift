//
//  WalkThroughtView.swift
//  QuickLocalizer
//
//  Created by Michael Rowe1 on 1/8/25.
//

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
                        .foregroundColor(.primary)
                        .fontWeight(.bold)
                    Spacer()
                }

                HStack(){
                    VStack {
                        Image(img)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(30)
                            .frame(width: 150, height: 150)
                            .padding()
                        Spacer()
                    }
                    VStack {
                        HStack {
                            Text(title)
                                .fontWeight(.semibold)
                                .font(.title)
                            Spacer()
                        }
                        
                        Text(description)
                            .padding(.top, 5.0)
                            .padding(.bottom, 10.0)
                        
                        Spacer()
                    }
                }
                
                Spacer(minLength: 0)
                
            }
            .padding()
            .overlay(
                HStack{
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
                                .font(.system(size: 20.0, weight: .semibold))
                                .frame(width: 30, height: 30)
                                .background(.secondary)
                                .clipShape(Circle())
                                .padding(5)
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
    WalkThroughtView(title: "Easily translate your strings", description: """
    Quick Localizer utilize's Apple's own lanugage translations dictionaries to quickly, and easily, translate your Xcode's projects strings to any supported language.
    
    The dictionaries can be downloaded via:
    System Settings...Languages and Regions...Translation Languages
    
    Or if you pick a language not already installed, it will download them on demand.
    """
                     , bgColor: "AccentColor", img: "Welcome_one")
}
