//
//  OffersModel.swift
//  test
//
//  Created by Rana Muneeb on 12/11/2020.
//

import Foundation
import Firebase

class MyDealsModel{
    var ref:DatabaseReference!
    var agreement_signed_lender:Bool,agreement_signed_borrower:Bool
    var type:String,amount:String,amountAfterInterest:String,interestRate:String,duration:String,timeStamp:String,loan_agreement:String,lender:String,borrower:String,offer_uid:String;
    var date:Double;
    var status:Int;
    var proposed_money: [PropsedMoneyModel]=[];
    var reported:Int;
    
    init() {
        
        self.type="";
        self.amount=""
        self.amountAfterInterest="";
        self.interestRate="";
        self.duration="";
        self.status=0;
        self.timeStamp="";
        self.agreement_signed_lender=false;
        self.agreement_signed_borrower=false;
        self.loan_agreement=""
        self.lender=""
        self.borrower=""
        self.date=0
        self.offer_uid=""
        self.reported=0;
    
    }
    
    init(type:String,amount:String,amountAfterInterest:String,interestRate:String,duration:String,status:Int,timeStamp:String, agreement_signed_lender:Bool,agreement_signed_borrower:Bool,loan_agreement:String,lender:String,borrower:String,reported:Int) {
        
        self.type=type;
        self.amount=amount
        self.amountAfterInterest=amountAfterInterest;
        self.interestRate=interestRate;
        self.duration=duration;
        self.status=status;
        self.timeStamp=timeStamp;
        self.agreement_signed_lender=agreement_signed_lender;
        self.agreement_signed_borrower=agreement_signed_borrower;
        self.loan_agreement=loan_agreement
        self.lender=lender
        self.borrower=borrower
        self.date=0
        self.offer_uid=""
        self.reported=reported;
    }
    
    func setOfferUid(uid:String) {
        self.offer_uid=uid
        
        ref = Database.database().reference();
        ref.child("payments").child(offer_uid).observeSingleEvent(of: .value, with: { (snapshots) in
            print(snapshots.childrenCount)
            for child in snapshots.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject];
                var ext = dict?["extension_requested"] as? Int ?? 0
                self.proposed_money.append(PropsedMoneyModel(amount: dict!["amount"] as! Double, index: Int(child.key as! String)!, status: dict!["status"] as! Int, due_date: dict!["due_date"] as! String, month: dict!["month"] as! String, uid: child.key,showStatus:true, extension_requested: ext));
            }


        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
