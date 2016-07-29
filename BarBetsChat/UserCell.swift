//
//  UserCell.swift
//  BarBetsChat
//
//  Created by Kayla Kerney on 7/20/16.
//  Copyright © 2016 Kayla Kerney. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var group: Group? {
        didSet {
            
            detailTextLabel?.textColor = UIColor.whiteColor()
            textLabel?.textColor = UIColor.whiteColor()
            textLabel?.font = UIFont.boldSystemFontOfSize(19)
            detailTextLabel?.font = UIFont.systemFontOfSize(15)
        }
    }
    
    
    let barstoolImage: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "whitebarrel")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .ScaleToFill
        return imageView
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton(type: .System)
        button.backgroundColor = UIColor.blackColor()
        button.setTitle("+", forState: .Normal)
        button.backgroundColor = UIColor.darkGrayColor()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFontOfSize(20)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(go), forControlEvents: .TouchUpInside)
        return button
    }()
    
    func go() {
        print("button tapped")
        
        if addButton.titleLabel?.text == "+" {
            addButton.setTitle("-", forState: .Normal)
            addButton.backgroundColor = UIColor.redColor()
        } else {
            addButton.setTitle("+", forState: .Normal)
            addButton.backgroundColor = UIColor.darkGrayColor()
        }
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(barstoolImage)
        addSubview(addButton)
        
        barstoolImage.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
        barstoolImage.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        barstoolImage.widthAnchor.constraintEqualToConstant(60).active = true
        barstoolImage.heightAnchor.constraintEqualToConstant(60).active = true

        
        addButton.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -15).active = true
        addButton.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 22).active = true
        addButton.widthAnchor.constraintEqualToConstant(30).active = true
        addButton.heightAnchor.constraintEqualToConstant(30).active = true
        

        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRectMake(56, textLabel!.frame.origin.y - 2, textLabel!.frame.width, textLabel!.frame.height)
        detailTextLabel?.frame = CGRectMake(56, detailTextLabel!.frame.origin.y + 2, detailTextLabel!.frame.width, detailTextLabel!.frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

