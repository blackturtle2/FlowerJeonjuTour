//
//  MyBadgeCollectionViewCell.swift
//  FlowerJeonjuTrip
//
//  Created by leejaesung on 2017. 11. 16..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit

class MyBadgeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewMain: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageViewMainCover: UIImageView!
    
    var sid: String?
    var sTitle: String?
    var fileUrl: String?
    
}
