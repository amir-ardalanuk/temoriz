//
//  HomeScreenView.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation
import SwiftUI
import Combine

typealias HomeStatefulViewModel = StatefulViewModel<Home.State, Home.Action, HomeViewModel.Destination>

struct ActivityIndicator: UIViewRepresentable {
    
    typealias UIView = UIActivityIndicatorView
    var isAnimating: Bool
    fileprivate var configuration = { (indicator: UIView) in }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView { UIView() }
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        configuration(uiView)
    }
    
}

struct HomeView: View {
    let viewModel: any HomeStatefulViewModel
    @State private var state: Home.State?
    var body: some View {
        NavigationView {
            VStack {
                WithViewStore(viewStore: .init(publisher: viewModel.stateSubject.map(\.translate).eraseToAnyPublisher())) { value in
                    if let values = value?.value?.translates {
                        List(values, id: \.text) { translate in
                            Section(header: Text("Translate")) {
                                Text(translate.text)
                            }.headerProminence(.increased)
                        }.listStyle(.grouped)
                    } else {
                        if let value = value?.error {
                            Text(value.localizedDescription)
                        }
                        if value?.isLoading ?? false {
                            ActivityIndicator(isAnimating: true)
                        } else {
                            VStack(spacing: 12.0) {
                                Image(systemName: "square.stack.3d.down.right.fill")
                                    .font(.system(size: 72))
                                Text("You can Search")
                                
                            }.padding()
                        }
                    }
                }
                
                WithViewStore(viewStore: .init(publisher: viewModel.stateSubject.map(\.definition).eraseToAnyPublisher())) { value in
                    if let values = value?.value {
                        List(values, id: \.definition) { definition in
                            Section(header: Text(definition.definition)) {
                                VStack {
                                    Text(definition.partOfSpeech)
                                    Text(definition.derivation?.joined(separator: "\n") ?? "No Derivation")
                                    Text(definition.examples?.joined(separator: "\n") ?? "No Example")
                                    Text(definition.memberOf?.joined(separator: "\n") ?? "No Memeber")
                                }
                            }.headerProminence(.increased)
                        }.listStyle(.grouped)
                    } else {
                        Text("No Definition")
                    }
                }
            }
        }.navigationTitle("Find and Memorieze")
            .searchable(text: .init(get: {
                state?.query ?? ""
            }, set: { text in
                viewModel.handle(action: .query(text))
            }), placement: .navigationBarDrawer(displayMode: .always)) {
            }.onReceive(viewModel.stateSubject.eraseToAnyPublisher()) { state in
                self.state = state
            }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let service = PresentationTranslateServices()
        let local = WordPersistance(databseManager: DatabaseManager())
        return HomeView(viewModel: HomeViewModel(definitionUsecase: service, translateUsecase: service, wordPersistingUsecases: local))
    }
}
