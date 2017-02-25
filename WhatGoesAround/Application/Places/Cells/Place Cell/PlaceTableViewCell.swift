//
//  PlaceTableViewCell.swift
//  WhatGoesAround
//
//  Created by Oren Bachar on 24/02/2017.
//  Copyright © 2017 Oren Bachar. All rights reserved.
//

import UIKit
import SDWebImage

class PlaceTableViewCell: UITableViewCell
{
    static let kImageMaxWidth: NSInteger = 50

    //MARK: Outlets
    @IBOutlet weak var placeIconimageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeDistanceLabel: UILabel!
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
        
        placeIconimageView.sd_setImage(with: nil)
        placeNameLabel.text = ""
        placeDistanceLabel.text = ""
        placeAddressLabel.text = ""
    }
    
    //MARK: Initializations
    
    /// Initialize cell with a given place model
    ///
    /// - Parameter placeModel: Selected place model
    public func initializeCell(placeModel: PlaceModel) -> Void
    {
        placeNameLabel.text = placeModel.name
        placeAddressLabel.text = placeModel.address
        
        // Show distance in Km
        placeDistanceLabel.text = Utilities.getFormatedStringFromNumber(number: Float((placeModel.distanceFromCurrentLocation/1000)), minFruction: 0, maxFruction: 1)
        
        // Download the place image here
        let maxHeightAndWidthString = NSString.localizedStringWithFormat("%ld", PlaceTableViewCell.kImageMaxWidth)
        let imageString: NSString = NSString.localizedStringWithFormat("%@/place/photo?maxwidth=%@&maxheight=%@&photoreference=%@&key=%@", GlobalConstants.kGooglePlacesApiBaseUrl, maxHeightAndWidthString, maxHeightAndWidthString, placeModel.imageReferenceString, GlobalConstants.kGooglePlacesServerApiKey)
        
        placeIconimageView.sd_setImage(with: URL.init(string: imageString as String), placeholderImage: UIImage.init(named:"location"))
    }

}
