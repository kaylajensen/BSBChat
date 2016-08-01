//
//  NewMessageController.swift
//  BarBetsChat
//
//  Created by Kayla Kerney on 7/19/16.
//  Copyright © 2016 Kayla Kerney. All rights reserved.
//

import UIKit
import Firebase


class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    var currentAddUserIndex : String?
    var messagesController: MessagesViewController?
    
    var friendGroup = [User]()
    var users = [User]()
    var group : Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let backImage = UIImage(named: "back")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .Plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .Plain, target: self, action: #selector(handleCreateGroupWithUsers))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        let backgroundImage = UIImage(named: "woodpattern.jpg")
        let background = UIImageView(image: backgroundImage)
        background.contentMode = .ScaleToFill
        tableView.backgroundView = background
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = background.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        background.addSubview(blurEffectView)
        
        
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
    }
    
    
    func handleCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handleCreateGroupWithUsers() {
        print("made it to handle creating new group with new users method")
        
        //need to save array of friends here to firebase
        
        if friendGroup.count == 0 {
            return
        }
        
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Create Barstool Group",
                                            message: "Enter below",
                                            preferredStyle: .Alert)
        
        alertController!.addTextFieldWithConfigurationHandler(
            {(textField: UITextField!) in
                textField.placeholder = "Enter Group Name"
        })
        alertController!.addTextFieldWithConfigurationHandler(
            {(textField: UITextField!) in
                textField.placeholder = "Enter Group Description"
        })
        
        let action = UIAlertAction(title: "Submit",
                                   style: UIAlertActionStyle.Default,
                                   handler: {[weak self]
                                    (paramAction:UIAlertAction!) in
                                    if let textFields = alertController?.textFields{
                                        let theTextFields = textFields as [UITextField]
                                        let enteredText = theTextFields[0].text
                                        print(enteredText)
                                        let nextText = theTextFields[1].text
                                        print(nextText)
                                        //displayLabel.text = enteredText
                                        if enteredText == "" || nextText == "" {
                                            print("error need to enter fields")
                                        } else {
                                            self!.handleCreatingGroup(enteredText!,groupDescription: nextText!)
                                        }
                                    }
            })
        
        alertController?.addAction(action)
        self.presentViewController(alertController!,
                                   animated: true,
                                   completion: nil)
        
    }
    
    func handleCreatingGroup(groupName: String,groupDescription: String) {
        print(groupName)
        print(groupDescription)
        
        let ref = FIRDatabase.database().reference().child("groups")
        let childRef = ref.childByAutoId()
        let fromId = FIRAuth.auth()!.currentUser!.uid
        
        
        var friendIds = [String]()
        for f in 0...friendGroup.count-1 {
            friendIds.append(friendGroup[f].id!)
        }
        
        //add user who created the group
        friendIds.append(fromId)
        
        let values = ["name": groupName, "description": groupDescription, "createdBy": fromId, "members": friendIds, "numusers": friendGroup.count, "groupId": childRef.key]
        
        childRef.updateChildValues(values as [NSObject : AnyObject]) { (error,ref) in
            if error != nil {
                print(error)
                return
            }
            
            let userGroupRef = FIRDatabase.database().reference().child("users").child(fromId).child("groups")
            let groupId = childRef.key
            
            userGroupRef.updateChildValues([groupId: 1])
            
            for f in 0...self.friendGroup.count-1 {
                let id = self.friendGroup[f].id!
                let currentUserRef = FIRDatabase.database().reference().child("users").child(id).child("groups")
                let groupId = childRef.key
                currentUserRef.updateChildValues([groupId: 1])
                
            }
        }
        
        dismissViewControllerAnimated(true) {
            print("dismiss completed")
            
            
        }

        
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.backgroundColor = UIColor.clearColor()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! UserCell
    
        let user = users[indexPath.row]
    
        cell.textLabel?.text = user.name
        //cell.detailTextLabel?.text = user.email
        cell.group = group
        
        cell.detailTextLabel?.hidden = true
        cell.barstoolImage.hidden = true
        cell.addButton.tag = indexPath.row
        
        cell.addButton.addTarget(self, action: #selector(handleAddOrRemove), forControlEvents: .TouchUpInside)
        return cell
    }
    
    func handleAddOrRemove(sender: UIButton) {
        
        let index = sender.tag
        let user = users[index]
        
        if sender.titleLabel?.text == "+" {
            print("add me")
            friendGroup.append(user)
        } else {
            print("delete me")
            for friend in friendGroup {
                if friend == user {
                    friendGroup.removeAtIndex(friendGroup.indexOf(user)!)
                }
            }
        }

        if friendGroup.count != 0 {
            for friends in 0...friendGroup.count-1 {
                print(friendGroup[friends].name)
            }
        }
        
        
    }
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let currentUser = FIRAuth.auth()!.currentUser!.uid

            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                
                if currentUser != snapshot.key {
                    user.name = dictionary["name"] as? String
                    user.email = dictionary["email"] as? String
                    user.id = snapshot.key
                    self.users.append(user)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                     })
                }
               
            }
            }, withCancelBlock: nil)
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

}

