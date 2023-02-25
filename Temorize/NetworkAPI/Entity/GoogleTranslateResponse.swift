//
//  GoogleTranslateResponse.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation

struct GoogleTranslateResponse: Codable {
    let sentences: [GoogleAPISentence]?
    let alternativeTranslations: [GoogleAlternativeTranslation]?
    let examples: GoogleApiExamples?

    enum CodingKeys: String, CodingKey {
        case sentences
        case alternativeTranslations = "alternative_translations"
        case examples
    }
}

struct GoogleAlternativeTranslation: Codable {
    let srcPhrase: String?
    let alternative: [GoogleAPIAlternative]?
    let rawSrcSegment: String?

    enum CodingKeys: String, CodingKey {
        case alternative
        case srcPhrase = "src_phrase"
        case rawSrcSegment = "raw_src_segment"
    }
}

struct GoogleAPIAlternative: Codable {
    let wordPostproc: String?
    enum CodingKeys: String, CodingKey {
        case wordPostproc = "word_postproc"
    }
}

struct GoogleApiExamples: Codable {
    let example: [GoogleApiExample]?
}

struct GoogleApiExample: Codable {
    let text: String
}

struct GoogleAPISentence: Codable {
    let trans: String
}
