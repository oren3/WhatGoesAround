//
//  PlacesViewController.swift
//  WhatGoesAround
//
//  Created by Oren Bachar on 24/02/2017.
//  Copyright © 2017 Oren Bachar. All rights reserved.
//

import UIKit
import AFNetworking

class PlacesViewController: UIViewController, LocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, SearchPlacesViewControllerDelegate
{
    static let kMapDefaultZoomLevel: Float = 12.0
    static let kAnimationDurationDefault: Float = 0.3;
    static let kTableViewMaxSizeOffset: CGFloat = 50;
    static let kAnimationSpringBouncing: CGFloat = 0.7
    static let kSegShowSearchController: String = "segShowSearchController"
    static let kChangeTableSizeButtonSelectedTitle: String = "Move Down"
    static let kChangeTableSizeButtonNotSelectedTitle: String = "Move Up"
    
    //MARK: Outlets
    
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var placesTableView: UITableView!
    @IBOutlet weak var placesActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noResultsContainerView: UIView!
    @IBOutlet weak var changeTableSizeButton: UIButton!
    @IBOutlet weak var changeTableSizeContainerView: UIView!
    @IBOutlet weak var placesTableContainerHeightConstraint: NSLayoutConstraint!
    
    //MARK: Private Properties
    
    private var placesArray: NSArray = NSArray()
    private var markersArray: NSMutableArray = NSMutableArray()
    private var isFirstLoad: Bool = Bool()
    private var placesTableContainerNormalHeightConstraint: CGFloat = CGFloat()
    private var changeSizeButtonStartingConstraint: CGFloat = CGFloat()
    private var placesTableViewMaxHeight: CGFloat = CGFloat()
    
    //MARK: View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.initializeView()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Initializations
    
    private func initializeView() -> Void
    {
        isFirstLoad = true
        googleMapView.isMyLocationEnabled = true
        LocationManager.sharedInstance.delegate = self
        self.showNoResultsView(show: true)
        placesTableContainerNormalHeightConstraint = placesTableContainerHeightConstraint.constant
        
        // Set elements for change size button
        changeTableSizeContainerView.layer.borderColor = UIColor.white.cgColor
        changeTableSizeButton.titleLabel?.numberOfLines = 2
        changeTableSizeButton.titleLabel?.textAlignment = .center
        
        // Calculating here the table's max size
        placesTableViewMaxHeight = (self.view.frame.size.height/2 + PlacesViewController.kTableViewMaxSizeOffset)
    }
    
    //MARK: Public Methods
    
    public func searchPlacesNearbyCoordinate(coordinate: CLLocationCoordinate2D)
    {
        // New location has reached.
        self.placesActivityIndicator.startAnimating()
        self.placesActivityIndicator.isHidden = false
        
        // Focus the map into the selected coordinate
        self.focusMap(coordinate: coordinate, zoomLevel: PlacesViewController.kMapDefaultZoomLevel, animated: false)
        
        // Make a request for places nearby
        NetworkManager.sharedInstance.getNearbyPlaces(apiKey: GlobalConstants.kGooglePlacesServerApiKey, coordinates: coordinate, radiusString: "10000", successBlock: { (data: NSMutableArray?) in

            // Got the places. Sort array according to distance and Show it.
            self.placesArray = Utilities.getSortedArray(arrayToSort: data?.copy() as! NSArray, sortValue: "distanceFromCurrentLocation")
            
            DispatchQueue.main.async
            {
                self.placesActivityIndicator.stopAnimating()
                self.showNoResultsView(show: self.placesArray.count == 0)
                self.placesTableView.scrollRectToVisible(CGRect.init(x: 0, y: 0, width: 1, height: 1), animated: true)
                self.placesTableView.reloadData()
                
                // Show markers on map view
                self.showMarkers(placesArray: self.placesArray)
            }
            
        }, failureBlock: { (error: NSError?) in
            
            // Failed to get places nearby. We need to show "No Results"
            DispatchQueue.main.async
            {
                self.placesActivityIndicator.stopAnimating()
                self.showNoResultsView(show: self.placesArray.count == 0)
            }
            
            print(error?.description ?? "")
        })
    }
    
    public func shouldRefreshPlacesOnMap() -> Bool
    {
        return (self.placesArray.count == 0)
    }
    
    // MARK: Private Methods
    
    /// Focus camera with a given place and zoom level.
    ///
    /// - Parameters:
    ///   - coordinate: Coordinate to move camera to.
    ///   - zoomLevel: The require zoom level.
    private func focusMap(coordinate: CLLocationCoordinate2D, zoomLevel: Float, animated: Bool)
    {
        let cameraPosition: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: zoomLevel)
        
