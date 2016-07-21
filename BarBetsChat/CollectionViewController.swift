//
//  CollectionViewController.swift
//  CircularCollectionView
//
//  Created by Rounak Jain on 10/05/15.
//  Copyright (c) 2015 Rounak Jain. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController {
    
    //var hardMoveVC : HardcodeMove?
    var circleView: CollectionViewController?
    var name: String?
  
  let images: [String] = NSBundle.mainBundle().pathsForResourcesOfType("png", inDirectory: "Images")
  var selectedPlayer : String = ""
  let names: [String] = ["Kayla","Corbin","Eric","Allison","Mattie","Bryce","Kenzie","Storto","Sarah","Phil","Ally","Michael"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBarHidden = true

    collectionView!.registerNib(UINib(nibName: "CircularCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    
    let imageView = UIImageView(image: UIImage(named: "wood-pattern.jpg"))
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    collectionView!.backgroundView = imageView
    
    let logoView = UIImageView(image: UIImage(named: "barbetslogo.png"))
    logoView.frame = CGRectMake(self.view.bounds.size.width/15, self.view.bounds.size.height/10, 325, 110)
    
    
    self.view.addSubview(logoView)
  }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
  
}

extension CollectionViewController //Swift 2 did not like this= : UICollectionViewDataSource
{
  
  // MARK: UICollectionViewDataSource
  
  override func collectionView(collectionView: UICollectionView,
    numberOfItemsInSection section: Int) -> Int {
      return images.count
  }
  
  override func collectionView(collectionView: UICollectionView,
    cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CircularCollectionViewCell
    
      cell.imageName = images[indexPath.row]
      print("\(names[indexPath.row])")
      cell.memberName = names[indexPath.row]
    
      return cell
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    print("\(names[indexPath.row]) was selected")
    selectedPlayer = names[indexPath.row]
    
    self.dismissViewControllerAnimated(true, completion: nil)
    
  }
  
}
