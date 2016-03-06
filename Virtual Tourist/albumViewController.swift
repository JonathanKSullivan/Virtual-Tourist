//
//  albumViewController.swift
//  Virtual Tourist
//
//  Created by Jonathan K Sullivan  on 2/10/16.
//  Copyright © 2016 Jonathan K Sullivan . All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class albumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate{
    
    
    var map: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var albumCollectionView: UICollectionView!
    var photoArray: [String]!
    var photoPage: [String]!
    var index:Int!
    var chosenRegion: MKCoordinateRegion!
    var chosenAnnotation: photoMapAnnotation!
    var mapRect: MKMapRect!

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.editing = false
        self.navigationController?.toolbarHidden = true
        let longPress = UILongPressGestureRecognizer(target: self, action: "action:")
        longPress.minimumPressDuration = 1.0
        self.albumCollectionView.delegate = self
        self.albumCollectionView.dataSource = self
        if index == nil{
            index = 0
        }
        var albumDict = [String : String]()
        albumDict["index"] = String(format:"%f", self.index)
        albumDict["centerLatitude"] = String(format:"%f", self.chosenAnnotation.coordinate.latitude)
        albumDict["centerLongitude"] = String(format:"%f", self.chosenAnnotation.coordinate.longitude)
        
        photoPage = [String]()
        if photoArray.count != 0 {
            if  (photoArray.count-1) < (index!+1)*20{
                for i in index!*20...(photoArray.count-1){
                    photoPage.append(photoArray[i])
                }
            }
            else{
                for i in index!*20...(index!+1)*20{
                    photoPage.append(photoArray[i])
                }
            }
        }
        
        
        PhotoAlbumData(dict: albumDict, index: self.index, centerLatitude: self.chosenAnnotation.coordinate.latitude, centerLongitude: self.chosenAnnotation.coordinate.longitude, photoArray: photoArray, photoPage: photoPage, context: sharedContext)
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        func action(gestureRecognizer:UIGestureRecognizer) {
            let touchPoint = gestureRecognizer.locationInView(self.albumCollectionView)
            let indexPath: NSIndexPath! = self.albumCollectionView.indexPathForItemAtPoint(touchPoint)!
            if (indexPath == nil){
                print("couldn't find index path");
            } else {
                // get the cell at indexPath (the one you long pressed)
                let cell = self.albumCollectionView.cellForItemAtIndexPath(indexPath) as! collectionCellViewController
                self.albumCollectionView.deleteItemsAtIndexPaths([indexPath])
                self.albumCollectionView.reloadData()
                // do stuff with the cell
            }
            
        }
        performUIUpdatesOnMain(){
            self.map = MKMapView(frame: CGRectMake(0, (self.navigationController?.navigationBar.frame.height)!, self.view.frame.size.width, 100))
            self.map.setRegion(self.chosenRegion, animated: true)
            self.map.setVisibleMapRect(self.mapRect, animated: true)
            self.map.zoomEnabled = false
            self.map.scrollEnabled = false
            self.map.mapType = MKMapType.Standard
            self.map.userInteractionEnabled = false
            self.map.region.span.longitudeDelta  = 0.005;
            self.map.region.span.latitudeDelta  = 0.01;
            self.map.addAnnotation(self.chosenAnnotation)
            
            self.view.addSubview(self.map)
        }
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.photoPage.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CustomImageCell", forIndexPath: indexPath) as! collectionCellViewController
        cell.layer.shouldRasterize = true;
        cell.layer.rasterizationScale = UIScreen().scale;
        let url = NSURL(string: photoPage[indexPath.item])
        
       
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            
            let request = NSURLRequest(URL: url!)
            weak var weakSelf = self;
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: { (response, data, connectionError) -> Void in
                if ((connectionError) != nil){
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        NSLog("Error Occurred", connectionError!.localizedDescription)
                        //weakSelf.loadingIndicator(stopAnimating)
                    })
                }
                else{
                    let image = UIImage(data: data!)
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        //weakSelf.loadingIndicator(stopAnimating)
                        cell.touristImage.image = image
                        cell.touristImage.contentMode = .ScaleAspectFit
                    })

                }
            })
        })
    
        return cell
    
    }
    func collectionView(collectionView: UICollectionView,didSelectItemAtIndexPath indexPath: NSIndexPath){
        self.photoPage.removeAtIndex(indexPath.item)
        self.albumCollectionView.reloadData()
        //let newcontroller = self.storyboard!.instantiateViewControllerWithIdentifier("largePhoto") as! largePhoto
        //let cell = collectionView.cellForItemAtIndexPath(indexPath) as! collectionCellViewController
        //newcontroller.phototoLoad = cell.touristImage
        //self.navigationController!.pushViewController(newcontroller, animated: true)
    }
    
    @IBAction func getNewPhotos(sender: UIButton) {
        self.index!++
        photoPage = [String]()
        if  (photoArray.count-1) < (index!+1)*20{
            for i in index!*20...(photoArray.count-1){
                photoPage.append(photoArray[i])
            }
            self.index = 0
        }
        else{
            for i in index!*20...(index!+1)*20{
            photoPage.append(photoArray[i])
        }

        }
                var albumDict = [String : AnyObject]()
        albumDict["centerLatitude"] = self.chosenAnnotation.coordinate.latitude
        albumDict["centerLongitude"] = self.chosenAnnotation.coordinate.longitude
        PhotoAlbumData(dict: albumDict, index: self.index, centerLatitude: self.chosenAnnotation.coordinate.latitude, centerLongitude:self.chosenAnnotation.coordinate.longitude, photoArray: photoArray, photoPage: photoPage, context: sharedContext)
        albumCollectionView.reloadData()
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "MapData")
        
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "centerLatitude", ascending: true)]
        
        
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    
}