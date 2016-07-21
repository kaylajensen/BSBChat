//
//  CircularCollectionViewCell.swift
//  CircularCollectionView
//
//  Created by Rounak Jain on 10/05/15.
//  Copyright (c) 2015 Rounak Jain. All rights reserved.
//

import UIKit

class CircularCollectionViewCell: UICollectionViewCell {
  
  var imageName = "" {
    didSet {
      imageView!.image = UIImage(named: imageName)
    }
  }
  var memberName = "" {
    didSet {
      memberLabel!.text = memberName
    }
  }
  
  @IBOutlet weak var imageView: UIImageView?
  @IBOutlet weak var memberLabel: UILabel?
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    contentView.layer.shouldRasterize = true
    contentView.layer.rasterizationScale = UIScreen.mainScreen().scale
    contentView.clipsToBounds = true
    
  }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        print("testing")
    }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    imageView!.contentMode = .ScaleAspectFill
  }
  
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
    super.applyLayoutAttributes(layoutAttributes)
    let circularlayoutAttributes = layoutAttributes as! CircularCollectionViewLayoutAttributes
    self.layer.anchorPoint = circularlayoutAttributes.anchorPoint
    self.center.y += (circularlayoutAttributes.anchorPoint.y - 0.5)*CGRectGetHeight(self.bounds)
  }
  
}
