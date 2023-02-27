//
//  RemmemberRowView.swift
//  Temorize
//
//  Created by ardalan on 2/26/23.
//

import Foundation
import SwiftUI

struct RemmemberRowListView: View {
    let word: RemmeberedWord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0.8) {
                HStack {
                    Circle().fill(Color.orange).frame(width: 16, height: 16)
                    
                    Text(word.word)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Circle().fill(Color.clear).frame(width: 16, height: 16)
                    Text(word.translate?.translates.first?.text ?? "-").padding(.vertical, 8.0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .padding(.horizontal)
            Spacer()
        }
    }
}

struct RemmemberRowListView_Preview: PreviewProvider {
    static var previews: some View {
        return RemmemberRowListView(word: .init(word: "word", date: .init(), translate: .init(examples: ["test"], translates: [.init(src: "src", text: "text")]), definition: [.init(definition: "definition", partOfSpeech: "part of", synonyms: [], typeOf: [], hasTypes: [], examples: [], hasInstances: [], memberOf: [], instanceOf: [], derivation: [])]))
    }
}
