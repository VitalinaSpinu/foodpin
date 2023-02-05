//
//  RestaurantDiffableDataSource.swift
//  FoodPin
//
//  Created by Vitalina Spinu on 04.11.2022.
//

import UIKit

enum Section {
    case all
}

class RestaurantDiffableDataSource: UITableViewDiffableDataSource<Section, Restaurant> {

    override func tableView(_ tableView: UITableView, canEditRowAt
                            indePath: IndexPath) -> Bool {
        return true
    }
    
    
}
