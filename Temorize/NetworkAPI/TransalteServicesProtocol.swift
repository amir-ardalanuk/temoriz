//
//  TransalteServicesProtocol.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation

protocol TranslateServicesProtocol: TranslateUsecase, WordDefinitionUsecases { }
final class TranslateServices: TranslateServicesProtocol {
    let requestManager: RequestManagerProtocol
    
    init(requestManager: RequestManagerProtocol) {
        self.requestManager = requestManager
    }
}

final class PresentationTranslateServices: TranslateUsecase, WordDefinitionUsecases {
    var translateHandler: (() -> TranslateList)?
    func translate(word: String, from: String, to: String) async throws -> TranslateList {
        if let translateHandler {
            return translateHandler()
        } else {
            throw NetworkError.invalidURL
        }
    }
    var definitionHandler: (() -> DefinitionList)?
    func definition(of word: String) async throws -> DefinitionList {
        if let definitionHandler {
            return definitionHandler()
        } else {
            throw NetworkError.invalidURL
        }
    }
    
    
}

extension TranslateServices {
    func translate(word: String, from: String, to: String) async throws -> TranslateList {
        let response: GoogleTranslateResponse = try await requestManager.perform(GoogleAPIRequest.translate(from: from, to: to, sentence: word))
        let translateList = response.alternativeTranslations?.first?.alternative?.compactMap {
            Translate(src: word, text: $0.wordPostproc ?? "")
        } ?? []
        let examples = response.examples?.example?.compactMap { $0.text } ?? []
        
        return .init(examples: examples, translates: translateList)
    }
}

extension TranslateServices {
    func definition(of word: String) async throws -> DefinitionList {
        let response: WordResponse = try await requestManager.perform(WordsApiRequest.word(word))
        
        
        return response.results.map {
            Definition.init(definition: $0.definition ?? "-", partOfSpeech: $0.partOfSpeech ?? "-", synonyms: $0.synonyms, typeOf: $0.typeOf, hasTypes: $0.hasTypes, examples: $0.examples, hasInstances: $0.hasInstances, memberOf: $0.memberOf, instanceOf: $0.instanceOf, derivation: $0.derivation)
        }
    }
    
    
}
