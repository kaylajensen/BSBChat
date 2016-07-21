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
    
    var message: Message? {
        didSet {
           
            setupName()
            
            detailTextLabel?.text = message?.text
            
            if let seconds = message?.timeStamp?.doubleValue {
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.stringFromDate(timestampDate)
            }
            
        }
    }
    
    private func setupName() {
        let chatPartnerId: String?
        //checking if the person logged in was the person to send the message
        if message?.fromId == FIRAuth.auth()?.currentUser?.uid {
            chatPartnerId = message?.toId
        } else {
            chatPartnerId = message?.fromId
        }
        if let id = chatPartnerId {
            let ref = FIRDatabase.database().reference().child("users").child(id)
            ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                }
                }, withCancelBlock: nil)
        }
    }
    
    let barstoolImage: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "barstool")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 3
        imageView.layer.masksToBounds = true
        imageView.contentMode = .ScaleToFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        //label.text = "HH:MM:SS"
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor.lightGrayColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(barstoolImage)
        addSubview(timeLabel)
        
        barstoolImage.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 8).active = true
        barstoolImage.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        barstoolImage.widthAnchor.constraintEqualToConstant(48).active = true
        barstoolImage.heightAnchor.constraintEqualToConstant(48).active = true
        
        timeLabel.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        timeLabel.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 18).active = true
        timeLabel.widthAnchor.constraintEqualToConstant(100).active = true
        timeLabel.heightAnchor.constraintEqualToAnchor(textLabel?.heightAnchor).active = true
        
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

