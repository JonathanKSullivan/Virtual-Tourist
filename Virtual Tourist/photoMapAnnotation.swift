//
//  photoMapAnnotation.swift
//  Virtual Tourist
//
//  Created by Jonathan K Sullivan  on 2/10/16.
//  Copyright © 2016 Jonathan K Sullivan . All rights reserved.
//


import Foundation
import UIKit
import MapKit

class photoMapAnnotation: NSObject, MKAnnotation, MKMapViewDelegate {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var photoArray: [String]!
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}