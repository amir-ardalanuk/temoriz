//
//  BaseViewModel.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation
import Combine

protocol StateProtocol {
    func updated(_ handler: (inout Self) -> Void) -> Self
}

extension StateProtocol {
    func updated(_ handler: (inout Self) -> Void) -> Self {
        var result = self
        handler(&result)
        return result
    }
    
    mutating func update(_ handler: (inout Self) -> Void) {
        var result = self
        handler(&result)
        self = result
    }
    
    mutating func update<Value>(_ keyPath: WritableKeyPath<Self,Value>, to value: Value) {
        self[keyPath: keyPath] = value
    }
}

protocol ViewModel<State, Action>: AnyObject {
    associatedtype State: StateProtocol
    associatedtype Action
    var state: State { get }
    var statePublisher: AnyPublisher<State, Never> { get }
    func handle(action: Action)
}

protocol StatefulViewModel<State, Action, Destination>: ViewModel {
    
    var stateSubject: CurrentValueSubject<State, Never> { get }
   
    associatedtype Destination
    var destinationSubject: PassthroughSubject<Destination, Never> { get }
}

extension StatefulViewModel {
    var state: State { stateSubject.value }
    var statePublisher: AnyPublisher<State, Never> { stateSubject.eraseToAnyPublisher() }
    var destinationPublisher: AnyPublisher<Destination, Never> { destinationSubject.eraseToAnyPublisher() }
}
