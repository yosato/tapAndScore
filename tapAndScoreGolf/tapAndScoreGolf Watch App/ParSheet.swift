//
//  ParSheet.swift
//  tapAndScoreGolf Watch App
//
//  Created by Yo Sato on 2026/04/07.
//

import SwiftUI

struct ParSheet: View {
        @Binding var par: Int?
    @Environment(\.dismiss) var dismiss

    var body: some View {VStack{
        HStack(spacing: 0) {
            segment(3)
            segment(4)
            segment(5)
        }.background(Color.gray.opacity(0.2)).clipShape(RoundedRectangle(cornerRadius: 8)).padding()
        
        Button(action:{dismiss()},label:{Text("Confirm")}).buttonStyle(.plain).padding()
        
    }
    }

        @ViewBuilder
        private func segment(_ value: Int) -> some View {
            Button(action: {
                par = value
            }) {
                Text("\(value)")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(par == value ? Color.yellow : Color.clear)
                    .foregroundStyle(par == value ? Color.black : Color.white)
            }
            .buttonStyle(.plain)
        }
    }

#Preview {
    ParSheet(par:.constant(4))
}
