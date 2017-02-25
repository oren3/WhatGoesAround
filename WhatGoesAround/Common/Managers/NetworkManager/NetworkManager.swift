//
//  NetworkManager.swift
//  WhatGoesAround
//
//  Created by Oren Bachar on 24/02/2017.
//  Copyright © 2017 Oren Bachar. All rights reserved.
//

import UIKit
import AFNetworking

class NetworkManager: NSObject
{
    var networkStatusBlock : ((AFNetworkReachabilityStatus) -> Void)?
    
    static let sharedInstance: NetworkManager =
    {
        let instance = NetworkManager()
        
        return instance
    }()
    
    //MARK: Public Methods
    
    /// Google nearby search
    ///
    /// - Parameters:
    ///   - apiKey: Google Api key
    ///   - coordinates: A given coordinate to search accordingly
    ///   - radiusString: A given radius to search for
    ///   - successBlock: Success - Will give us array of place models
    ///   - failureBlock: Failure - Request failed
    public func getNearbyPlaces(apiKey: String, coordinates: CLLocationCoordinate2D, radiusString: String, successBlock: @escaping (NSMutableArray?) -> (), failureBlock: @escaping (NSError?) -> ())
    {
        // Creating the URL string for making the request
        let locationString:NSString = NSString.localizedStringWithFormat("%f,%f", coordinates.latitude, coordinates.longitude)
        let placesUrlString: NSString = NSString.localizedStringWithFormat("%@/place/nearbysearch/json?location=%@&radius=%@&key=%@&sensor=true", GlobalConstants.kGooglePlacesApiBaseUrl, locationString, radiusString, apiKey)
        
        // Make the request
        self.sendRequest(path: placesUrlString, parameters: nil, method: "GET", timeoutInterval: 15.0, successBlock:
            { (response: [String : AnyObject]?) in
            
                // Got places. Create here place models
                let placesArray: NSMutableArray = NSMutableArray()
                
                if (response != nil)
                {
                    let resultsArray: NSArray = response!["results"] as! NSArray
                    
                    for value in resultsArray
                    {
                        let placeDictionary = value as! [String : AnyObject]
                        let placeModel: PlaceModel = PlaceModel.init(dictionary: placeDictionary, isForSearch: false)
                        
                        placesArray.add(placeModel)
                    }
                }
                
                successBlock(placesArray)
                
        })
        { (error: NSError?) in
            failureBlock(error)
        }
    }
    
    /// Google Autocomplete Search
    ///
    /// - Parameters:
    ///   - input: The string a user entered for searching
    ///   - apiKey: Google api key
    ///   - successBlock: Success - Will give us array of place models
    ///   - failureBlock: Failure - Request failed
    public func getGoogleSearchPlaces(input: String, apiKey: String, successBlock: @escaping (NSArray?) -> (), failureBlock: @escaping (NSError?) -> ())
    {
        // Create the request url here
        let requestString: String = NSString.localizedStringWithFormat("%@/place/autocomplete/json?input=%@&key=%@", GlobalConstants.kGooglePlacesApiBaseUrl, input, apiKey) as String
        
        self.sendRequest(path: requestString as NSString, parameters: nil, method: "GET", timeoutInterval: 15.0, successBlock:
            {(response: [String : AnyObject]?) in

                // Got places. Create here place models
                let placesArray: NSMutableArray = NSMutableArray()
                
                if (response != nil)
                {
                    let resultsArray: NSArray = response!["predictions"] as! NSArray
                    
                    for value in resultsArray
                    {
                        let placeDictionary = value as! [String : AnyObject]
                        let placeModel: PlaceModel = PlaceModel.init(dictionary: placeDictionary, isForSearch: true)
                        
                        placesArray.add(placeModel)
                    }
                }
                
                successBlock(placesArray)
                
        })
        { (error: NSError?) in
            
            // Request failed
            failureBlock(error)
        }
    }
    
    /// Convert an address to coordinates with Google geocode
    ///
    /// - Parameters:
    ///   - placeModel: We will use the placeModel's address to get a coordinate
    ///   - apiKey: Google api key
    ///   - successBlock: Success - Will give us a place model with an updated coordinate inside
    ///   - failureBlock: Failure - Request failed
    public func getCoordinateForPlace(placeModel: PlaceModel, apiKey: String, successBlock: @escaping (PlaceModel?) -> (), failureBlock: @escaping (NSError?) -> ())
    {
        // Create request url here
        let requestString: String = NSString.localizedStringWithFormat("%@/geocode/json?address=%@&key=%@", GlobalConstants.kGooglePlacesApiBaseUrl, placeModel.address, apiKey) as String
        
        self.sendRequest(path: requestString as NSString, parameters: nil, method: "GET", timeoutInterval: 15.0, successBlock: { (response :[String : AnyObject]?) in
            
            // Got results. Parse for coordinate
            let addressArray: NSArray = response?["results"] as? NSArray ?? NSArray()
            
            if addressArray.count > 0
            {
                let addressDictionary: [String : AnyObject] = addressArray.firstObject as? [String : AnyObject] ?? [String : AnyObject]()
                
                let locationDictionary = addressDictionary["geometry"]?["location"] as? [String : AnyObject];
                placeModel.coordinate.latitude = locationDictionary?["lat"] as? CLLocationDegrees ?? 0.0
                placeModel.coordinate.longitude = locationDictionary?["lng"] as? CLLocationDegrees ?? 0.0
            }
            
            successBlock(placeModel)
            
        })
        { (error: NSError?) in
            
            // Request failed
            failureBlock(error)
        }
    }
    
    //MARK: Private Methods
    
    /// This is a general method for making a request to a remote server
    ///
    /// - Parameters:
    ///   - path: The path we wish to reach (Url string)
    ///   - parameters: In case the request inclouds some parameters
    ///   - method: Method type. (Could be GET, POST, PUT...)
    ///   - timeoutInterval: Timeout in seconds
    ///   - successBlock: Success - Will give us a dictionary
    ///   - failureBlock: Request failed
    private func sendRequest(path: NSString, parameters: NSDictionary?, method: NSString, timeoutInterval: CGFloat, successBlock: @escaping ([String : AnyObject]?) -> (), failureBlock: @escaping (NSError?) -> ())
    {
        // Create a url for request
        let newPathString = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: newPathString! as String)
        
        // Create the Url request and the session
        let request = NSMutableURLRequest.init(url: url!)
        let session = URLSession.shared
        
        request.httpMethod = method as String
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let _: NSError?
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = TimeInterval(timeoutInterval)
        
        // Make a task call
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, err -> Void in
            
            // We got data or an error. Act accordingly
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            if data != nil
            {
                do
                {
                    let responseObject = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : AnyObject]
                    successBlock(responseObject)
                }
                catch let error as NSError
                {
                    print("error: \(error.localizedDescription)")
                    failureBlock(error)
                }
            }
            else
            {
                failureBlock(nil)
            }
        })
        
        task.resume()
    }
    
    //MARK: Network Connectivity
    
    /// Start monitoring for internet connection
    func startMonitoring()
    {
        AFNetworkReachabilityManager.shared().startMonitoring()
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange
        { status in
            
            // We need to inform about connectivity change. Activate networkStatusBlock
            self.networkStatusBlock!(status)
        }
    }
    
    func networkConnectionHasChanged(statusBlock: @escaping (AFNetworkReachabilityStatus) -> ())
    {
        // Save the new block and activate it when needed.
        networkStatusBlock = statusBlock
    }
}
