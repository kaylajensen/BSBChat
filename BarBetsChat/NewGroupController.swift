//
//  NewMessageController.swift
//  BarBetsChat
//
//  Created by Kayla Kerney on 7/19/16.
//  Copyright © 2016 Kayla Kerney. All rights reserved.
//

import UIKit
import Firebase


class NewGroupController: UITableViewController {
    
    let cellId = "cellId"
    
    var messagesController: MessagesViewController?
    
    lazy var addRmButton: UIButton = {
        let button = UIButton(type: .System)
        button.setTitle("Add", forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFontOfSize(10)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(setAddRemoveButton), forControlEvents: .TouchUpInside)
        return button
    }()
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(handleCancel))
        
        self.view.addSubview(addRmButton)
        
        
        addRmButton.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
        addRmButton.topAnchor.constraintEqualToAnchor(self.view.topAnchor, constant: 28).active = true
        addRmButton.widthAnchor.constraintEqualToConstant(20).active = true
        addRmButton.heightAnchor.constraintEqualToConstant(20).active = true
        
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
    }
    
    func handleCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        return cell
    }
    
    func setAddRemoveButton() {
        
    }
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.id = snapshot.key
                self.users.append(user)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
            }, withCancelBlock: nil)
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        dismissViewControllerAnimated(true) {
//            print("dismiss completed")
//            let user = self.users[indexPath.row]
//            self.messagesController?.showChatControllerForUser(user)
//            
//        }
//    }
    
}

