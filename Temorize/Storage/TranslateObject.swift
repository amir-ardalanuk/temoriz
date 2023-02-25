//
//  TranslateObject.swift
//  Temorize
//
//  Created by ardalan on 2/15/23.
//

import Foundation
import RealmSwift

final class RemmeberWordObject: Object {
    @Persisted var date: Date
    @Persisted var translate: TranslateListObject?
    @Persisted var definition: List<DefinitionObject>
    @Persisted var word: String
    
    override class func primaryKey() -> String? { "word" }
    
    convenience init(word: RemmeberedWord) {
        self.init()
        self.date = word.date
        self.translate = word.translate.flatMap { .init(transactionList: $0) }
        self.definition = .init()
        word.definition?.forEach {
            let object = DefinitionObject(definition: $0)
            definition.append(object)
        }
        self.word = word.word
    }
    
    var converToRemmeberWord: RemmeberedWord {
        .init(word: word, date: date, translate: translate?.converToTranslateList, definition: definition.map { $0.converToDefinition })
    }
}

final class TranslateListObject: Object {
    @Persisted var examples: String
    @Persisted var translates: List<TranslateObject>
    
    convenience init(transactionList: TranslateList) {
        self.init()
        self.examples = transactionList.examples.joined(separator: "---")
        self.translates = .init()
        transactionList.translates.forEach {
            let item = TranslateObject.init(translate: $0)
            translates.append(item)
        }
    }
    
    var converToTranslateList: TranslateList {
        TranslateList.init(examples: self.examples.components(separatedBy: "---"), translates: translates.map { $0.converToTranslate })
    }
}
final class TranslateObject: Object {
    @Persisted var src: String
    @Persisted var text: String
    
    convenience init(translate: Translate) {
        self.init()
        self.src = translate.src
        self.text = translate.text
    }
    
    var converToTranslate: Translate {
        .init(src: src, text: text)
    }
}

final class DefinitionObject: Object {
    private static let seprator = "---"
    @Persisted var definition: String
    @Persisted var partOfSpeech: String
    @Persisted var synonyms: String?
    @Persisted var typeOf: String?
    @Persisted var hasTypes: String?
    @Persisted var examples: String?
    @Persisted var hasInstances: String?
    @Persisted var memberOf: String?
    @Persisted var instanceOf: String?
    @Persisted var derivation: String?
    
    convenience init(definition: Definition) {
        self.init()
        self.definition = definition.definition
        self.partOfSpeech = definition.partOfSpeech
        self.synonyms = definition.synonyms?.joined(separator: Self.seprator)
        self.typeOf = definition.typeOf?.joined(separator: Self.seprator)
        self.hasTypes = definition.hasTypes?.joined(separator: Self.seprator)
        self.examples = definition.examples?.joined(separator: Self.seprator)
        self.hasInstances = definition.hasInstances?.joined(separator: Self.seprator)
        self.memberOf = definition.memberOf?.joined(separator: Self.seprator)
        self.instanceOf = definition.instanceOf?.joined(separator: Self.seprator)
        self.derivation = definition.derivation?.joined(separator: Self.seprator)
    }
    
    var converToDefinition: Definition {
        .init(definition: definition, partOfSpeech: partOfSpeech, synonyms: synonyms?.components(separatedBy: Self.seprator), typeOf: typeOf?.components(separatedBy: Self.seprator), hasTypes: hasTypes?.components(separatedBy: Self.seprator), examples: examples?.components(separatedBy: Self.seprator), hasInstances: hasInstances?.components(separatedBy: Self.seprator), memberOf: memberOf?.components(separatedBy: Self.seprator), instanceOf: instanceOf?.components(separatedBy: Self.seprator), derivation: derivation?.components(separatedBy: Self.seprator))
    }
}
