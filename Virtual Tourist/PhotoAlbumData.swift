//  MapData.swift
//  Virtual Tourist
//
//  Created by Jonathan K Sullivan  on 2/9/16.
//  Copyright © 2016 Jonathan K Sullivan . All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(PhotoAlbumData)

class PhotoAlbumData: NSManagedObject {
    //TODO: configure file to be stored in sqlite
    //TODO: add to core data model

    @NSManaged var index:Int64
    @NSManaged var centerLatitude:Double
    @NSManaged var centerLongitude:Double
    @NSManaged var photoArray: [String]!
    @NSManaged var photoPage: [String]!
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dict: [String: AnyObject], index:Int, centerLatitude:Double, centerLongitude:Double, photoArray: [String], photoPage: [String], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("PhotoAlbumData", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.index = Int64(index)
        self.centerLatitude = centerLatitude
        self.centerLongitude = centerLongitude
        self.photoArray = photoArray
        self.photoPage = photoPage

    }
}