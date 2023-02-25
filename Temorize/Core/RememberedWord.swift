//
//  RememberedWord.swift
//  Temorize
//
//  Created by ardalan on 2/15/23.
//

import Foundation

struct RemmeberedWord: Hashable {
    let word: String
    let date: Date
    let translate: TranslateList?
    let definition: DefinitionList?
}
