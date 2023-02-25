//
//  TemorizeApp.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import SwiftUI

@main
struct TemorizeApp: App {
    let appDependencies: AppDependencies = AppDI()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Home.create.build(configuration: .init(definitionUsecase: appDependencies.dependencies.wordUsecases, translateUsecase: appDependencies.dependencies.translateUsecase, wordPersistingUsecases: appDependencies.dependencies.wordPersisting))
            }
        }
    }
}
