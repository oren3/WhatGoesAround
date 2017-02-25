//
//  SearchPlacesViewController.swift
//  WhatGoesAround
//
//  Created by Oren Bachar on 24/02/2017.
//  Copyright © 2017 Oren Bachar. All rights reserved.
//

import UIKit

protocol SearchPlacesViewControllerDelegate
{
    func userPickedSearchPlace(placeModel: PlaceModel)
}

class SearchPlacesViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource
{
    // MARK: Static Properties
    
    static let kSearchSuggestringCellIdentifier: String = "SearchSuggestionTableViewCellIdentifier"
    
    // MARK: Outlets
    
    @IBOutlet weak var searchActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchPlacesTableView: UITableView!
    
    // MARK: Properties
    
    var placesSearchBar:UISearchBar = UISearchBar()
    var placesSearchArray: NSArray = NSArray()
    
    // MARK: Delegate
    
    var delegate: SearchPlacesViewControllerDelegate!

    //MARK: View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.initializeView()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        placesSearchBar.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Initializations
    
    func initializeView() -> Void
    {
        // MAke a search bar
        placesSearchBar = UISearchBar.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width - 70, height: 30))
        placesSearchBar.placeholder = "Search for places"
        placesSearchBar.delegate = self
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: placesSearchBar)
    }
    
    //MARK: Search Bar Delegate Methods
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        let fullSearchString = (searchBar.text as NSString?)?.replacingCharacters(in: range, with: text) ?? text
        
        // Call google for search places every time a user is typing (Google autocomplete)
        NetworkManager.sharedInstance.getGoogleSearchPlaces(input: fullSearchString, apiKey: GlobalConstants.kGooglePlacesServerApiKey, successBlock:
        { (resultsArray: NSArray?) in
            
            // We got places from autocomplete. Show it.
            self.placesSearchArray = resultsArray!
            
            DispatchQueue.main.async
            {
                self.searchPlacesTableView.reloadData()
            }
            
        })
        { (error: NSError?) in
            print(error ?? "")
        }
        
        return true
    }
    
    // MARK: Table View Delegate And Data Source Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return placesSearchArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let searchCell = tableView.dequeueReusableCell(withIdentifier: SearchPlacesViewController.kSearchSuggestringCellIdentifier, for: indexPath) as! SearchSuggestionTableViewCell
        
        // Initialize the cell based on a given place model from placesSearchArray.
        searchCell.initializeCell(placeModel: placesSearchArray.object(at: indexPath.row) as! PlaceModel)
        
        return searchCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // User clicked a place. Make a call for /geocode to get a coordinate from an address.
        searchActivityIndicator.isHidden = false
        searchActivityIndicator.startAnimating()
        searchActivityIndicator.hidesWhenStopped = true
        
        NetworkManager.sharedInstance.getCoordinateForPlace(placeModel: placesSearchArray.object(at: indexPath.row) as! PlaceModel, apiKey: GlobalConstants.kGooglePlacesServerApiKey, successBlock:
        { (placeModel :PlaceModel?) in
            
            /* Got the coordinate. Inform PlacesViewController with the new, searched by user, coordinate and move 
               to PlacesViewController 
             */
            if placeModel != nil
            {
                DispatchQueue.main.async
                {
                    self.searchActivityIndicator.stopAnimating()
                    self.delegate.userPickedSearchPlace(placeModel: placeModel!)
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        })
        {
        (error: NSError?) in
            
            // Show error alert here
            let errorAlertController: UIAlertController = UIAlertController.init(title: GlobalConstants.kAlertErrorTitle, message: GlobalConstants.kAlertErrorMessage, preferredStyle: .alert)
            errorAlertController.addAction(UIAlertAction.init(title: GlobalConstants.kAlertErrorOKButton, style: .cancel, handler: nil))
            
            DispatchQueue.main.async
            {
                self.searchActivityIndicator.stopAnimating()
                self.present(errorAlertController, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: User Action
    
    @IBAction func backBarButtonWasPressed(_ sender: Any)
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
