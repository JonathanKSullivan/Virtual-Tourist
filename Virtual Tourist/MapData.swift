//
//  MapData.swift
//  Virtual Tourist
//
//  Created by Jonathan K Sullivan  on 2/9/16.
//  Copyright © 2016 Jonathan K Sullivan . All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(MapData)

class MapData : NSManagedObject {

    @NSManaged var centerLatitude:Double
    @NSManaged var centerLongitude:Double
    @NSManaged var deltaLatitude:Double
    @NSManaged var deltaLongitude:Double
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    init(mapView:MKMapView, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("MapData", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.centerLatitude = mapView.region.center.latitude
        self.centerLongitude = mapView.region.center.longitude
        self.deltaLatitude = mapView.region.span.latitudeDelta
        self.deltaLongitude = mapView.region.span.longitudeDelta
        
        

    }
}