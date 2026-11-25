//
//  IAPProducts.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 26.02.18.
//  Copyright © 2018 aXimilate. All rights reserved.
//

import Foundation

@objc final class IAPProducts: NSObject {
    @objc static let projects = "com.aximilate.axtimespro.projects"

    private static let productIdentifiers: Set<ProductIdentifier> = [IAPProducts.projects]

    @objc static let store = IAPHelper(productIds: IAPProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
