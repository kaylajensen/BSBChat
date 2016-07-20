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
    
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(handleCancel))
        
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
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                //user.setValuesForKeysWithDictionary(dictionary)
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.id = snapshot.key
                
                
                self.users.append(user)
                
                //this will crash because of background thread, so lets use dispatch_async to fix
                //self.tableView.reloadData()
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
            }, withCancelBlock: nil)
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    var messagesController: MessagesViewController?
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dismissViewControllerAnimated(true) {
            print("dismiss completed")
            let user = self.users[indexPath.row]
            self.messagesController?.showChatControllerForUser(user)
            
        }
    }

}

