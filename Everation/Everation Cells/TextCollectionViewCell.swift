//
//  TextCollectionViewCell.swift
//  Everation
//
//  Created by Ignacio Nieto Carvajal on 23/07/2017.
//  Copyright © 2017 Digital Leaves. All rights reserved.
//

import UIKit

class TextCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureWithText(_ text: String) {
        textLabel.text = text
    }
}
