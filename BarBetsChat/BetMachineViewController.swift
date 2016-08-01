//
//  ViewController.swift
//  Carousel
//
//  Created by Kayla Kerney on 8/1/16.
//  Copyright © 2016 Kayla Kerney. All rights reserved.
//

import UIKit
import Firebase

class BetMachineViewController: UIViewController, iCarouselDelegate, iCarouselDataSource {
    
    var messagesController: MessagesViewController?
    var group: Group?
    var user: User?
    var users = [User]()
    var circleView: CollectionViewController?
    var name: String?
    let logoView = UIImageView(image: UIImage(named: "bets"))
     var currentGroupId: String?
    
    var carouselViews: iCarousel = {
        let c = iCarousel()
        c.translatesAutoresizingMaskIntoConstraints = false
        return c
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        carouselViews.delegate = self
        carouselViews.dataSource = self
        
        view.addSubview(carouselViews)
        
        setupConstraints()
        
        carouselViews.type = .InvertedTimeMachine
        
        let backImage = UIImage(named: "back")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .Plain, target: self, action: #selector(handleBack))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "woodpattern.jpg")
        backgroundImage.contentMode = .ScaleToFill
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundImage.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        backgroundImage.addSubview(blurEffectView)
        self.view.insertSubview(backgroundImage, atIndex: 0)
        
    }
    
    func handleBack() {
        print("back pressed")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func buttonPressed() {
        print("button pressed")
    }
    
    func setupConstraints() {
        
        carouselViews.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        carouselViews.heightAnchor.constraintEqualToAnchor(view.heightAnchor).active = true
        carouselViews.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: 26).active = true
        carouselViews.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    }
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return 50
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        
        let tempView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
        tempView.backgroundColor = UIColor.clearColor()
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = tempView.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        tempView.addSubview(blurEffectView)
        
        return tempView
        
    }
    
    
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == iCarouselOption.Spacing {
            return value/1.4
        }
        if option == iCarouselOption.Radius {
            //print(value)
            return value * 1.4
        }
        
        
        return value
    }
    
    func carousel(carousel: iCarousel, didSelectItemAtIndex index: Int) {
        print("selected: \(index)")
    }
    
    func fetchUser() {
        
        let groupMembers = group?.groupMemberIds
        
        for member in 0...groupMembers!.count-1 {
            print(groupMembers![member])
            let m = groupMembers![member]
            
            let ref = FIRDatabase.database().reference().child("users").child(m)
            ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let user = User()
                    user.name = dictionary["name"] as? String
                    user.id = dictionary["id"] as? String
                    user.email = dictionary["email"] as? String
                    
                    self.users.append(user)
                    dispatch_async(dispatch_get_main_queue(), {
                        //self.collectionView!.reloadData()
                        self.carouselViews.reloadData()
                    })
                }
                
                }, withCancelBlock: nil)
        }
        
    }
}


