//
//  ClassifiedCell.swift
//  Classified
//
//  Created by Burhanuddin Sunelwala on 25/12/20.
//

import UIKit
import AlamofireImage

class ProductCell: UICollectionViewCell {

    @IBOutlet private weak var photoView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!

    var product: Product? {
        didSet {
            guard let product = product else { return }

            titleLabel.text = product.name
            priceLabel.text = product.price
            photoView.contentMode = .center
            if let url = product.imageUrlsThumbnails.first {
                photoView.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "Placeholder"), completion: {[weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.photoView.contentMode = .scaleAspectFill
                })
            }
        }
    }
}
