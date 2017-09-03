//
//  ImageCollectionViewCell.swift
//  Everation
//
//  Created by Ignacio Nieto Carvajal on 23/07/2017.
//  Copyright © 2017 Digital Leaves. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureWithImage(_ image: UIImage) {
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
    }
}
