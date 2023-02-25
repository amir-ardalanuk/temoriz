//
//  Loadable.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation
import Combine

protocol LoadableProtocol {
    associatedtype DataType
    associatedtype Failure
    
    var value: DataType? { get }
    var error: Failure? { get }
    var isLoading: Bool { get }
    
}

public enum Loadable<T>: LoadableProtocol {
    
    case notRequested
    case isLoading(last: T?)
    case loaded(T)
    case failed(Error)
    
    public var value: T? {
        switch self {
        case let .loaded(value): return value
        case let .isLoading(last): return last
        default: return nil
        }
    }
    
    public var error: Error? {
        switch self {
        case let .failed(error): return error
        default: return nil
        }
    }
    
    public  var isLoading: Bool {
        switch self {
        case  .isLoading: return true
        default: return false
        }
    }
}

extension Publisher where Output: LoadableProtocol, Failure == Never {
    var loaded: AnyPublisher<Output.DataType, Failure> {
        self.compactMap(\.value).receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    var isLoading: AnyPublisher<Bool, Never> {
        self.map(\.isLoading).receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    var isFailed: AnyPublisher<Output.Failure, Never> {
        self.compactMap(\.error).receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
}

extension Publisher {
    func mapToLoadable() -> AnyPublisher<Loadable<Output>, Never>
    where Failure == Error {
        self
            .subscribe(on: RunLoop.main)
            .map {
                Loadable<Output>.loaded($0)
            }.catch {
                Just(Loadable.failed($0))
            }
            .assertNoFailure()
            .merge(with: Just(Loadable<Output>.isLoading(last: nil)))
            .eraseToAnyPublisher()
    }
    
}

extension Loadable {
    func map<V>(_ transform: (T) throws -> V) -> Loadable<V> {
        do {
            switch self {
            case .notRequested: return .notRequested
            case let .failed(error): return .failed(error)
            case .isLoading:
                return .isLoading(last: try value.map { try transform($0) }
                )
            case let .loaded(value):
                return .loaded(try transform(value))
            }
        } catch {
            return .failed(error)
        }
    }
}
extension Loadable {
    mutating func update(_ handler: (inout DataType) -> Void) {
        if case var .loaded(data) = self {
            handler(&data)
            self = .loaded(data)
        }
    }
}

extension Loadable where T: Hashable {
    var hashableValue: T? { value }
}

extension Loadable: Equatable where T: Equatable {
    public static func == (lhs: Loadable<T>, rhs: Loadable<T>) -> Bool {
        switch (lhs, rhs) {
        case let (.loaded(lhsValue), .loaded(rhsValue)):
            return lhsValue == rhsValue
        case let (.isLoading(lhsValue), .isLoading(rhsValue)):
            return lhsValue == rhsValue
        case let (.failed(lhsValue), .failed(rhsValue)):
            switch (lhsValue, rhsValue) {
            case let (lhsValue, rhsValue) as (NetworkError, NetworkError):
                return lhsValue == rhsValue
            default:
                return type(of: lhsValue) == type(of: rhsValue) && lhsValue.localizedDescription == rhsValue.localizedDescription
            }
        case (.notRequested, .notRequested):
            return true
        default:
            return false
        }
    }
}
