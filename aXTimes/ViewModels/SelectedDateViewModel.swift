//
//  SelectedDateViewModel.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 17.10.17.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

protocol SelectedDateViewModelProtocol: NSObjectProtocol {
    var currentlySelectedDate: Date { get set }
}

class SelectedDateViewModel: NSObject, SelectedDateViewModelProtocol {
    @objc var currentlySelectedDate: Date

    @objc init(date: Date) {
        currentlySelectedDate = date
    }
}
