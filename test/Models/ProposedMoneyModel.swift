//
//  ProposedMoneyModel.swift
//  test
//
//  Created by Rana Muneeb on 18/11/2020.
//

import Foundation

class PropsedMoneyModel {

    var amount:Double;
    var extension_requested:Int
    var index:Int,status:Int;
    var due_date:String,month:String,uid:String;
    var showStatus:Bool
    
    init(amount:Double,index:Int,status:Int,due_date:String,month:String,uid:String,showStatus:Bool,extension_requested:Int) {
        self.amount=amount
        self.index=index
        self.status=status;
        self.due_date=due_date;
        self.month=month;
        self.uid=uid
        self.showStatus=showStatus
        self.extension_requested=extension_requested
    }
    
    
}
