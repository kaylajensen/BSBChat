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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(handleLogout))
        let image = UIImage(named: "Message-50")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .Plain, target: self, action: #selector(handleNewMessage))
        checkIfUserIsLoggedIn()
        
        
        
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: cellId)
    }
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    func observeUserMessages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let messageId = snapshot.key
            let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
            
            messageRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in

                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message()
                    message.fromId = dictionary["fromId"] as? String
                    message.text = dictionary["text"] as? String
                    message.toId = dictionary["toId"] as? String
                    message.timeStamp = dictionary["timestamp"] as? NSNumber
                    //self.messages.append(message)
                    
                    // this groups the messages through a message dictionary
                    if let toId = message.toId {
                        self.messagesDictionary[toId] = message
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sortInPlace({ (m1, m2) -> Bool in
                            return m1.timeStamp?.intValue > m2.timeStamp?.intValue
                        })
                    }
                    
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                }
                }, withCancelBlock: nil)
            
        }, withCancelBlock: nil)
        
        
        
    }
    
    func observeMessages() {
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message()
                message.fromId = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.toId = dictionary["toId"] as? String
                message.timeStamp = dictionary["timestamp"] as? NSNumber
                //self.messages.append(message)
                
                // this groups the messages through a message dictionary
                if let toId = message.toId {
                    self.messagesDictionary[toId] = message
                    self.messages = Array(self.messagesDictionary.values)
                    self.messages.sortInPlace({ (m1, m2) -> Bool in
                        return m1.timeStamp?.intValue > m2.timeStamp?.intValue
                    })
                }
                
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
            }, withCancelBlock: nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
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
                self.navigationItem.title = dictionary["name"] as? String
                if let name = self.navigationItem.title {
                    self.setUpNavBar(name)
                }
                
            }
            
            
            }, withCancelBlock: nil)
    }
    
    func setUpNavBar(name: String) {
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRectMake(0, 0, 100, 40)
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        
        
        let image = UIImage(named: "smalllogo")
        let barBetsImageView = UIImageView(image: image)
        barBetsImageView.translatesAutoresizingMaskIntoConstraints = false
        barBetsImageView.contentMode = .ScaleAspectFill
        barBetsImageView.layer.cornerRadius = 20
        barBetsImageView.clipsToBounds = true
        containerView.addSubview(barBetsImageView)
        
        barBetsImageView.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        barBetsImageView.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        barBetsImageView.widthAnchor.constraintEqualToConstant(40).active = true
        barBetsImageView.heightAnchor.constraintEqualToConstant(40).active = true
        
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
        
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(launchCircleView)))
        
        //titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        
    }
    
    func launchCircleView() {
        print("circle view made it ")
        
        let circleView = CollectionViewController(collectionViewLayout: CircularCollectionViewLayout())
        
        //navigationController?.pushViewController(circleView, animated: true)
        
        //let c = NewMessageController()
        
        //circleView.circleView = circleView
        circleView.fetchUser()
        let nav = UINavigationController(rootViewController: circleView)
        presentViewController(nav, animated: true, completion: nil)
        
        
    }
    
    func showChatControllerForUser(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
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

