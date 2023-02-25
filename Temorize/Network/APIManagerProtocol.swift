//
//  APIManagerProtocol.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation

protocol APIManagerProtocol {
  func perform(_ request: RequestProtocol, authToken: String) async throws -> Data
}

final class APIManager: APIManagerProtocol {
  private let urlSession: URLSession

  init(urlSession: URLSession = URLSession.shared) {
    self.urlSession = urlSession
  }
    
    func perform(_ request: RequestProtocol,
      authToken: String = "") async throws -> Data {
        let requestURL = try request.createURLRequest(authToken: authToken)
      let (data, response) = try await urlSession.data(for: requestURL)
        print("Request: =>>>>> \(requestURL.debugDescription)")
        print("Response: =>>>>> \((response as? HTTPURLResponse).debugDescription)")
      guard let httpResponse = response as? HTTPURLResponse,
        httpResponse.statusCode == 200
      else {
        throw NetworkError.invalidServerResponse(data)
      }
      return data
    }
}
