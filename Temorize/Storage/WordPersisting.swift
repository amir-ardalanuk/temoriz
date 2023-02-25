//
//  WordPersisting.swift
//  Temorize
//
//  Created by ardalan on 2/15/23.
//

import Foundation
import Combine

protocol WordPersisting: WordPersistingUsecases { }

final class WordPersistance: WordPersisting {
    let databseManager: DatabaseManagerProtocol
    
    init(databseManager: DatabaseManagerProtocol) {
        self.databseManager = databseManager
    }
    func save(word: RemmeberedWord) throws {
        try databseManager.add(object: RemmeberWordObject(word: word), update: true)
    }
    
    func delete(word: String) throws {
        guard let word = try databseManager.get(type: RemmeberWordObject.self, by: word) else { return }
        try databseManager.remove(object: word)
    }
    
    func retriveAll() throws -> [RemmeberedWord] {
        try databseManager.get(type: RemmeberWordObject.self, filter: nil).map {
            $0.converToRemmeberWord
        }
    }
    
    func publisher() throws -> AnyPublisher<[RemmeberedWord], Error> {
        let result = try databseManager.get(type: RemmeberWordObject.self, filter: nil)
        return result.collectionPublisher.map {
            $0.map {
                $0.converToRemmeberWord
            }
        }.eraseToAnyPublisher()
    }
    
    func retrive(word: String) -> RemmeberedWord? {
        guard let word = try? databseManager.get(type: RemmeberWordObject.self, by: word) else { return nil }
        return word.converToRemmeberWord
    }
}
