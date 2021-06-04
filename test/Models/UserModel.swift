//
//  UserModel.swift
//  test
//
//  Created by Rana Muneeb on 12/11/2020.
//

import Foundation

class UserModel:Codable{
    public var name:String, username:String,phone:String, email:String, password:String, socialSecurityNo:String, employmentId:String, address:String, dateOfBirth:String,uid:String,image_url:String,device_token:String,blocked:Int;
    
    init()
    {
        self.name="";
        self.username="";
        self.email="";
        self.phone="";
        self.password="";
        self.socialSecurityNo="";
        self.employmentId="";
        self.address="";
        self.dateOfBirth="";
        self.uid=""
        self.image_url=""
        self.device_token=""
        self.blocked=0
    }
    
    init(name:String, username:String,phone:String, email:String, password:String, socialSecurityNo:String, employmentId:String, address:String, dateOfBirth:String,image_url:String) {
        self.name=name;
        self.username=username;
        self.email=email;
        self.phone=phone;
        self.password=password;
        self.socialSecurityNo=socialSecurityNo;
        self.employmentId=employmentId;
        self.address=address;
        self.dateOfBirth=dateOfBirth;
        self.uid=""
        self.image_url=image_url
        self.device_token=""
        self.blocked=0
    }
    
    func setDeviceToken(token:String)
    {
        self.device_token=token
    }
    
    func setBlocked(blocked:Int)
    {
        self.blocked=blocked
    }
    
    func setUid(uid:String) {
        self.uid=uid
    }

}
