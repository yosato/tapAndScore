//
//  ContentView.swift
//  tapAndScoreGolf Watch App
//
//  Created by Yo Sato on 2026/04/05.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State var holeNum=1
    @State var shotCnt=0
    @State var lastHitAt=2
    @State var parsScores:[(par:Int,score:Int)]=[]
    var pars:[Int]{parsScores.map{$0.0}}
        var scores:[Int]{parsScores.map{$0.1}}
    var currentOverPar:Int {parsScores.map{$1-$0}.reduce(0,+)}
    var front9:[(par:Int,score:Int)] {Array(parsScores.prefix(9))}
    var back9:[(par:Int,score:Int)] {Array(parsScores.dropFirst(9).prefix(9))}

    var front9Total:Int {front9.map(\.score).reduce(0, +)}
    var overallTotal:Int { parsScores.map(\.score).reduce(0, +)}
    @State var scoresFst9:[Int]=[]
    @State var scoresLst9:[Int]=[]
    @State var started:Bool=false
    @State var showParSheet:Bool=false
    @State var par:Int?=nil
    @State var lastEntered:Date?=nil
    @State private var undoIsVisible: Bool = false
    @State private var undoController = MomentaryUndoController()
    
    var body: some View {
        
        GeometryReader{geo in
            let scale=geo.size.width/210
            VStack(alignment: .leading) {
                Image("tapAndScoreBanner")
                    //.imageScale(.small)
                    .foregroundStyle(.tint).scaleEffect(1)
                
                HStack(alignment:.top){
                    VStack{
                        Text("Hole");Spacer();Text("\(holeNum)").font(.title3);Spacer();Text("Par \(par==nil ? "-" : "\(par!)")")}
                    VStack{
                        Text("Shots");Button(action:{
                            shotCnt+=1
                            lastEntered=Date()
                            undoController.open(undoAction:{if(shotCnt>=1){shotCnt-=1}})
                            started=true
                        },label:{Text("\(shotCnt)").font(.title3)}).padding(.horizontal).disabled(par==nil)
                        
                    }.padding(.horizontal)
                    
                    VStack{
                        Text("Last\nentered")
                            .font(.system(size:10))
                            .padding(.trailing, -2)
                            .padding(.top,2)
                        
                        TimelineView(.periodic(from: .now, by: 10)) { context in
                            if let lastEntered {
                                Text(format_timeInterval(context.date.timeIntervalSince(lastEntered)))
                                    .font(.footnote)
                                    .padding(.top,6)
                                Text("ago").font(.caption2)
                                
                            }
                        }
                        
                    }
                }
                .padding(.vertical)
                .padding(.horizontal, -5)
                .overlay {
                    if undoIsVisible {
                        Button(action: {
                            undoController.undo{}
                        }, label: {
                            Text("Tap to undo")
                        })
                        .tint(.yellow)
                        .offset(y:35)
                    }
                }
                .opacity(undoIsVisible ? 0.5 : 1.0)
                .onAppear{
                    undoController.onVisibilityChanged = { visible in
                          undoIsVisible = visible
                      }
                }

                Group{
                    if(!started){
                        HStack{
                            Button(action:{
                                showParSheet=true
                            },label:{Text("(Re)Enter par").font(.system(size:14)).foregroundStyle(Color.yellow)}).padding(.bottom).buttonStyle(.plain)
                        }
                        
                    }else{
                        HStack{Spacer()
                            //next button
                            Button(action:{
                                guard holeNum<=18 else {return}
                                parsScores.append((par:par!,score:shotCnt))
                                
                                if(holeNum != 18){holeNum+=1}

                                undoController.open(undoAction: {
                                    if(holeNum != 1){holeNum-=1}
                                    parsScores.removeLast()
                                })

                                shotCnt=0
                                started=false
                                par=nil

                                
                            },label:{Text("Next hole").font(.system(size:14)).foregroundStyle(Color.yellow)}).padding(.bottom).buttonStyle(.plain).disabled(shotCnt==0)
                        }
                    }
                }.sheet(isPresented:$showParSheet){
                    ParSheet(par:$par)
                }

                VStack(spacing: 2) {
                    score_row(
                        pairs: front9,//[(3,20),(4,32),(3,14),(3,14),(3,14),(3,14),(3,14),(3,14),(3,14)],
                        showOverPar: !parsScores.isEmpty && parsScores.count <= 9,
                        trailingTotal: front9.isEmpty ? nil : front9Total
                    )

                    score_row(
                        pairs: back9,
                        showOverPar: parsScores.count > 9,
                        trailingTotal: parsScores.count > 9 ? overallTotal : nil
                    )
                }
//                .padding(.bottom, 10)
                
                .padding(.leading, 10)            }.scaleEffect(scale)
                .padding(.bottom).padding(.top,-15).padding(.trailing,6)

        }
    }
    private func score_row(
        pairs: [(par: Int, score: Int)],
        showOverPar: Bool,
        trailingTotal: Int?
    ) -> some View {
        HStack(alignment: .center) {
            ForEach(Array(pairs.enumerated()), id: \.offset) { _, pair in
                Text("\(pair.score)")
                    .foregroundStyle(par2colour(pair.par, pair.score)).font(.caption2)
            }

            if showOverPar {
                Text(currentOverPar.plusMinus)
                    .padding(.leading, 4).lineLimit(1).fixedSize(horizontal: true, vertical: false)
                    .foregroundStyle(
                        par2colour(0, currentOverPar, baseBrightness: 0.75, maxBoost: 0.6, spread: 8.0)       )
            }

            Spacer()

            if let trailingTotal {
                Text("\(trailingTotal)")
            }
        }.lineLimit(1).minimumScaleFactor(0.4)
    }
    func par2colour(_ par: Int, _ score: Int, baseBrightness: Double = 0.6, maxBoost: Double = 0.4, spread: Double = 3.0) -> Color {

        let diff = score - par
        if diff == 0 { return .primary }

        let intensity = min(Double(abs(diff)) / spread, 1.0)
        let brightness = baseBrightness + maxBoost * intensity

        if diff < 0 {
            return Color(hue: 1.0 / 3.0, saturation: 1.0, brightness: brightness)
        } else {
            return Color(hue: 0.0, saturation: 1.0, brightness: brightness)
        }
    }

    func format_timeInterval(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: interval) ?? ""
    }
    
    func lastEntered2string()->String{
        if let lastEntered
        {
            let timeDelta=Date().timeIntervalSince(lastEntered)
            return format_timeInterval(timeDelta)
            
            
            
        }else{return ""}
        
    }
}
extension Int {
    var plusMinus: String {
        self == 0 ? "±0" : (self > 0 ? "+\(self)" : "\(self)")
    }
}
#Preview {
    ContentView()
}
