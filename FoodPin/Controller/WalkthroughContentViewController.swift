//
//  WalkthroughContentViewController.swift
//  FoodPin
//
//  Created by Vitalina Spinu on 13.12.2022.
//

import UIKit

class WalkthroughContentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

            headingLabel.text = heading
            subHeadingLabel.text = subHeading
            contentImageView.image = UIImage(named: imageFile)
        
    }
    @IBOutlet var headingLabel: UILabel! {
        didSet {
            headingLabel.numberOfLines = 0
        }
    }
    @IBOutlet var subHeadingLabel: UILabel! {
        didSet {
            subHeadingLabel.numberOfLines = 0
        }
    }
    @IBOutlet var contentImageView: UIImageView!

    var index = 0
    var heading = ""
    var subHeading = ""
    var imageFile = ""

   }
