//
//  TranslateView.swift
//  Temorize
//
//  Created by ardalan on 2/27/23.
//

import SwiftUI

struct TranslateView: View {
    @State private var tabSelected = 0
    let translateList: [Translate]?
    let definition: DefinitionList?
    
    var body: some View {
        VStack {
            Picker("What is your favorite color?", selection: $tabSelected) {
                Text("Translate").tag(0)
                Text("Defination").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            if tabSelected == 0 {
                VStack {
                    if let values = translateList {
                        translateView(values: values)
                            .padding(16)
                            .background(.blue.opacity(0.5))
                            .cornerRadius(8.0)
                            .padding()
                    }
                }
            }
            
            if tabSelected == 1 {
                VStack {
                    if let values = definition {
                        definationView(values: values)
                    } else {
                        Text("No Definition")
                    }
                }
            }
            
            Spacer()
        }
    }
    
    private func translateView(values: [Translate]) -> some View {
        VStack(alignment: .leading) {
            ForEach(values, id: \.self) { value in
                HStack {
                    Spacer()
                    Text(value.text)
                        .font(.headline)
                    Circle().fill(Color.black).frame(width: 8, height: 8)
                }
            }
        }
    }

    private func definationView(values: DefinitionList) -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(values, id: \.self) { definition in
                    VStack(alignment: .leading) {
                        Text(definition.partOfSpeech)
                            .font(.title2)
                        Divider()
                        HStack {
                            Circle().fill(Color.black).frame(width: 8, height: 8)
                            Text(definition.definition)
                                .font(.headline)
                            Spacer()
                        }
                        Spacer().frame(height: 24)
                        Text("Examples")
                            .font(.title2)
                        Divider()
                        ForEach(definition.examples ?? [], id: \.self) { example in
                            VStack(alignment: .leading) {
                                HStack(alignment: .center) {
                                    Circle().fill(Color.black).frame(width: 8, height: 8)
                                    Text(example)
                                        .font(.headline)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(.blue.opacity(0.5))
                    .cornerRadius(8.0)
                    .padding()
                }
            }
        }
    }
}

struct TranslateView_Previews: PreviewProvider {
    static var previews: some View {
        TranslateView(translateList: [.init(src: "test src", text: "text")],
                      definition: [.init(definition: "def", partOfSpeech: "partof", synonyms: ["syno"], typeOf: [], hasTypes: [], examples: ["1", "2"], hasInstances: [], memberOf: [], instanceOf: [], derivation: [])])
    }
}
