//
//  HomeScreenViewModel.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation
import Combine
import SwiftUI

protocol HomeModule: BaseFeatureModule {
    associatedtype Configuration = Home.Configuration
}
enum Home {
    case create
    
    struct Configuration {
        let definitionUsecase: WordDefinitionUsecases
        let translateUsecase: TranslateUsecase
        let wordPersistingUsecases: WordPersistingUsecases
    }
    
    struct State: StateProtocol {
        var query: String?
        var translate: Loadable<TranslateList>
        var definition: Loadable<DefinitionList>
        var isBookmarked: Bool
        var hasBookmarkButton: Bool { translate.value != nil }
    }
    
    enum Destination {
        
    }
    
    enum Action {
        case query(String)
        case toggle
    }
}
extension Home: HomeModule {
    @MainActor func build(configuration: Configuration) -> some View {
        HomeView(
            viewModel: HomeViewModel(
                definitionUsecase: configuration.definitionUsecase,
                translateUsecase: configuration.translateUsecase,
                wordPersistingUsecases: configuration.wordPersistingUsecases)
        )
    }
}

@MainActor
final class HomeViewModel: StatefulViewModel {
    typealias Destination = Home.Destination
    typealias State = Home.State
    typealias Action = Home.Action
    
    let stateSubject: CurrentValueSubject<Home.State, Never>
    let destinationSubject: PassthroughSubject<Home.Destination, Never> = .init()
    private let definitionUsecase: WordDefinitionUsecases
    private let translateUsecase: TranslateUsecase
    private var currentTask: Task<Void, Error>?
    private var wordPersistingUsecases: WordPersistingUsecases
    private var translateQuery = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    init(definitionUsecase: WordDefinitionUsecases,
         translateUsecase: TranslateUsecase,
         wordPersistingUsecases: WordPersistingUsecases
    ) {
        self.stateSubject = .init(.init(translate: .notRequested, definition: .notRequested, isBookmarked: false))
        self.definitionUsecase = definitionUsecase
        self.translateUsecase = translateUsecase
        self.wordPersistingUsecases = wordPersistingUsecases
        translateQuery.debounce(for: 1.0, scheduler: DispatchQueue.main).filter { !$0.isEmpty }.removeDuplicates().sink { [weak self] value in
            self?.translateQuery(query: value)
        }.store(in: &cancellables)
    }
    
    func handle(action: Home.Action) {
        switch action {
        case let .query(value):
            stateSubject.value.update {
                $0.query = value
            }
            translateQuery.send(value)
        case .toggle:
            toggle()
        }
    }
    
    private func toggle() {
        do {
            guard let word = state.query, let translate = state.translate.value else { return }
            if let _ = wordPersistingUsecases.retrive(word: word) {
                try wordPersistingUsecases.delete(word: word)
                stateSubject.value.update {
                    $0.isBookmarked = false
                }
            } else {
                let definition = state.definition.value
                try wordPersistingUsecases.save(word: .init(word: word, date: .init(), translate: translate, definition: definition))
                stateSubject.value.update {
                    $0.isBookmarked = true
                }
            }
        } catch {
            print(error)
        }
    }
    
    private func translateQuery(query: String) {
        stateSubject.value.update { $0.translate = .isLoading(last: nil)}
        currentTask?.cancel()
        currentTask = Task {
            do {
                let isWord = query.components(separatedBy: " ").count == 1
                
                async let definitionQuery = isWord ? try definitionUsecase.definition(of: query): nil
                async let translateQuery = try translateUsecase.translate(word: query, from: "en", to: "fa")
                let (response, definitionResponse) = try await (translateQuery, definitionQuery)
                stateSubject.value.update {
                    $0.translate = .loaded(response)
                    $0.isBookmarked = wordPersistingUsecases.retrive(word: query) != nil
                    if let definitionResponse {
                        $0.definition = .loaded(definitionResponse)
                    }
                }
            } catch {
                stateSubject.value.update { $0.translate = .failed(error)}
            }
        }
    }
}
