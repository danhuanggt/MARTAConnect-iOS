//
//  NetworkingManager.swift
//  MARTAConnect
//
//  Created by Dan Huang on 10/29/16.
//  Copyright © 2016 Technic. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

class NetworkingManager {
    static let sharedInstance = NetworkingManager()
    
    let manager = SessionManager()
    
    let serverIP = "http://104.236.40.30:3000"
    
    // MARK: Methods for GET / POST
    
    func getRequestWith(_ urlString: URLConvertible, params: [String:Any] = ["":""], completion: @escaping (DataResponse<Any>) -> ()) {
        manager.request(urlString, method: .get, parameters: params)
            .validate()
            .responseJSON { response in
                completion(response)
        }
    }
    
    // MARK: API
    
    func getSome(_ completion: @escaping (DataResponse<Any>) ->()) {
        let someURL = "\(serverIP)/some"
        getRequestWith(someURL) { response in
            completion(response)
        }
    }
}
