//
//  WordsapiRequest.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation
enum WordsApiRequest {
    case word(String)
}

extension WordsApiRequest: RequestProtocol {
    var path: String {
        switch self {
        case let .word(word):
            return "/mashape/words/\(word.utf8)"
        }
    }
    
    var host: String {
        "www.wordsapi.com"
    }
    
    var requestType: RequestType {
        .GET
    }
    
    var urlParams: [String: String?] {
        switch self {
        case .word:
            var params = [String: String]()
            params["encrypted"] = "8cfdb189e722919bea9907bdef58bab8aeb22c0935fa97b8"
            params["when"] = "2023-02-08T20:41:21.550Z"
            return params
        }
    }
    
    var headers: [String : String] {
        var header = [String: String]()
        header["User-Agent"] = "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:52.0) Gecko/20100101 Firefox/52.0"
        return header
    }
}
