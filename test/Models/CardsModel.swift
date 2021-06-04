//
//  ProposedMoneyModel.swift
//  test
//
//  Created by Rana Muneeb on 18/11/2020.
//

import Foundation

class CardsModel {

    var id:String,brand:String,country:String,exp_month:String,exp_year:String,last4:String;
 
    init()
    {
        self.id=""
        self.brand=""
        self.country="";
        self.exp_month="";
        self.exp_year="";
        self.last4=""
    }
    
    init(id:String,brand:String,country:String,exp_month:String,exp_year:String,last4:String) {
        self.id=id
        self.brand=brand
        self.country=country
        self.exp_month=exp_month
        self.exp_year=exp_year
        self.last4=last4
    }    
}
