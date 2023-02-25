//
//  WordResponse.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation

// MARK: - WordResponse
struct WordResponse: Codable {
    let word: String
    let results: [WordResult]
}

// MARK: - Result
struct WordResult: Codable {
    let definition, partOfSpeech: String?
    let synonyms, typeOf, hasTypes, examples: [String]?
    let hasInstances, memberOf, instanceOf, derivation: [String]?
}
