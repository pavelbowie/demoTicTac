//
//  SharedNetworkManager.swift
//  demoTicTac
//
//  Created by PavelMac on 1/02/2025.
//  Copyright © 2025 Monitoreal – Smart Monitoring LLC. All rights reserved.
//

import Foundation

enum SharedNetworkManagerErrorType: Error {
    case invalidUrlError(String)
}

class SharedNetworkManager {
    
    public static let shared =  SharedNetworkManager()
    
    fileprivate lazy var privateSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
    
    fileprivate let serverUrl = URL(string: "http://127.0.0.1:8020")

    public func getDataWithRelativePath(_ path: String,
                                        completionBlock: @escaping ((_ data: Data?,_ error:Error?) -> Void)) {
        
        guard let url = URL(string:path,relativeTo: serverUrl) else {
            completionBlock(nil,SharedNetworkManagerErrorType.invalidUrlError(path))
            return
        }
        
        let task = self.privateSession.dataTask(with: url) { data, _, error in
            completionBlock(data,error)
        }
        task.resume()
    }
    
    public func postData(data: Data, withRelativePath path: String,
                         completionBlock: ((_ error:Error?) -> Void)? = nil) {
        guard let url = URL(string:path, relativeTo: serverUrl) else {
            completionBlock?(SharedNetworkManagerErrorType.invalidUrlError(path))
            return
        }
        
        var mutablePOSTRequest = URLRequest(url: url)
        mutablePOSTRequest.httpMethod = "POST"
        mutablePOSTRequest.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        mutablePOSTRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
     
        let task = self.privateSession.uploadTask(with: mutablePOSTRequest, from: data) { _, _, error in
            completionBlock?(error)
        }
        task.resume()
    }
}
