//
//  NetworkError.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation

enum NetworkError: Error, Equatable, CustomStringConvertible {
    case invalidURL
    case invalidServerResponse(Data?)
    case ServerError(ServerError)
    case failedParsingData
    
    var description: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidServerResponse(let data):
            return "Invalid Server Response with \(String(data: data ?? .init(), encoding: .utf8))"
        case .ServerError(let serverError):
            return serverError.message
        case .failedParsingData:
            return "failed Parsing Data"
        }
    }
}

struct ServerError: Decodable, Hashable, Equatable {
    let success: Bool
    let message: String
}
