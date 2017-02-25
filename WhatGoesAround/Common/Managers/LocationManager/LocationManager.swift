//
//  LocationManager.swift
//  WhatGoesAround
//
//  Created by Oren Bachar on 24/02/2017.
//  Copyright © 2017 Oren Bachar. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationManagerDelegate
{
    func locationUpdated(newLocationCoordinate: CLLocationCoordinate2D)
}

class LocationManager: NSObject, CLLocationManagerDelegate
{
    //MARK: Properties
    
    private let locationManager: CLLocationManager = CLLocationManager()
    public var currentCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    public var lastSearchedCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    //MARK: Delegate 
    
    internal var delegate: LocationManagerDelegate!
    
    //MARK: Initializations
    
    static let sharedInstance: LocationManager =
    {
        let instance = LocationManager()
        
        return instance
    }()
    
    override init()
    {
        super.init()
        
        // Initiate location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    //MARK: CLLocation Delegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // Location updated. inform all clases registered to the protocol.
        let newUserLocation = locations[0]
        currentCoordinate = newUserLocation.coordinate
        self.delegate?.locationUpdated(newLocationCoordinate: newUserLocation.coordinate)
    }
}
