//
//  SearchSuggestionTableViewCell.swift
//  WhatGoesAround
//
//  Created by Oren Bachar on 24/02/2017.
//  Copyright © 2017 Oren Bachar. All rights reserved.
//

import UIKit

class SearchSuggestionTableViewCell: UITableViewCell
{
    //MARK: Outlets
    
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        placeNameLabel.text = ""
        placeAddressLabel.text = ""
    }
    
    //MARK: Initializations
    
    /// Initialize place cell with place model
    ///
    /// - Parameter placeModel: The model defining a place nearby
    func initializeCell(placeModel: PlaceModel) -> Void
    {
        placeNameLabel.text = placeModel.name
        placeAddressLabel.text = placeModel.address
    }
}
