//
//  DependecyLocator.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation

protocol Dependencies {
    var translateUsecase: TranslateUsecase { get }
    var wordUsecases: WordDefinitionUsecases { get }
    var wordPersisting: WordPersistingUsecases { get }
}

final class DependencyLocator: Dependencies {
   
    
    lazy var databaseManager: DatabaseManagerProtocol = {
        DatabaseManager()
    }()
    
    lazy var requestManagerProtocol: RequestManagerProtocol = {
        RequestManager()
    }()
    lazy var translateServices: TranslateServicesProtocol = {
       TranslateServices(requestManager: requestManagerProtocol)
    }()
    
    var translateUsecase: TranslateUsecase {
        translateServices
    }
    
    var wordUsecases: WordDefinitionUsecases {
        translateServices
    }
    
    lazy var wordPersisting: WordPersistingUsecases = {
        WordPersistance(databseManager: databaseManager)
    }()
    
}
