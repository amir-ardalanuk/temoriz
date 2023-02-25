//
//  Translate.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation

struct TranslateList: Hashable {
    let examples: [String]
    let translates: [Translate]
}

struct Translate: Hashable {
    let src: String
    let text: String
}
