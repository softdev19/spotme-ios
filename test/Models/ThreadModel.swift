//
//  ProposedMoneyModel.swift
//  test
//
//  Created by Rana Muneeb on 18/11/2020.
//

import Foundation

class ThreadModel {


    var notification_count:Int
    var chat_with:String,last_message:String,thread_id:String;

    init()
    {
        self.chat_with=""
        self.last_message=""
        self.thread_id="";
        self.notification_count=0;
    }
    
    init(chat_with:String,last_message:String,notification_count:Int) {
        self.chat_with=chat_with
        self.last_message=last_message
        self.thread_id="";
        self.notification_count=notification_count;
    }
    
    
    func setThreadId(uid:String) {
        self.thread_id=uid
    }
    
    
}
