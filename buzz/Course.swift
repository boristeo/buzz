//
//  Course.swift
//  buzz
//
//  Created by Boris Teodorovich on 12/1/18.
//  Copyright © 2018 Boris Teodorovich. All rights reserved.
//

import Foundation
import MapKit

class Course {
    var name: String
    var id: String
    var description: String
    var hives: Int
    
    init(name: String, hives: Int, description: String, id: String) {
        self.name = name
        self.hives = hives
        self.description = description
        self.id = id
    }
    
}
