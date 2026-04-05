//
//  ContentView.swift
//  tapAndScoreGolf Watch App
//
//  Created by Yo Sato on 2026/04/05.
//

import SwiftUI

struct ContentView: View {
    @State var holeNum=1
    @State var shotCnt=0
    @State var lastHitAt=2
    @State var scoresFst9:[Int]=[]
    @State var scoresLst9:[Int]=[]
    var body: some View {
        VStack(alignment: .leading) {
            Image("tapAndScoreBanner")
                .imageScale(.small)
                .foregroundStyle(.tint)
                      HStack(alignment:.top){
                VStack{
                    Text("Hole");Text("\(holeNum)").font(.title3).padding(.top,12)}
                VStack{
                    Text("Shots");Button(action:{shotCnt+=1},label:{Text("\(shotCnt)").font(.title3)})}
                          VStack{Text("Last entered").font(.system(size:10)).padding(.trailing, -5).padding(.top,2);Text("\(lastHitAt)m").font(.footnote).padding(.top,6);Text("ago").font(.caption2)}
            }.padding(.vertical).padding(.horizontal,-5)
            HStack{Spacer()
                Button(action:{
                    guard holeNum<=18 else {return}
                    if(scoresFst9.count<9){
                        scoresFst9.append(shotCnt)}
                    else if(scoresLst9.count<9){
                        scoresLst9.append(shotCnt)}
                    if(holeNum != 18){
                        holeNum+=1}

                    shotCnt=0
                },label:{Text("Next hole").font(.system(size:14)).foregroundStyle(Color.yellow)}).padding(.bottom).buttonStyle(.plain).disabled(shotCnt==0)
            }
            VStack{
                HStack{
                    ForEach(scoresFst9,id:\.self){score in
                        Text("\(score)")
                    }
                    Spacer()
                    if(!scoresFst9.isEmpty){Text(" \(scoresFst9.reduce(0,+))")}
                }
                HStack{
                    ForEach(scoresLst9,id:\.self){score in
                        Text("\(score)")
                    }
                    Spacer()
                    if(!scoresLst9.isEmpty){Text(" \(scoresLst9.reduce(0,+))")}
                }
            }.padding(.bottom,10).padding(.leading,10)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
