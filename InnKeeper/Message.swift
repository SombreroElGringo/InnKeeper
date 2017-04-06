//
//  Message.swift
//  InnKeeper
//
//  Created by Florent on 30/03/2017.
//  Copyright © 2017 SombreroElGringo. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    var videoUrl: String?
    
    func chatPartnerId() -> String? {
        
        if fromId == FIRAuth.auth()?.currentUser?.uid {
            return toId
        } else {
            return fromId
        }
    }
}
