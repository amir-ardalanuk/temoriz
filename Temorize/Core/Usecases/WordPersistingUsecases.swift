//
//  SavedWordUsecases.swift
//  Temorize
//
//  Created by ardalan on 2/15/23.
//

import Foundation
import Combine

protocol WordPersistingUsecases {
    func save(word: RemmeberedWord) throws
    func retrive(word: String) -> RemmeberedWord?
    func delete(word: String) throws
    func retriveAll() throws -> [RemmeberedWord]
    func publisher() throws -> AnyPublisher<[RemmeberedWord], Error>
}
