//
//  SavedWordUsecases.swift
//  Temorize
//
//  Created by ardalan on 2/15/23.
//

import Foundation

protocol WordPersistingUsecases {
    func save(word: RemmeberedWord) throws
    func delete(word: String) throws
    func retriveAll() throws -> [RemmeberedWord] 
}
