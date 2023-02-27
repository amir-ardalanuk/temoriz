//
//  RemmemberListView.swift
//  Temorize
//
//  Created by ardalan on 2/25/23.
//

import Foundation
import SwiftUI

typealias RemmemberListStatefulViewModel = StatefulViewModel<RemmemberList.State, RemmemberList.Action, RemmemberList.Destination>

struct RemmemberListView: View {
    let viewModel: any RemmemberListStatefulViewModel
    @State private var state: RemmemberList.State?
    @State private var showWordModal: RemmeberedWord?
    @State private var tabSelected = 0
    var body: some View {
        NavigationView {
            VStack {
                if state?.list.isEmpty ?? true {
                    VStack(spacing: 12.0) {
                        Image(systemName: "bookmark.slash.fill")
                            .font(.system(size: 72))
                        Text("There isn't any word here")
                        
                    }.padding()
                } else {
                    LazyVStack(alignment: .leading, spacing: 8.0) {
                        VStack {
                            ForEach(state?.list ?? [], id: \.word) { word in
                                RemmemberRowListView(word: word)
                                    .onTapGesture {
                                        showWordModal = word
                                    }
                                Divider()
                            }
                        }
                    }
                    Spacer()
                }
            }
            .padding(.vertical)
            .onAppear {
                viewModel.handle(action: .observeToDatabase)
            }.onReceive(viewModel.stateSubject.eraseToAnyPublisher()) { value in
                state = value
            }.sheet(isPresented: .init(get: {
                showWordModal != nil
            }, set: { bool in
                showWordModal = nil
            })) {
                NavigationView {
                    TranslateView(translateList: showWordModal?.translate?.translates, definition: showWordModal?.definition)
                        .navigationTitle("Find and Memorieze")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar(content: {
                            Button {
                                showWordModal.flatMap {
                                    viewModel.handle(action: .remove(item: $0))
                                }
                                showWordModal = nil
                            } label: {
                                Image(systemName: "bookmark.fill")
                                
                            }})
                }
            }
            .navigationTitle("Remember Items")
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
}

struct RemmemberListView_Previews: PreviewProvider {
    static var previews: some View {
        let service = WordPersistance(databseManager: DatabaseManager())
        return RemmemberListView(viewModel: RemmemberListViewModel(wordPersistingUsecases: service))
    }
}
