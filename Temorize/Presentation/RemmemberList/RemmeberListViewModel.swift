//
//  RemmeberListViewModel.swift
//  Temorize
//
//  Created by ardalan on 2/25/23.
//

import Foundation
import SwiftUI
import Combine

protocol RemmemberListModule: BaseFeatureModule {
    associatedtype Configuration = Home.Configuration
}

enum RemmemberList {
    case create
    
    struct Configuration {
        let wordPersistingUsecases: WordPersistingUsecases
    }
    
    struct State: StateProtocol {
        var list: [RemmeberedWord]
    }
    
    enum Destination {}
    
    enum Action {
        case remove(item: RemmeberedWord)
        case observeToDatabase
    }
}

extension RemmemberList: RemmemberListModule {
    @MainActor func build(configuration: Configuration) -> some View {
        RemmemberListView(
            viewModel: RemmemberListViewModel.init(wordPersistingUsecases: configuration.wordPersistingUsecases)
        )
    }
}

@MainActor
final class RemmemberListViewModel: StatefulViewModel {
    typealias Destination = RemmemberList.Destination
    typealias State = RemmemberList.State
    typealias Action = RemmemberList.Action
    
    let stateSubject: CurrentValueSubject<State, Never>
    let destinationSubject: PassthroughSubject<Destination, Never> = .init()
    private let wordPersistingUsecases: WordPersistingUsecases
    private var currentTask: Task<Void, Error>?
    private var cancellables = Set<AnyCancellable>()
    
    init(wordPersistingUsecases: WordPersistingUsecases) {
        self.stateSubject = .init(.init(list: []))
        self.wordPersistingUsecases = wordPersistingUsecases
    }
    
    func handle(action: Action) {
        switch action {
        case .observeToDatabase:
            observerToDatabase()
        case let .remove(item):
            remove(item: item)
        }
    }
    private func remove(item: RemmeberedWord) {
       try? wordPersistingUsecases.delete(word: item.word)
    }
    private func observerToDatabase() {
        try? wordPersistingUsecases.publisher().sink { error in
            print(error)
        } receiveValue: { [weak self] list in
            self?.stateSubject.value.update { state in
                state.list = list
            }
        }.store(in: &cancellables)
    }
}
