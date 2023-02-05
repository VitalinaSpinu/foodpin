//
//  NavigationControllerViewController.swift
//  FoodPin
//
//  Created by Vitalina Spinu on 15.11.2022.
//

import UIKit

class NavigationControllerViewController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
           return topViewController?.preferredStatusBarStyle ?? .default
       }
 
}
