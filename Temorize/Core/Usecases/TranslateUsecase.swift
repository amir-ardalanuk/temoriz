//
//  TranslateUsecase.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation
protocol TranslateUsecase {
    func translate(word: String, from: String, to: String) async throws -> TranslateList
}