        if animated
        {
            googleMapView.animate(to: cameraPosition)
        }
        else
        {
            googleMapView.camera = cameraPosition
        }
    }
    
    /// Show no results view if we have not received places from google
    ///
    /// - Parameter show: Bool value to know if we have to show or not the "noResultsView"
    private func showNoResultsView(show: Bool) -> Void
    {
        var alpha: CGFloat = 1.0
        
        if show
        {
            alpha = 0.0
        }
        
        self.noResultsContainerView.alpha = alpha
        self.noResultsContainerView.isHidden = !show
        
        _ = [UIView.animate(withDuration: TimeInterval(PlacesViewController.kAnimationDurationDefault), animations:
            {
                if show
                {
                    self.noResultsContainerView.alpha = 1.0
                }
                else
                {
                    self.noResultsContainerView.alpha = 0.0
                }
            },
            completion: { (_: Bool) in
                
                if !show
                {
                 self.noResultsContainerView.isHidden = true
                }
            })]
    }
    
    
    /// Show markers on map from results
    ///
    /// - Parameter placesArray: Array contains placeModels
    private func showMarkers(placesArray: NSArray)
    {
        // First, clear alll annotations currently on map
        self.googleMapView.clear()
        self.markersArray.removeAllObjects()
        
        for placeModel in placesArray
        {
            let position = CLLocationCoordinate2D(latitude: (placeModel as! PlaceModel).coordinate.latitude, longitude: (placeModel as! PlaceModel).coordinate.longitude)
            let marker = GMSMarker(position: position)
            marker.title = (placeModel as! PlaceModel).name
        
            marker.map = googleMapView
            
            // Add marker to markers array
            self.markersArray.add(marker)
        }
    }
    
    // MARK Location Manager Delegate Methods
    
    func locationUpdated(newLocationCoordinate: CLLocationCoordinate2D)
    {
        if isFirstLoad
        {
            isFirstLoad = false
            
            self.searchPlacesNearbyCoordinate(coordinate: newLocationCoordinate)
        }
    }
    
    // MARK: Table view Delegate And Data Source Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return placesArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let placeCell = tableView.dequeueReusableCell(withIdentifier: "PlaceTableViewCellIdentifier", for: indexPath) as! PlaceTableViewCell
        
        // Initialize the cell with a given place model.
        placeCell.initializeCell(placeModel: self.placesArray.object(at: indexPath.row) as! PlaceModel)
        
        return placeCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // User selected a place. zoom to the selected coordinate and Show him the marker on map
        let placeModel: PlaceModel = self.placesArray.object(at: indexPath.row) as! PlaceModel
        self.focusMap(coordinate: placeModel.coordinate, zoomLevel: PlacesViewController.kMapDefaultZoomLevel, animated: true)
        
        // Select the requested marker
        let selectedMarker: GMSMarker = self.markersArray.object(at: indexPath.row) as! GMSMarker
        googleMapView.selectedMarker = selectedMarker
    }
    
    //MARK: Search Places Controller Delegate Methods
    
    func userPickedSearchPlace(placeModel: PlaceModel)
    {
        // Got a new place to show. inform location manager with the lastSearched coordinate.
        LocationManager.sharedInstance.lastSearchedCoordinate = placeModel.coordinate
        
        // Make a call to google nearby to show nearby places
        self.searchPlacesNearbyCoordinate(coordinate: placeModel.coordinate)
    }
    
    //MARK: User Action
    
    @IBAction func searchBarButtonWasPressed(_ sender: Any)
    {
        self.performSegue(withIdentifier: PlacesViewController.kSegShowSearchController, sender: nil)
    }
    
    @IBAction func changeTableSizeButtonWasPressed(_ sender: Any)
    {
        // Make the user change the table's size for more comfortable experience
        changeTableSizeButton.isSelected = !changeTableSizeButton.isSelected
        
        if changeTableSizeButton.isSelected
        {
            // We need to move up the table view
            placesTableContainerHeightConstraint.constant = placesTableViewMaxHeight
            changeTableSizeButton.setTitle(PlacesViewController.kChangeTableSizeButtonSelectedTitle, for: .normal)
        }
        else
        {
            // Bring table view down
            placesTableContainerHeightConstraint.constant = placesTableContainerNormalHeightConstraint
            changeTableSizeButton.setTitle(PlacesViewController.kChangeTableSizeButtonNotSelectedTitle, for: .normal)
        }
        
        // Animate the size changes for table view.
        UIView.animate(withDuration: TimeInterval(PlacesViewController.kAnimationDurationDefault), delay: 0.0, usingSpringWithDamping:PlacesViewController.kAnimationSpringBouncing, initialSpringVelocity: 0.0, options: UIViewAnimationOptions(), animations:
        {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func changeTableSizePanGestureDetected(_ sender: Any)
    {
        // Animate table's size according to user pan gesture
        let panGesture = sender as! UIPanGestureRecognizer
        
        if panGesture.state == UIGestureRecognizerState.began
        {
            // Get the start height of table when beginning
            changeSizeButtonStartingConstraint = placesTableContainerHeightConstraint.constant
        }
        
        // Starting constraint minus the new fingure y position
        var newConstraintSize: CGFloat = (changeSizeButtonStartingConstraint - panGesture.translation(in: self.view).y)
        
        // Make newConstant to be on max/min height in case it reached the limit
        if newConstraintSize > placesTableViewMaxHeight
        {
            newConstraintSize = placesTableViewMaxHeight
        }
        else if newConstraintSize < placesTableContainerNormalHeightConstraint
        {
            newConstraintSize = placesTableContainerNormalHeightConstraint
        }

        placesTableContainerHeightConstraint.constant = newConstraintSize
        
        if panGesture.state == UIGestureRecognizerState.ended
        {
            // We need to move up the table container
            changeTableSizeButton.isSelected = !(placesTableContainerHeightConstraint.constant > placesTableViewMaxHeight/1.5)
            self.changeTableSizeButtonWasPressed(changeTableSizeButton)
        }
        
        UIView.animate(withDuration: TimeInterval(PlacesViewController.kAnimationDurationDefault), delay: 0.0, usingSpringWithDamping: PlacesViewController.kAnimationSpringBouncing, initialSpringVelocity: 0.0, options: UIViewAnimationOptions(), animations:
        {
                self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == PlacesViewController.kSegShowSearchController
        {
            let searchPlacesController = segue.destination as! SearchPlacesViewController
            searchPlacesController.delegate = self
        }
    }    
}
