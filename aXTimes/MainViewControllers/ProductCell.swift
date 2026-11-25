//
//  ProductCell.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 16.04.18.
//  Copyright © 2018 aXimilate. All rights reserved.
//

import UIKit
import StoreKit

final class ProductCell: UITableViewCell {
    
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        return formatter
    }()
    
    var buyButtonHandler: ((_ product: SKProduct) -> ())?
    
    var product: SKProduct? {
        didSet {
            guard let product = product else { return }
            
            textLabel?.text = product.localizedTitle
            
            if IAPProducts.store.isProductPurchased(product.productIdentifier) {
                accessoryType = .checkmark
                accessoryView = nil
                detailTextLabel?.text = ""
            } else if IAPHelper.canMakePayments() {
                ProductCell.priceFormatter.locale = product.priceLocale
                detailTextLabel?.text = ProductCell.priceFormatter.string(from: product.price)
                accessoryType = .none
                accessoryView = newBuyButton()
            } else {
                detailTextLabel?.text = LocalizationConstants.notAvailable
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textLabel?.adjustsFontForContentSizeCategory = true
        detailTextLabel?.adjustsFontForContentSizeCategory = true
        setupTextUI()
        
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(preferredContentSizeChanged(notification:)),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func preferredContentSizeChanged(notification: NSNotification) {
        setupTextUI()
    }
    
    private func setupTextUI() {
        textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .body)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = ""
        detailTextLabel?.text = ""
        accessoryView = nil
    }
    
    func newBuyButton() -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = ColorPalette.signature
        button.setTitle(LocalizationConstants.buy, for: .normal)
        button.addTarget(self, action: #selector(ProductCell.buyButtonTapped(_:)), for: .touchUpInside)
        button.sizeToFit()
        return button
    }
    
    @objc func buyButtonTapped(_ sender: AnyObject) {
        guard let product = product else { return }
        buyButtonHandler?(product)
    }
}
