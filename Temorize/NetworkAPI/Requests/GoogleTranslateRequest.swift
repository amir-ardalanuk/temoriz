//
//  GoogleTranslateRequest.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation
enum GoogleAPIRequest {
    case translate(from: String, to: String, sentence: String)
}

extension GoogleAPIRequest: RequestProtocol {
    var path: String {
        "/translate_a/single"
    }
    
    var host: String {
        "translate.googleapis.com"
    }
    
    var requestType: RequestType {
        .POST
    }
    
    var urlParams: [String: String?] {
        switch self {
        case let .translate(from, to, sentence):
            var params = [
                "client": "gtx",
                "hl": "en-US",
                "dt": "at",
                "dj":"1",
                "source":"input"
            ]
            params["sl"] = from
            params["tl"] = to
            params["q"] = sentence
            return params
        }
    }
    
    var headers: [String : String] {
        var header = [String: String]()
        header["User-Agent"] = "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:52.0) Gecko/20100101 Firefox/52.0"
        return header
    }
}
