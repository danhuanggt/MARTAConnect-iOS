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
    
    let serverIP = "http://104.236.40.30:3000/api"
    
    // MARK: Methods for GET / POST
    
    func getRequestWith(_ urlString: URLConvertible, params: [String:Any] = ["":""], completion: @escaping (DataResponse<Any>) -> ()) {
        manager.request(urlString, method: .get, parameters: params)
            .validate()
            .responseJSON { response in
                completion(response)
        }
    }
    
    // MARK: API
    
    func getGeo(searchString: String, completion: @escaping (DataResponse<Any>) ->()) {
        let url = "\(serverIP)/geo"

        let params: [String:Any] = [
            "searchString" : searchString
        ]
        
        getRequestWith(url, params: params) { response in
            completion(response)
        }
    }
    
    func getTrip(currentLocation: CLLocationCoordinate2D, completion: @escaping (DataResponse<Any>) ->()) {
        let url = "\(serverIP)/trip"
        
        let params: [String:Any] = [
            "lat" : currentLocation.latitude,
            "lng" : currentLocation.longitude
        ]
        
        getRequestWith(url, params: params) { response in
            completion(response)
        }
    }
}
