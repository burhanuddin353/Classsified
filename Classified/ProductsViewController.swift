//
//  ArticlesViewController.swift
//  Classified
//
//  Created by Burhanuddin Sunelwala on 25/12/20.
//

import UIKit
import MBProgressHUD

class ProductsViewController: UICollectionViewController {

    private let cellSpacing: CGFloat = 4
    private let lineSpacing: CGFloat = 4
    private let cellPadding: CGFloat = 12
    private let numberOfCellsInARow: CGFloat = 2
    private let cellHeight: CGFloat = 250

    private var products = [Product]()
    private var filteredProducts = [Product]()

    private var isSearchBarEmpty: Bool { searchController.searchBar.text?.isEmpty ?? true }
    private var isFiltering: Bool { searchController.isActive && !isSearchBarEmpty }

    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Products"
        searchController.searchBar.tintColor = #colorLiteral(red: 0.1568627451, green: 0.6941176471, blue: 0.4274509804, alpha: 1)
        navigationItem.searchController = searchController
        definesPresentationContext = true

        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(loadProducts), for: .valueChanged)

        loadProducts()
    }

    @objc private func loadProducts() {

        MBProgressHUD.showAdded(to: view, animated: true)
        Network.shared.getProducts { [weak self] result in
            guard let strongSelf = self else { return }
            MBProgressHUD.hide(for: strongSelf.view, animated: true)
            strongSelf.collectionView.refreshControl?.endRefreshing()

            result.ifSuccess {

                strongSelf.products = result.value!
                strongSelf.collectionView.reloadData()
            }

            result.ifFailure {

                let alert = UIAlertController(title: "Error", message: result.error!.localizedDescription, preferredStyle: .alert)
                strongSelf.present(alert, animated: true)
            }
        }
    }

    private func filterContentForSearchText(_ searchText: String) {

        filteredProducts = products.filter { product in

            let searchText = searchText.lowercased()
            return product.name.lowercased().contains(searchText)
        }

        collectionView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segue.identifier {
        case "segueToProductDetail":
            let detailViewController = segue.destination as! ProductDetailViewController
            guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return }

            detailViewController.product = products[indexPath.row]

        default: break
        }
    }
}

//MARK:- IBActions
extension ProductsViewController {

    @IBAction private func sortClicked(_ barButtonItem: UIBarButtonItem) {

        let actionSheet = UIAlertController(title: "Sort", message: "", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Price (Low-High)", style: .default, handler: { (action) in
            self.products.sort(by: { $0.priceDoubleValue < $1.priceDoubleValue })
            self.collectionView.reloadData()
        }))

        actionSheet.addAction(UIAlertAction(title: "Price (High-Low)", style: .default, handler: { (action) in
            self.products.sort(by: { $0.priceDoubleValue > $1.priceDoubleValue })
            self.collectionView.reloadData()
        }))

        actionSheet.addAction(UIAlertAction(title: "Name (A-Z)", style: .default, handler: { (action) in
            self.products.sort(by: { $0.name < $1.name })
            self.collectionView.reloadData()
        }))

        actionSheet.addAction(UIAlertAction(title: "Name (Z-A)", style: .default, handler: { (action) in
            self.products.sort(by: { $0.name > $1.name })
            self.collectionView.reloadData()
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(actionSheet, animated: true)
    }
}

//MARK:- CollectionView DataSource
extension ProductsViewController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        isFiltering ? filteredProducts.count : products.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        cell.product = isFiltering ? filteredProducts[indexPath.row] : products[indexPath.row]

        return cell
    }
}

extension ProductsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellWidth = collectionView.bounds.width-cellSpacing-(cellPadding*2)
        return CGSize(width: cellWidth/numberOfCellsInARow, height: cellHeight)
    }
}

extension ProductsViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {

        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}
