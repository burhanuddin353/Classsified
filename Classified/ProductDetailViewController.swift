//
//  ViewController.swift
//  Classified
//
//  Created by Burhanuddin Sunelwala on 25/12/20.
//

import UIKit
import AlamofireImage
import MBProgressHUD

class ProductDetailViewController: UIViewController {

    private var photoView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var contentView: UIView!
    var scrollView: UIScrollView?
    var product: Product?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let product = product else { return }

        photoView = UIImageView()
        MBProgressHUD.showAdded(to: view, animated: true)
        photoView.af_setImage(withURL: product.imageUrls.first!, completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            MBProgressHUD.hide(for: strongSelf.view, animated: true)
            strongSelf.configureAndAddScrollView()
        })
        nameLabel.text = product.name
        priceLabel.text = product.price
    }

    private func configureAndAddScrollView() {

        scrollView = UIScrollView(frame: contentView.bounds)
        scrollView!.minimumZoomScale = 0.1
        scrollView!.maximumZoomScale = 4.0
        scrollView!.zoomScale = 1
        scrollView!.delegate = self
        contentView.addSubview(scrollView!)
        if let productImage = photoView.image {
            photoView = UIImageView(image: productImage)
            photoView!.frame = scrollView!.bounds
            photoView!.contentMode = .scaleAspectFit
            scrollView!.addSubview(photoView!)
        }
    }
}

extension ProductDetailViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        photoView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale < 1 {
            scrollView.zoomScale = 1
        }
    }
}


