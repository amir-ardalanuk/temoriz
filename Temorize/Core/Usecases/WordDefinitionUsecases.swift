//
//  WordDefinitionUsecases.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation

protocol WordDefinitionUsecases {
    func definition(of word: String) async throws -> DefinitionList
}
