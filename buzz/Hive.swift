//
//  Hive.swift
//  buzz
//
//  Created by Boris Teodorovich on 12/1/18.
//  Copyright © 2018 Boris Teodorovich. All rights reserved.
//

import Foundation
import MapKit

class Hive: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    var name: String
    var courseID: String
    var queenID: String
    var queenName: String
    var id: String
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, name: String, courseID: String, queenID: String, queenName: String, members: Int, id: String) {
        self.coordinate = coordinate
        self.name = name
        self.courseID = courseID
        self.title = name
        self.subtitle = "Size: " + String(members)
        self.queenID = queenID
        self.queenName = queenName
        self.id = id
    }
    
}
