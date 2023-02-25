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
    var body: some View {
        if state?.list.isEmpty ?? true {
            VStack(spacing: 12.0) {
                Image(systemName: "bookmark.slash.fill")
                    .font(.system(size: 72))
                Text("There isn't any word here")
                
            }.padding()
        } else {
            LazyVStack(alignment: .leading, spacing: 7.0) {
                ForEach(state?.list ?? [], id: \.word) { word in
                    RemmemberRowListView(word: word)
                        .listRowSeparatorTint(Color.gray)
                }
            }
        }
        
    }
}

struct RemmemberListView_Previews: PreviewProvider {
    static var previews: some View {
        let service = WordPersistance(databseManager: DatabaseManager())
        return RemmemberListView(viewModel: RemmemberListViewModel(wordPersistingUsecases: service))
    }
}
