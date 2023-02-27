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
struct TestTextfield: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    @Binding var text: String
    var keyType: UIKeyboardType
    
    public final class Coordinator: NSObject {
        @Binding private var text: String
        
        public init(text: Binding<String>) {
            self._text = text
        }
        
        @objc func textChanged(_ sender: UITextField) {
            guard let text = sender.text else { return }
            self.text = text
        }
    }
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
      textField.keyboardType = keyType
        let bar = UIToolbar()
        let action = UIAction.captureTextFromCamera(responder: textField, identifier: nil)
        let ocr = UIBarButtonItem(title: "OCR", image: .init(systemName: ""), primaryAction: action, menu: nil)
        bar.items = [ocr]
        bar.sizeToFit()
        textField.inputAccessoryView = bar
        textField.addTarget(context.coordinator, action: #selector(context.coordinator.textChanged), for: .editingChanged)
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
}

extension  UITextField{
    @objc func doneButtonTapped(button:UIBarButtonItem) -> Void {
       self.resignFirstResponder()
    }

}

private enum TabState {
    case translate
    case defination
}

struct HomeView: View {
    let viewModel: any HomeStatefulViewModel
    @State private var state: Home.State?
    @State private var tabSelected = 0

    var body: some View {
        NavigationView {
            VStack {
                TestTextfield(text: .init(get: {
                                        state?.query ?? ""
                                    }, set: { text in
                                        viewModel.handle(action: .query(text))
                                    }), keyType: UIKeyboardType.default)
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 45)
                .overlay(
                    RoundedRectangle(cornerRadius: 8.0)
                        .stroke(Color(uiColor: .lightGray), lineWidth: 1))
                .padding()

              
                if state?.query?.isEmpty ?? true {
                    HStack(alignment: .center, spacing: 8.0) {
                        Image("empty")
                    }
                    Spacer()
                } else {
                    if state?.translate.isLoading ?? false || state?.translate.value == nil {
                        ActivityIndicator(isAnimating: true)
                    } else {
                        WithViewStore(viewStore: .init(publisher: viewModel.stateSubject.eraseToAnyPublisher())) { state in
                            TranslateView(translateList: state?.translate.value?.translates, definition: state?.definition.value)
                        }
                    }
                    Spacer()
                }
               
            }.navigationTitle("Find and Memorieze")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    WithViewStore(viewStore: .init(publisher: viewModel.stateSubject.map(\.hasBookmarkButton).eraseToAnyPublisher())) { bool in
                        if bool ?? false {
                            Button {
                                viewModel.handle(action: .toggle)
                            } label: {
                                Image(systemName: viewModel.state.isBookmarked ? "bookmark.fill" : "bookmark")
                            }
                        }
                    }
                }).onReceive(viewModel.stateSubject.eraseToAnyPublisher()) { state in
                    self.state = state
                }
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
