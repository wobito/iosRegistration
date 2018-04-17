//
//  Attendee.swift
//  Registration
//
//  Created by Adrian Wobito on 2018-01-08.
//  Copyright © 2018 Adrian Wobito. All rights reserved.
//

import UIKit
import SwiftyJSON

class Attendee {
    var name : String  = ""
    var status : String = ""
    var postStatus : String = ""
    var seatType : String  = ""
    var state : String  = ""
    var city : String  = ""
    var first : String  = ""
    var last : String  = ""
    var label : String = ""
    
    var contactId : Int = 0
    var eventId : Int = 0
    var pivotId : Int = 0
    
    init(data: JSON = []) {
        self.name = data["name"].stringValue
        self.city = data["city"].stringValue
        self.state = data["state"].stringValue
        self.seatType = data["seatType"].stringValue
        self.first = data["first"].stringValue
        self.last = data["last"].stringValue
        self.label = data["label"].stringValue
        self.status = data["status"].stringValue
        self.postStatus = data["postStatus"].stringValue
        
        self.contactId = data["contact_id"].intValue
        self.eventId = data["event_id"].intValue
        self.pivotId = data["pivot_id"].intValue        
    }
}
