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

private enum TabState {
    case translate
    case defination
}

struct HomeView: View {
    let viewModel: any HomeStatefulViewModel
    @State private var state: Home.State?
    @State private var tabStatus = TabState.translate

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button("Translate") {
                        tabStatus = .translate
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        tabStatus == .translate ? .blue.opacity(0.5):.white)
                    .foregroundColor(.black)

                    Button("Defination") {
                        tabStatus = .defination
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        tabStatus == .defination ? .blue.opacity(0.5):.white)
                    .foregroundColor(.black)
                }
                .padding([.horizontal, .top], 8)

                if tabStatus == .translate {
                    VStack {
                        WithViewStore(viewStore: .init(publisher: viewModel.stateSubject.map(\.translate).eraseToAnyPublisher())) { value in
                            if let values = value?.value?.translates {
                                translateView(values: values)
                                    .padding(8)
                                    .background(.blue.opacity(0.5))
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
                    }
                }

                if tabStatus == .defination {
                    VStack {
                        WithViewStore(viewStore: .init(publisher: viewModel.stateSubject.map(\.definition).eraseToAnyPublisher())) { value in
                            if let values = value?.value {
                                definationView(values: values)
                                    .padding(8)
                                    .background(.blue.opacity(0.5))
                            } else {
                                Text("No Definition")
                            }
                        }
                    }
                }

                Spacer()
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

    private func translateView(values: [Translate]) -> some View {
        VStack(alignment: .leading) {
            ForEach(values, id: \.self) { value in
                HStack {
                    Circle()
                        .background(.black)
                        .frame(width: 12, height: 12)
                    Text(value.text)
                        .font(.headline)
                    Spacer()
                }
            }
        }
    }

    private func definationView(values: DefinitionList) -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(values, id: \.self) { definition in
                    VStack(alignment: .leading) {
                        Text(definition.partOfSpeech)
                            .font(.title)
                        Divider()
                        HStack {
                            Circle()
                                .background(.black)
                                .frame(width: 12, height: 12)
                            Text(definition.definition)
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .padding(.top, 8)
                }
            }
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
