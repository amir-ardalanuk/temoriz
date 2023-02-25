//
//  RequestProtocol.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//
// Use https://www.kodeco.com/books/real-world-ios-by-tutorials/v1.0/chapters/3-data-layer-networking
//

import Foundation

protocol RequestProtocol {
    var host: String { get }
    var path: String { get }
    var headers: [String: String] { get }
    var params: [String: Any] { get }
  var urlParams: [String: String?] { get }
  var addAuthorizationToken: Bool { get }
  var requestType: RequestType { get }
}

enum RequestType: String {
  case GET
  case POST
}

extension RequestProtocol {
  
  var addAuthorizationToken: Bool {
    false
  }
  
  var params: [String: Any] {
    [:]
  }

  var urlParams: [String: String?] {
    [:]
  }

  var headers: [String: String] {
    [:]
  }
}

extension RequestProtocol {
    func createURLRequest(authToken: String) throws -> URLRequest {

      var components = URLComponents()
      components.scheme = "https"
      components.host = host
      components.path = path

      if !urlParams.isEmpty {
        components.queryItems = urlParams.map {
          URLQueryItem(name: $0, value: $1)
        }
      }

      guard let url = components.url
      else { throw NetworkError.invalidURL }

      var urlRequest = URLRequest(url: url)
      urlRequest.httpMethod = requestType.rawValue

      if !headers.isEmpty {
        urlRequest.allHTTPHeaderFields = headers
      }

      if addAuthorizationToken {
        urlRequest.setValue(authToken,
          forHTTPHeaderField: "Authorization")
      }

      urlRequest.setValue("application/json",
        forHTTPHeaderField: "Content-Type")

      if !params.isEmpty {
        urlRequest.httpBody = try JSONSerialization.data(
          withJSONObject: params)
      }

      return urlRequest
    }
}
