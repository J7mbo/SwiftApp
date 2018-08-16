//
//  NetworkResponse.swift
//  GithubBusApp
//
//  Created by James Mallison on 21/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import Foundation

/// Contains the response data from `NetworkRequestClient.request()`
struct NetworkResponse
{
    /// The status of the response
    let statusCode: Int

    /// The response string, which could be nil if nothing is returned
    let string: String?

    /// If `string` could be converted to `[String: Any]`, this will be returned
    var asJson: [String: Any]? {
        get {
            guard let data = string?.data(using: .utf8) else {
                return nil
            }
            
            guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return nil
            }
            
            return jsonData
        }
    }
}
