//
//  CollectionViewController.swift
//  CircularCollectionView
//
//  Created by Rounak Jain on 10/05/15.
//  Copyright (c) 2015 Rounak Jain. All rights reserved.
//

import UIKit
import Firebase

let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController {
    
    var group: Group?
    var user: User?
    var users = [User]()
    var messagesController: MessagesViewController?
    var circleView: CollectionViewController?
    var name: String?
    let logoView = UIImageView(image: UIImage(named: "barbetslogo.png"))
    let images: [String] = NSBundle.mainBundle().pathsForResourcesOfType("png", inDirectory: "Images")
    var selectedPlayer : String = ""
    
    
    lazy var groupButton: UIButton = {
        let button = UIButton(type: .System)
        button.backgroundColor = UIColor.blackColor()
        button.setTitle("Create Group Bet", forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFontOfSize(10)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(addGroupButton), forControlEvents: .TouchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationController?.navigationBarHidden = true
        
        let backImage = UIImage(named: "back")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .Plain, target: self, action: #selector(handleBack))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        //self.view.addSubview(groupButton)
        self.view.addSubview(logoView)
        
        
        
        
        
//        
//        groupButton.centerXAnchor.constraintEqualToAnchor(logoView.centerXAnchor).active = true
//        groupButton.centerYAnchor.constraintEqualToAnchor(self.view.centerYAnchor).active = true
//        groupButton.widthAnchor.constraintEqualToConstant(120).active = true
//        groupButton.heightAnchor.constraintEqualToConstant(40).active = true
        
        collectionView!.registerNib(UINib(nibName: "CircularCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        let imageView = UIImageView(image: UIImage(named: "woodpattern.jpg"))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        collectionView!.backgroundView = imageView
        
        logoView.frame = CGRectMake(self.view.bounds.size.width/15, self.view.bounds.size.height/8, 325, 110)
        
    }
    
    func addGroupButton() {
        
        
    }
    func handleBack() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension CollectionViewController
{
    
    override func collectionView(collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        
        if users.count == 0 {
            let userDummy = User()
            userDummy.name = "No members"
            users.append(userDummy)
            
            return 1
        }
        else {
            return users.count
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CircularCollectionViewCell
        let path = indexPath.row
        let user = users[path]
        cell.memberName = user.name!
        cell.imageName = images[0]
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        print("\(users[indexPath.row].name) was selected")
        
        let cameraVC = CameraViewController()
        cameraVC.messagesController = self.messagesController
        cameraVC.currentBettie = users[indexPath.row]
        cameraVC.currentGroupId = group?.groupId
        let nav = UINavigationController(rootViewController: cameraVC)
        presentViewController(nav, animated: true, completion: nil)
        
        
        //self.dismissViewControllerAnimated(true, completion: nil)
        
        
        
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
                        self.collectionView!.reloadData()
                    })
                }
                
                }, withCancelBlock: nil)
        }


    }
    
    
}
