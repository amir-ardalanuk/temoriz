//
//  Definition.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation

typealias DefinitionList = [Definition]

struct Definition: Hashable {
    let definition: String
    let partOfSpeech: String
    let synonyms: [String]?
    let typeOf: [String]?
    let hasTypes: [String]?
    let examples: [String]?
    let hasInstances: [String]?
    let memberOf: [String]?
    let instanceOf: [String]?
    let derivation: [String]?
}
