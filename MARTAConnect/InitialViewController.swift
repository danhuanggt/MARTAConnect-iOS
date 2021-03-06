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

class InitialViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var tripView: UIView!
    @IBOutlet weak var tripViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var trip1Name: UILabel!
    @IBOutlet weak var trip1Distance: UILabel!
    @IBOutlet weak var trip1Time: UILabel!
    @IBOutlet weak var trip2Name: UILabel!
    @IBOutlet weak var trip2Distance: UILabel!
    @IBOutlet weak var trip2Time: UILabel!
    @IBOutlet weak var trip3Name: UILabel!
    @IBOutlet weak var trip3Distance: UILabel!
    @IBOutlet weak var trip3Time: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    var currentLocation = CLLocationCoordinate2D()
    var destinationLocation = CLLocationCoordinate2D()
    var hasZoomedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Setup Map
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        // Setup Constraint
        tripViewHeightConstraint.constant = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goButtonPressed(_ sender: AnyObject) {
        getGeo()
    }
    
    @IBAction func startButtonPressed(_ sender: AnyObject) {
        startButton.setTitle("Walk to \(trip1Name.text!)...", for: .normal)
        startButton.isEnabled = false
    }

    @IBAction func textField(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    // MARK: Networking
    
    func getGeo() {
        // Perform search
        guard let searchString = locationTextField.text else {
            return
        }
        
        NetworkingManager.sharedInstance.getGeo(searchString: searchString) { response in
            switch response.result {
            case .success(let value):
                print ("API Response Succeeded")
                
                guard let JSONResponse = value as? NSDictionary else {
                    return
                }
                
                print(JSONResponse)
                
                if let lat = JSONResponse["lat"] as? Double, let lng = JSONResponse["lng"] as? Double {
                    self.destinationLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    self.showDestination()
                    self.getTrip()
                }
                
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
    
    func getTrip() {
        NetworkingManager.sharedInstance.getTrip(currentLocation: currentLocation, destinationLocation: destinationLocation) { response in
            switch response.result {
            case .success(let value):
                print ("API Response Succeeded")
                
                guard let JSONResponse = value as? NSDictionary else {
                    return
                }
                
                self.trip1Name.text = JSONResponse["startMartaname"] as? String
                self.trip1Time.text = JSONResponse["startMartatime"] as? String
                self.trip1Distance.text = JSONResponse["startMartadist"] as? String
                
                self.trip2Name.text = JSONResponse["startUbername"] as? String
                self.trip2Time.text = JSONResponse["startUbertime"] as? String
                self.trip2Distance.text = JSONResponse["startUbercost"] as? String
                
                self.trip3Name.text = JSONResponse["endTripname"] as? String
                self.trip3Time.text = JSONResponse["endTriptime"] as? String
                
                let distance = JSONResponse["endTripdist"] as? String
                let cost = JSONResponse["endTripcost"] as? String
                self.trip3Distance.text = "\(distance!) (\(cost!))"
                
                print(JSONResponse)
                
                self.showTrip()
                
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
    
    // MARK: UI
    
    func showDestination() {
        // Show destination placemarker
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = self.destinationLocation
        destinationAnnotation.title = "Destination"
        mapView.addAnnotation(destinationAnnotation)
        
        let region = MKCoordinateRegion(center: self.destinationLocation, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        mapView.setRegion(region, animated: true)
        
        // Animate out blurView on geocode success
        UIView.animate(withDuration: 1.0) {
            self.blurView.alpha = 0
        }
    }
    
    func showTrip() {
        tripViewHeightConstraint.constant = 400
        UIView.animate(withDuration: 0.75) { 
            self.view.layoutIfNeeded()
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
    
    // MARK: Map
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        currentLocation = userLocation.coordinate
        if (hasZoomedIn == false) {
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            mapView.setRegion(region, animated: true)
            hasZoomedIn = true
        }
    }
}

