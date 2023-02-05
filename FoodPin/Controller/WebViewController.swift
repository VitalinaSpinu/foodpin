//
//  WebViewController.swift
//  FoodPin
//
//  Created by Vitalina Spinu on 19.12.2022.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    @IBOutlet var webView: WKWebView!

    var targetURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: targetURL) {
                let request = URLRequest(url: url)
                webView.load(request)
            }
    }

}
