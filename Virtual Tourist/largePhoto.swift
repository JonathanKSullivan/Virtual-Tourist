//
//  largePhoto.swift
//  Virtual Tourist
//
//  Created by Jonathan K Sullivan  on 2/12/16.
//  Copyright © 2016 Jonathan K Sullivan . All rights reserved.
//

import Foundation
import UIKit
import MapKit

class largePhoto: UIViewController {
    var photoArray: [String]!
    var photoPage: [String]!
    var index:Int!
    var chosenRegion: MKCoordinateRegion!
    var chosenAnnotation: photoMapAnnotation!
    var mapRect: MKMapRect!

    @IBOutlet weak var photo: UIImageView!
    var phototoLoad: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        photo.image = phototoLoad.image
    }
}