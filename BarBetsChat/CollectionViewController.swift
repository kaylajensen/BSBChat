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
    
    var users = [User]()
    var circleView: CollectionViewController?
    var name: String?
  
  let images: [String] = NSBundle.mainBundle().pathsForResourcesOfType("png", inDirectory: "Images")
  var selectedPlayer : String = ""
  let names: [String] = ["Kayla","Corbin","Eric","Allison","Mattie","Bryce","Kenzie","Storto","Sarah","Phil","Ally","Michael"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBarHidden = true
    
    //fetchUser()

    collectionView!.registerNib(UINib(nibName: "CircularCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    
    let imageView = UIImageView(image: UIImage(named: "woodpattern.jpg"))
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    collectionView!.backgroundView = imageView
    
    let logoView = UIImageView(image: UIImage(named: "barbetslogo.png"))
    logoView.frame = CGRectMake(self.view.bounds.size.width/15, self.view.bounds.size.height/10, 325, 110)
    
    
    self.view.addSubview(logoView)
  }
    
  
}

extension CollectionViewController //Swift 2 did not like this= : UICollectionViewDataSource
{
  
  override func collectionView(collectionView: UICollectionView,
    numberOfItemsInSection section: Int) -> Int {
    
    if users.count == 0 {
        return 1
    }
    else {
        return users.count
    }
  }
  
  override func collectionView(collectionView: UICollectionView,
    cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CircularCollectionViewCell
    

    let path = indexPath.row
    let user = users[path]
    cell.memberName = user.name!
    cell.imageName = images[indexPath.row]
    
      return cell
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    print("\(names[indexPath.row]) was selected")
    
    //selectedPlayer = names[indexPath.row]
    
    self.dismissViewControllerAnimated(true, completion: nil)
    
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
                
                print(user.name)
                
                dispatch_async(dispatch_get_main_queue(), {
                    // self.collectionView?.reloadData()
                    self.collectionView!.reloadData()
                })
            }
            }, withCancelBlock: nil)
    }

  
}
