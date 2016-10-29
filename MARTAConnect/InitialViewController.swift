//
//  ViewController.swift
//  MARTAConnect
//
//  Created by Dan Huang on 10/29/16.
//  Copyright © 2016 Technic. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
}

