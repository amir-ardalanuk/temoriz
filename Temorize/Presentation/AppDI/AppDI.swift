//
//  AppDI.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation
import SwiftUI

protocol AppDependencies {
    var module: FeatureModules { get }
    var dependencies: Dependencies{ get }
}

final class AppDI: AppDependencies {
    lazy var module: FeatureModules = {
        AppFeatureModules(dependencies: dependencies)
    }()
    
    lazy var dependencies: Dependencies = {
        DependencyLocator()
    }()
}


