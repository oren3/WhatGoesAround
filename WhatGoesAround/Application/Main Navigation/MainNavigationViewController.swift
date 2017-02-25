//
//  MainNavigationViewController.swift
//  WhatGoesAround
//
//  Created by Oren Bachar on 24/02/2017.
//  Copyright © 2017 Oren Bachar. All rights reserved.
//

import UIKit
import AFNetworking

class MainNavigationViewController: UINavigationController
{
    //MARK: Static Properties
    
    static let noInternetConnectionTitleString: String = "No internet connection"
    static let noInternetConnectionMessageString: String = "You need to connect to internet before you continue. Please check your connectivity settings"
    static let noInternetOkButtonString: String = "OK"
    
    //MARK: Properties
    
    var placesViewController: PlacesViewController = PlacesViewController()
    var isLoadedFirstTime: Bool = true
    
    //MARK: View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if self.viewControllers.count > 0
        {
            // Get the places view controller
            placesViewController = self.viewControllers.first as! PlacesViewController
        }
        
        NetworkManager.sharedInstance.networkConnectionHasChanged
        { (status: AFNetworkReachabilityStatus) in
            
            // Network status has changed
            if status == AFNetworkReachabilityStatus.notReachable || status == AFNetworkReachabilityStatus.unknown
            {
                // Show alert controller - User has no internet connection
                let noConnectionAlertController: UIAlertController = UIAlertController.init(title: MainNavigationViewController.noInternetConnectionTitleString, message: MainNavigationViewController.noInternetConnectionMessageString, preferredStyle: UIAlertControllerStyle.alert)
                
                noConnectionAlertController.addAction(UIAlertAction.init(title: MainNavigationViewController.noInternetOkButtonString, style: UIAlertActionStyle.cancel, handler: nil))
                
                DispatchQueue.main.async
                {
                    self.present(noConnectionAlertController, animated: true, completion: nil)
                }
            }
            else
            {
                // User have network connectivity. Check if we need to update places
                if !self.isLoadedFirstTime && self.placesViewController.shouldRefreshPlacesOnMap()
                {
                    DispatchQueue.main.async
                    {
                        var coordinateToShowOnMap: CLLocationCoordinate2D = LocationManager.sharedInstance.currentCoordinate
                        
                        if LocationManager.sharedInstance.lastSearchedCoordinate.longitude != 0.0 && LocationManager.sharedInstance.lastSearchedCoordinate.latitude != 0.0
                        {
                            // We have searched before. Show the user it's most current searched coordinate.
                            coordinateToShowOnMap = LocationManager.sharedInstance.lastSearchedCoordinate
                        }
                        
                        // Update places in placesViewController
                        self.placesViewController.searchPlacesNearbyCoordinate(coordinate: coordinateToShowOnMap)
                    }
                }
                
                self.isLoadedFirstTime = false
            }
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
