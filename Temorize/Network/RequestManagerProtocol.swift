//
//  RequestManagerProtocol.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation

protocol RequestManagerProtocol {
  func perform<T: Decodable>(_ request: RequestProtocol) async throws -> T
}

class RequestManager: RequestManagerProtocol {
  let apiManager: APIManagerProtocol
  let parser: DataParserProtocol

  init(
  apiManager: APIManagerProtocol = APIManager(),
  parser: DataParserProtocol = DataParser() // 2
  ) {
    self.apiManager = apiManager
    self.parser = parser
  }

  func perform<T: Decodable>(
    _ request: RequestProtocol) async throws -> T {
        do {
            let data = try await apiManager.perform(request, authToken: "")
            return try parser.parse(data, type: T.self)
        } catch {
            if let network = error as? NetworkError {
                switch network {
                case let .invalidServerResponse(data):
                    let serverError = try parser.parse(data ?? .init(), type: ServerError.self)
                    throw NetworkError.ServerError(serverError)
                default:
                    throw error
                }
            } else {
                throw error
            }
        }
  }
}
