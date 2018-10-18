//
//  MagazineSecondCVCell.swift
//  Ppulma
//
//  Created by 강수진 on 2018. 10. 17..
//  Copyright © 2018년 강수진. All rights reserved.
//

import UIKit

class MagazineSecondCVCell: UICollectionViewCell {
    
    @IBOutlet weak var outerView: UIView!
    var myImgView = UIImageView()
    func configure(data : UIImage) {
        myImgView.image = data
    }

    override func awakeFromNib() {
        outerView.clipsToBounds = false
        outerView.layer.applySketchShadow(alpha : 0.16, x : 0, y : 2, blur : 6, spread : 2)
        outerView.backgroundColor = UIColor.clear
        myImgView.frame = outerView.bounds
        myImgView.clipsToBounds = true
        myImgView.layer.cornerRadius = 7
        outerView.addSubview(myImgView)
    }
}

