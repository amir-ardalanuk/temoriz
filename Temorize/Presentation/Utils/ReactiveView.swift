//
//  ReactiveView.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation
import Combine
import SwiftUI

public struct WithViewStore<State, Content>: View where Content: View {

    private let content: (State?) -> Content
    @ObservedObject private var viewStore: ObserveModel<State>
    
    init(viewStore: ObserveModel<State>, @ViewBuilder content: @escaping (State?) -> Content) {
        self.content = content
        self.viewStore = viewStore
    }
    
    public var body: Content {
        return self.content(viewStore.value)
     }
}

final class ObserveModel<T>: ObservableObject {
    @Published var value: T?
    private let publisher: any Publisher<T, Never>
    private var cancellable: AnyCancellable? = nil
    init(value: T? = nil, publisher: any Publisher<T, Never>) {
        self.value = value
        self.publisher = publisher
        cancellable = publisher.sink { [weak self] value in
            self?.value = value
        }
    }
    
}
