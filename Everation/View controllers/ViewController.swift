//
//  ViewController.swift
//  Everation
//
//  Created by Ignacio Nieto Carvajal on 23/07/2017.
//  Copyright © 2017 Digital Leaves. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // data
    var everitems = [EverItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

