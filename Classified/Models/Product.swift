//
//  Product.swift
//  Classified
//
//  Created by Burhanuddin Sunelwala on 25/12/20.
//

import Foundation

class Product: Decodable {

    var uid: String
    var name: String
    var createdAt: Date
    var price: String
    var imageIds: [String]
    var imageUrls: [URL]
    var imageUrlsThumbnails: [URL]

    var priceDoubleValue: Double {
        let priceDoubleValue = price.components(separatedBy: CharacterSet.decimalDigits.inverted).joined() 
        return Double(priceDoubleValue) ?? 0.0
    }
}
