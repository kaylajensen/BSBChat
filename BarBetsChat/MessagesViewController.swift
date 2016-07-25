//
//  ViewController.swift
//  BarBetsChat
//
//  Created by Kayla Kerney on 7/19/16.
//  Copyright © 2016 Kayla Kerney. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UITableViewController {

    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoutImage = UIImage(named: "logout")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: logoutImage, style: .Plain, target: self, action: #selector(handleLogout))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.darkGrayColor()
        
        let image = UIImage(named: "beer")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .Plain, target: self, action: #selector(handleNewMessage))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.darkGrayColor()
        
        navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        
        checkIfUserIsLoggedIn()
        
        let backgroundImage = UIImage(named: "woodpattern.jpg")
        let background = UIImageView(image: backgroundImage)
        
        background.contentMode = .ScaleAspectFill
        tableView.backgroundView = background
        
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: cellId)
    }
    
    var messages = [Message]()
    var groups = [Group]()
    var messagesDictionary = [String: Message]()
    var clickedGroup: Group?
    
    
    
    func observeUsersGroups() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("users").child(uid).child("groups")
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let groupId = snapshot.key
            let groupRef = FIRDatabase.database().reference().child("groups").child(groupId)
            
            groupRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    let group = Group()
                    group.groupName = dictionary["name"] as? String
                    group.groupDescription = dictionary["description"] as? String
                    group.createdByUserId = dictionary["createdBy"] as? String
                    group.groupMemberIds = dictionary["members"] as? [String]
                    group.groupId = dictionary["groupId"] as? String
                    
                    self.groups.append(group)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
                
                
                }, withCancelBlock: nil)
            
            }, withCancelBlock: nil)
    }
    
    
//    func observeUserMessages() {
//        
//        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
//            return
//        }
//        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
//        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
//            
//            let messageId = snapshot.key
//            let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
//            
//            messageRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
//
//                if let dictionary = snapshot.value as? [String: AnyObject] {
//                    let message = Message()
//                    message.fromId = dictionary["fromId"] as? String
//                    message.text = dictionary["text"] as? String
//                    message.toId = dictionary["toId"] as? String
//                    message.timeStamp = dictionary["timestamp"] as? NSNumber
//                    
//                    // this groups the messages through a message dictionary
//                    if let toId = message.toId {
//                        self.messagesDictionary[toId] = message
//                        self.messages = Array(self.messagesDictionary.values)
//                        self.messages.sortInPlace({ (m1, m2) -> Bool in
//                            return m1.timeStamp?.intValue > m2.timeStamp?.intValue
//                        })
//                    }
//                    
//                    
//                    dispatch_async(dispatch_get_main_queue(), {
//                        self.tableView.reloadData()
//                    })
//                }
//                }, withCancelBlock: nil)
//            
//        }, withCancelBlock: nil)
//        
//    }
    
//    func observeMessages() {
//        let ref = FIRDatabase.database().reference().child("messages")
//        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
//            
//            if let dictionary = snapshot.value as? [String: AnyObject] {
//                let message = Message()
//                message.fromId = dictionary["fromId"] as? String
//                message.text = dictionary["text"] as? String
//                message.toId = dictionary["toId"] as? String
//                message.timeStamp = dictionary["timestamp"] as? NSNumber
//                
//                // this groups the messages through a message dictionary
//                if let toId = message.toId {
//                    self.messagesDictionary[toId] = message
//                    self.messages = Array(self.messagesDictionary.values)
//                    self.messages.sortInPlace({ (m1, m2) -> Bool in
//                        return m1.timeStamp?.intValue > m2.timeStamp?.intValue
//                    })
//                }
//                
//                dispatch_async(dispatch_get_main_queue(), {
//                    self.tableView.reloadData()
//                })
//            }
//            }, withCancelBlock: nil)
//    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.backgroundColor = UIColor.clearColor()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! UserCell
        
        
        let group = groups[indexPath.row]
        
        cell.textLabel?.text = group.groupName
        cell.detailTextLabel?.text = group.groupDescription
        cell.group = group
        
        cell.addButton.hidden = true
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
//        let userId = FIRAuth.auth()?.currentUser?.uid
//        
//        let user = User()
//        user.id = userId
//        
//        let index = groups[indexPath.row].groupId
//        let indexName = groups[indexPath.row].groupName
//        
//        print(index)
        print("\(groups[indexPath.row].groupName) selected")
        clickedGroup = groups[indexPath.row]
        showCircleController()
    }
    
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            performSelector(#selector(handleLogout), withObject: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            //for some reason uid is nil
            return
        }
        FIRDatabase.database().reference().child("users").child(uid).observeEventType(.Value, withBlock: {
            (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.navigationItem.title = (dictionary["name"] as? String)! + "'s Groups"
                if let name = self.navigationItem.title {
                    self.setUpNavBar(name)
                }
                
            }
            
            
            }, withCancelBlock: nil)
    }
    
    func setUpNavBar(name: String) {
        
        groups.removeAll()
        
        messages.removeAll()
        messagesDictionary.removeAll()
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
        
        tableView.reloadData()
        
        observeUsersGroups()
        //observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRectMake(0, 0, 100, 40)
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let image = UIImage(named: "smalllogo")
        let barBetsImageView = UIImageView(image: image)
        barBetsImageView.translatesAutoresizingMaskIntoConstraints = false
        barBetsImageView.contentMode = .ScaleAspectFill
        barBetsImageView.layer.cornerRadius = 5
        barBetsImageView.clipsToBounds = true
        containerView.addSubview(barBetsImageView)
        
        barBetsImageView.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        barBetsImageView.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        barBetsImageView.widthAnchor.constraintEqualToConstant(30).active = true
        barBetsImageView.heightAnchor.constraintEqualToConstant(30).active = true
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraintEqualToAnchor(barBetsImageView.rightAnchor, constant: 8).active = true
        nameLabel.centerYAnchor.constraintEqualToAnchor(barBetsImageView.centerYAnchor).active = true
        nameLabel.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        nameLabel.heightAnchor.constraintEqualToAnchor(barBetsImageView.heightAnchor).active = true
        
        containerView.centerXAnchor.constraintEqualToAnchor(titleView.centerXAnchor).active = true
        containerView.centerYAnchor.constraintEqualToAnchor(titleView.centerYAnchor).active = true
        
        self.navigationItem.titleView = titleView
        
        //titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(launchCircleView)))
        
        //titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        
    }
    
//    func launchCircleView() {
//        print("1")
//        let circleView = CollectionViewController(collectionViewLayout: CircularCollectionViewLayout())
//        
//        circleView.fetchUser()
//        let nav = UINavigationController(rootViewController: circleView)
//        presentViewController(nav, animated: true, completion: nil)
//        
//        
//    }
//    
//    func showChatControllerForUser(user: User) {
//        print("2")
//        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
//        chatLogController.user = user
//        navigationController?.pushViewController(chatLogController, animated: true)
//    }
    
    func showCircleController() {
        print("3")
        
        
        
        let circleView = CollectionViewController(collectionViewLayout: CircularCollectionViewLayout())
        circleView.messagesController = self
        
        circleView.group = clickedGroup
        
        
        circleView.fetchUser()
        
        let nav = UINavigationController(rootViewController: circleView)
        presentViewController(nav, animated: true, completion: nil)
    }
    
    func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginVC = LoginViewController()
        loginVC.messagesController = self
        presentViewController(loginVC, animated: true, completion: nil)
        
    }
    
    func handleNewMessage() {
        
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let nav = UINavigationController(rootViewController: newMessageController)
        presentViewController(nav, animated: true, completion: nil)
        
    }

}

