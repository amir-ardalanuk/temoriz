//
//  DataParserProtocol.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation
protocol DataParserProtocol {
    func parse<T: Decodable>(_ data: Data, type: T.Type) throws -> T
}

final class DataParser: DataParserProtocol {
    let decoder: JSONDecoder
    
    init(decoder: JSONDecoder = .init()) {
        self.decoder = decoder
    }
    
    func parse<T>(_ data: Data, type: T.Type) throws -> T where T : Decodable {
       try decoder.decode(T.self, from: data)
    }
    
    
}
