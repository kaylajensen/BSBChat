//
//  ViewController.swift
//  Carousel
//
//  Created by Kayla Kerney on 8/1/16.
//  Copyright © 2016 Kayla Kerney. All rights reserved.
//

import UIKit
import Firebase

class GroupCarouselViewController: UIViewController, iCarouselDelegate, iCarouselDataSource {
    
    var messagesController: MessagesViewController?
    var group: Group?
    var user: User?
    var users = [User]()
    var circleView: CollectionViewController?
    var name: String?
    let logoView = UIImageView(image: UIImage(named: "bets"))
    
    var carouselViews: iCarousel = {
        let c = iCarousel()
        c.translatesAutoresizingMaskIntoConstraints = false
        return c
    }()
    
    lazy var myButton : UIButton = {
        let button = UIButton()
        button.setTitle("Bet Machine", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.addTarget(self, action: #selector(betButtonPressed), forControlEvents: .TouchUpInside)
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 2.0
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        carouselViews.delegate = self
        carouselViews.dataSource = self
        
        view.addSubview(carouselViews)
        view.addSubview(myButton)
        
        setupConstraints()
        
        carouselViews.type = .Cylinder
        
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
        logoView.frame = CGRectMake(90, 40, 210, 95)
        view.addSubview(logoView)
    }
    
    func handleBack() {
        print("back pressed")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func betButtonPressed() {
        print("view bet machine pressed")
        
        let machineVC = BetMachineViewController()
        machineVC.messagesController = self.messagesController
        machineVC.currentGroupId = group?.groupId
        let nav = UINavigationController(rootViewController: machineVC)
        presentViewController(nav, animated: true, completion: nil)
        
    }
    
    func setupConstraints() {
        
        carouselViews.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        carouselViews.heightAnchor.constraintEqualToAnchor(view.heightAnchor).active = true
        carouselViews.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: 26).active = true
        carouselViews.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        
        myButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -40).active = true
        myButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        myButton.heightAnchor.constraintEqualToConstant(60).active = true
        myButton.widthAnchor.constraintEqualToConstant(120).active = true
    }

    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return users.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        let tempView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 325))
        tempView.backgroundColor = UIColor.clearColor()
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = tempView.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        tempView.addSubview(blurEffectView)
        
        let barImage = UIImageView(image: UIImage(named: "barstoolbsb"))
        barImage.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = users[index].name
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        tempView.addSubview(nameLabel)
        tempView.addSubview(barImage)
        
        nameLabel.topAnchor.constraintEqualToAnchor(tempView.topAnchor, constant: 10).active = true
        nameLabel.widthAnchor.constraintEqualToAnchor(tempView.widthAnchor).active = true
        nameLabel.centerXAnchor.constraintEqualToAnchor(tempView.centerXAnchor, constant: 40).active = true
        
        barImage.topAnchor.constraintEqualToAnchor(nameLabel.topAnchor).active = true
        barImage.widthAnchor.constraintEqualToAnchor(tempView.widthAnchor).active = true
        barImage.centerXAnchor.constraintEqualToAnchor(tempView.centerXAnchor).active = true
        barImage.bottomAnchor.constraintEqualToAnchor(tempView.bottomAnchor).active = true
        
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
        let cameraVC = CameraViewController()
        cameraVC.messagesController = self.messagesController
        cameraVC.currentBettie = users[index]
        cameraVC.currentGroupId = group?.groupId
        let nav = UINavigationController(rootViewController: cameraVC)
        presentViewController(nav, animated: true, completion: nil)

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


