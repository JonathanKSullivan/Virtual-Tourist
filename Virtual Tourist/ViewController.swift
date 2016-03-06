//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Jonathan K Sullivan  on 2/9/16.
//  Copyright © 2016 Jonathan K Sullivan . All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let BASE_URL = "https://api.flickr.com/services/rest/"
    let METHOD_NAME = "flickr.photos.search"
    let API_KEY = "ce190e05b11ca689a9c1fac8c9de619d"
    let EXTRAS = "url_m"
    let SAFE_SEARCH = "1"
    let DATA_FORMAT = "json"
    let NO_JSON_CALLBACK = "1"
    let BOUNDING_BOX_HALF_WIDTH = 1.0
    let BOUNDING_BOX_HALF_HEIGHT = 1.0
    let LAT_MIN = -90.0
    let LAT_MAX = 90.0
    let LON_MIN = -180.0
    let LON_MAX = 180.0
    var loaded = false
    
    var savedMap: MapData!
    var addr1:String!
    var addr2:String!
    
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
    var photoArray:[String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let longPress = UILongPressGestureRecognizer(target: self, action: "action:")
        longPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPress)
        mapView.delegate = self
        
        fetchedResultsController.delegate = self
        
    }
        // Step 9: set the fetchedResultsController.delegate = self
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if true{
            do {
                try fetchedResultsController.performFetch()
                if let fetched = fetchedResultsController.fetchedObjects as? [MapData]{
                    performUIUpdatesOnMain({ () -> Void in
                        if fetched.count != 0{
                            self.mapView.region.center.latitude = (fetched.last?.centerLatitude)!
                            print(fetched.last!)
                            self.mapView.region.center.longitude = (fetched.last?.centerLongitude)!
                            self.mapView.region.span.latitudeDelta = (fetched.last?.deltaLatitude)!
                            self.mapView.region.span.longitudeDelta = (fetched.last?.deltaLongitude)!
                        }
                    })
                }
            }
            catch {
                print("hi")
            }
        }
        
    }
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // Step 1 - Add the lazy fetchedResultsController property. See the reference sheet in the lesson if you
    // want additional help creating this property.
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "MapData")
        
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "centerLatitude", ascending: true)]
        

        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    lazy var fetchedResultsController1: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "PhotoAlbumData")
        
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "centerLatitude", ascending: true)]
        
        
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered fullyRendered: Bool){
        loaded = true
    }
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        if loaded{
            savedMap = MapData(mapView: mapView, context: sharedContext)
            CoreDataStackManager.sharedInstance().saveContext()
        }

    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            //pinView!.rightCalloutAccessoryView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "loadUrl:"))
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl){
        let DetailController = self.storyboard!.instantiateViewControllerWithIdentifier("albumViewController") as! albumViewController
        let detailNavigationController = UINavigationController()
        detailNavigationController.pushViewController(DetailController, animated: false)
        
        do {
            try self.fetchedResultsController1.performFetch()
            if let fetched = self.fetchedResultsController1.fetchedObjects as? [PhotoAlbumData]{
                if fetched.count != 0{
                    for data in fetched{
                        if(view.annotation?.coordinate.latitude == data.centerLatitude && view.annotation?.coordinate.longitude == data.centerLongitude){
                            DetailController.photoArray = data.photoArray
                            DetailController.photoPage = data.photoPage
                            DetailController.index = Int(data.index)
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                self.navigationController!.pushViewController(DetailController, animated: true)
                            })

                           
                        }
                    }
                    if DetailController.photoArray == nil{
                        self.getImageFromFlickr(view.annotation!.coordinate.latitude, longitude: view.annotation!.coordinate.longitude){
                            DetailController.photoArray = self.photoArray
                            DetailController.index = 0
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                self.navigationController!.pushViewController(DetailController, animated: true)
                            })

                            
                        }
                    }
                }
                else{
                    self.getImageFromFlickr(view.annotation!.coordinate.latitude, longitude: view.annotation!.coordinate.longitude){
                        DetailController.photoArray = self.photoArray
                        DetailController.index = 0
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            self.navigationController!.pushViewController(DetailController, animated: true)
                        })

                    
                    }
                }
            }
            DetailController.photoArray = self.photoArray
            DetailController.chosenRegion = self.mapView.region
            DetailController.chosenAnnotation = view.annotation as! photoMapAnnotation
            DetailController.mapRect = self.mapView.visibleMapRect
        }
        catch {
            print("Error")
        }
        
            }

    
    func action(gestureRecognizer:UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        let newCoord:CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: newCoord.latitude, longitude: newCoord.longitude), completionHandler: { (placemarks, error) -> Void in
            let placeMark = placemarks![0]
            if let address = (placeMark.addressDictionary!["FormattedAddressLines"]){
                self.addr1 = address[0] as? String
                self.addr2 = address[1] as? String
            }
            else{
                self.addr1 = "None"
                self.addr2 = "None"
            }
            let newAnotation = photoMapAnnotation(coordinate: newCoord, title: self.addr1, subtitle: self.addr2)
            performUIUpdatesOnMain(){
                self.mapView.addAnnotation(newAnotation)
            }
        })
        
        
    }
    
    func getImageFromFlickr(latitude: Double, longitude: Double, completionHandler:()->Void)->Void {
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "bbox": createBoundingBoxString(latitude, longitude: longitude),
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        getImageFromFlickrBySearch(methodArguments){
            completionHandler()
        }
        
    }
    func createBoundingBoxString(latitude: Double, longitude: Double) -> String {
        let latitude = latitude
        let longitude = longitude
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }

    func getImageFromFlickrBySearch(methodArguments: [String : AnyObject], completionHandler:()->Void)->Void {
        
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        self.photoArray = [String]()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                print("Could not complete the request \(error)")
            }
            else{
                let parsedResult: AnyObject!
                do{
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                }
                catch{
                    print("could not parse Json data")
                    return
                }
                if let photosDictionary = parsedResult.valueForKey("photos")! as? [String:AnyObject] {
                    //if let totalPages = photosDictionary["pages"] as? Int {
                        /* Flickr API - will only return up the 4000 images (100 per page * 40 page max) */
                        //let pageLimit = min(totalPages, 40)
                        //let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                        //self.getImageFromFlickrBySearchWithPage(methodArguments, pageNumber: randomPage)
                    for student in (photosDictionary["photo"]! as? [[String:AnyObject]])!{
                        self.photoArray.append(student["url_m"]! as! String)
                    }
                }
            }
            completionHandler()
        }
        task.resume()
    }
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    func saveMapRegion() {
        
        // Place the "center" and "span" of the map into a dictionary
        // The "span" is the width and height of the map in degrees.
        // It represents the zoom level of the map.
        
        let dictionary = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        
        // Archive the dictionary into the filePath
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


