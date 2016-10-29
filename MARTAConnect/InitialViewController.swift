//
//  ViewController.swift
//  MARTAConnect
//
//  Created by Dan Huang on 10/29/16.
//  Copyright © 2016 Technic. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class InitialViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Networking
    
    func getSome() {
        NetworkingManager.sharedInstance.getSome { response in
            switch response.result {
            case .success(let value):
                print ("API Response Succeeded")
                
                guard let JSONResponse = value as? NSDictionary else {
                    return
                }
                print(JSONResponse)
                
            case .failure(let error):
                print("API Response Failed: \(error)")
                
                // Show Network Error Alert
                let networkErrorAlertController = UIAlertController(title: "Network Error",
                message: error.localizedDescription,
                preferredStyle: .alert)

                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)

                networkErrorAlertController.addAction(okAction)
                self.present(networkErrorAlertController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: CoreLocation
    
    func checkLocationPermission() {
        let locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        switch locationAuthorizationStatus {
        case .notDetermined:
            // Request permission
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted, .denied:
            // Display permission alert
            let locationPermissionErrorTitle = "Location Permission Error"
            let locationPermissionErrorMessage = "MARTAConnect needs permission to access your location.\n\nGo to your iOS Settings → Privacy → Location Services and enable access for MARTAConnect."
            
            let alertController = UIAlertController(title: locationPermissionErrorTitle,
                                                    message: locationPermissionErrorMessage,
                                                    preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok",
                                         style: UIAlertActionStyle.default)
            { (action: UIAlertAction) -> Void in
                // Do Nothing
            }
            
            alertController.addAction(okAction)
            DispatchQueue.main.async(execute: {
                self.present(alertController, animated: true, completion: nil)
            })
            break
        default:
            // Start getting location
            locationManager.startUpdatingLocation()
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Check permission for location services
        checkLocationPermission()
    }
}

