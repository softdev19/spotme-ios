//
//  ProposedMoneyModel.swift
//  test
//
//  Created by Rana Muneeb on 18/11/2020.
//

import Foundation

class NotificationModel {

    var notifcation:String;
    var uid:String
    
    init(notifcation:String) {
        self.notifcation=notifcation
        self.uid=""
    }
    
    func setUid(uid:String) {
        self.uid=uid
    }

    
    
}
