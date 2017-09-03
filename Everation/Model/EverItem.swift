//
//  EverItem.swift
//  Everation
//
//  Created by Ignacio Nieto Carvajal on 23/07/2017.
//  Copyright © 2017 Digital Leaves. All rights reserved.
//

import UIKit

enum EverItem {
    case text(content: String)
    case image(content: UIImage)
}

func arrayOfSampleItems() -> [EverItem] {
    return [
        .text(content: "Donec id elit non mi porta gravida at eget metus."),
        .image(content: UIImage(named: "image1")!),
        .text(content: "Nullam quis risus eget urna mollis ornare vel eu leo. Morbi leo risus, porta ac consectetur ac, vestibulum at eros."),
        .text(content: "Aenean lacinia bibendum nulla sed consectetur."),
        .image(content: UIImage(named: "image2")!),
        .text(content: "Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."),
        .text(content: "Curabitur blandit tempus porttitor. Maecenas sed diam eget risus varius blandit."),
        .image(content: UIImage(named: "image3")!),
        .text(content: "Morbi leo risus, porta ac consectetur ac, vestibulum at eros."),
    ]
}
