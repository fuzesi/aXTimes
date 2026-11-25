//
//  ProductsViewController.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 26.02.18.
//  Copyright © 2018 aXimilate. All rights reserved.
//

import UIKit
import StoreKit

class ProductsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var products = [SKProduct]()

    private let cellIdentifier = String(describing: ProductCell.self)

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = LocalizationConstants.premiumFeatures

        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        for subview in [tableView, activityIndicator] as [UIView] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                subview.topAnchor.constraint(equalTo: view.topAnchor),
                subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                subview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ProductsViewController.reload), for: .valueChanged)
        tableView.refreshControl = refreshControl

        let restoreButton = UIBarButtonItem(title: LocalizationConstants.restore,
            style: .plain,
            target: self,
            action: #selector(ProductsViewController.restoreTapped(_:))
        )
        navigationItem.rightBarButtonItem = restoreButton

        NotificationCenter.default.addObserver(self, selector: #selector(ProductsViewController.handlePurchaseNotification(_:)),
            name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
            object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        reload()
        activityIndicator.startAnimating()
        super.viewWillAppear(animated)
    }

    @objc func reload() {
        products = []
        tableView.reloadData()
        IAPProducts.store.requestProducts { success, products in
            if success {
                if let products = products {
                    self.products = products
                }
                self.tableView.reloadData()
            }
            self.activityIndicator.stopAnimating()
            self.tableView.refreshControl?.endRefreshing()
        }
    }

    @objc func restoreTapped(_ sender: AnyObject) {
        IAPProducts.store.restorePurchases()
    }

    @objc func handlePurchaseNotification(_ notification: Notification) {
        guard let productID = notification.object as? String else { return }

        for (index, product) in products.enumerated() {
            guard product.productIdentifier == productID else { continue }

            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        }
    }
}

// MARK: - UITableViewDataSource

extension ProductsViewController {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ProductCell
        let product = products[indexPath.row]
        cell.product = product
        cell.selectionStyle = .none
        cell.buyButtonHandler = { product in
            IAPProducts.store.buyProduct(product)
        }

        return cell
    }
}
