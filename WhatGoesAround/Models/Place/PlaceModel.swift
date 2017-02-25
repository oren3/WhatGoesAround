//
//  PlaceModel.swift
//  WhatGoesAround
//
//  Created by Oren Bachar on 23/02/2017.
//  Copyright © 2017 Oren Bachar. All rights reserved.
//

import UIKit

class PlaceModel: NSObject
{
    var name: String = String()
    var address: String = String()
    var iconImageString: String = String()
    var imageReferenceString: String = String()
    var distanceFromCurrentLocation: CLLocationDistance = CLLocationDistance()
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    //MARK: Initializations
    
    init(dictionary: [String : AnyObject]?, isForSearch: Bool)
    {
        super.init()
        
        if isForSearch
        {
            self.setSearchPlaceModel(dictionary: dictionary)
        }
        else
        {
            self.setPlaceModel(dictionary: dictionary)
        }
    }
    
    //MARK: Private Methods
    
    private func setPlaceModel(dictionary: [String : AnyObject]?)
    {
        if dictionary != nil
        {
            let location = dictionary?["geometry"]?["location"] as? [String : AnyObject];
            
            if (location != nil)
            {
                coordinate.latitude = location?["lat"] as! CLLocationDegrees
                coordinate.longitude = location?["lng"] as! CLLocationDegrees
                
                // Calculate the distance between current location and place location
                let placeLocation: CLLocation = CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let currentLocation: CLLocation = CLLocation.init(latitude: LocationManager.sharedInstance.currentCoordinate.latitude, longitude: LocationManager.sharedInstance.currentCoordinate.longitude)
                
                distanceFromCurrentLocation = currentLocation.distance(from: placeLocation)
            }
            
            name = dictionary?["name"] as? String ?? ""
            address = dictionary?["vicinity"] as? String ?? ""
            iconImageString = dictionary?["icon"] as? String ?? ""
            
            // Get photo reference here
            
            if (dictionary?["photos"] != nil)
            {
                let photosArray = dictionary?["photos"] as! NSArray
                
                if photosArray.count > 0
                {
                    let photosDictionary = photosArray.object(at: 0) as? [String : AnyObject]
                    imageReferenceString = (photosDictionary?["photo_reference"] as? String)!
                }
            }
        }
    }
    
    private func setSearchPlaceModel(dictionary: [String : AnyObject]?)
    {
        name = dictionary?["structured_formatting"]?["main_text"] as? String ?? ""
        address = dictionary?["description"] as? String ?? ""
        imageReferenceString = dictionary?["reference"] as? String ?? ""
    }
}
