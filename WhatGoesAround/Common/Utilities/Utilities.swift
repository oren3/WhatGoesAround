//
//  Utilities.swift
//  WhatGoesAround
//
//  Created by Oren Bachar on 24/02/2017.
//  Copyright © 2017 Oren Bachar. All rights reserved.
//

import UIKit

class Utilities: NSObject
{
    /// Get formated string from number - Will format number to distance in Km
    ///
    /// - Parameters:
    ///   - number: The selected number to format
    ///   - minFruction: Minimum digits after the dot
    ///   - maxFruction: Maximum digits after the dot
    /// - Returns: Return formaterd string to distance in Km
    static func getFormatedStringFromNumber(number: Float, minFruction: Int, maxFruction: Int) -> String
    {
        let numberFormatter: NumberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.minimumFractionDigits = minFruction
        numberFormatter.maximumFractionDigits = maxFruction
        
        return NSString.localizedStringWithFormat("%@ Km", numberFormatter.string(from: NSNumber.init(value: number))!) as String
    }
    
    /// Sort array according to a given descriptor
    ///
    /// - Parameters:
    ///   - arrayToSort: The array we want to sort according to some descriptor
    ///   - sortValue: The descriptor value
    /// - Returns: Sorted array
    static func getSortedArray(arrayToSort: NSArray, sortValue: String) -> NSArray
    {
        let sortDescriptor = NSSortDescriptor.init(key: sortValue, ascending: true)
        
        return arrayToSort.sortedArray(using: [ sortDescriptor ]) as NSArray
    }
}
