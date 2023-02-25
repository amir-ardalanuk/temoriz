//
//  FeatureModules.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation
import SwiftUI

protocol BaseFeatureModule{
    associatedtype Configuration
    associatedtype ContentView: View
    func build(configuration: Configuration) -> ContentView
}

protocol FeatureModules {
    func homeModule() -> any HomeModule
}

final class AppFeatureModules: FeatureModules {
    let dependencies: Dependencies
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func homeModule() -> any HomeModule {
        Home.create
    }
}
