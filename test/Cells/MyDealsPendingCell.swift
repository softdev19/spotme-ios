//
//  OffersCell.swift
//  test
//
//  Created by Rana Muneeb on 12/11/2020.
//

import UIKit
import Firebase

class MyDealsPendingCell: UITableViewCell {
  
    @IBOutlet weak var user_image: CircleImageView!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var interest_rate: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var amountAfterInterest: UILabel!
    
    var ref:DatabaseReference!
    var uid:String = ""
    var this=UIViewController()
    var model=MyDealsModel()
    @IBOutlet weak var pendingStatus_text: UILabel!
    @IBOutlet weak var payNowBtn: Button1!
    var selectedUser=UserModel()
    var currentUser=UserModel()
    
    func setOffer(offer:MyDealsModel,this:UIViewController,position:Int)
    {
        if(offer.type=="lend"){
            self.type.text="Loan Offer"
            self.type.textColor=UIColor.systemOrange
            self.uid=offer.borrower
        
        }else{
            self.type.text="Borrow Request"
            self.type.textColor=UIColor.systemGreen
            self.uid=offer.lender
        }
        self.this=this
        self.model=offer
        
        ref = Database.database().reference();
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshots) in
              let dict = snapshots.value as? [String : AnyObject];
            
            let model=UserModel(name: dict!["name"] as! String, username: dict!["username"] as! String, phone: dict!["phone"] as! String, email:  dict!["email"] as! String, password: dict!["password"] as! String, socialSecurityNo: dict!["socialSecurityNo"] as! String, employmentId: dict!["employmentId"] as! String, address: dict!["address"] as! String, dateOfBirth: dict!["dateOfBirth"] as! String, image_url: dict!["image_url"] as! String);
            model.setUid(uid: (snapshots as AnyObject).key as String)
            model.setDeviceToken(token: dict!["device_token"] as! String)
            self.selectedUser = model
            self.username.text="(@"
            self.username.text!.append(dict!["username"] as! String)
            self.username.text!.append(") ")
            self.username.text!.append(dict!["name"] as! String)
            
            if(self.selectedUser.image_url==""){
            
            }else{
                
                DispatchQueue.main.async(execute: {() -> Void in
                    if self.tag == position {
                        self.user_image.sd_setImage(with: URL(string:   self.selectedUser.image_url))
                        self.user_image.contentMode = .scaleAspectFill
                        self.user_image.layer.masksToBounds = true
                    }
                })
                
              
            }
            if(offer.type=="lend"){
                self.pendingStatus_text.isHidden=false
                if(offer.status==0){
                    self.pendingStatus_text.text="Waiting for approval from "+self.username.text!
                    self.pendingStatus_text.text?.append(". You will be able to pay afterwards")
                    self.payNowBtn.isHidden=true
                }else if(offer.status==1){
                        self.pendingStatus_text.text="Approved by "+self.username.text!
                        self.pendingStatus_text.text?.append(". Please pay the loan now")
                        self.payNowBtn.isHidden=false
                }
                else{
                    self.payNowBtn.isHidden=true
                }
            }else{
                self.pendingStatus_text.isHidden=false
                self.pendingStatus_text.text="Waiting for approval"
                self.payNowBtn.isHidden=true
                
            }
            
          }) { (error) in
            print(error.localizedDescription)
        }
        
        amount.text="$"+offer.amount+".00"
        interest_rate.text=offer.interestRate+"%"
        duration.text=offer.duration;
        var dble=Double(offer.amountAfterInterest)!
        var int_value=Int(dble)
        amountAfterInterest.text="$"+String(int_value)+".00"
        
        ref.child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshots) in
            let dict = snapshots.value as? [String : AnyObject];
            let model=UserModel(name: dict!["name"] as! String, username: dict!["username"] as! String, phone: dict!["phone"] as! String, email:  dict!["email"] as! String, password: dict!["password"] as! String, socialSecurityNo: dict!["socialSecurityNo"] as! String, employmentId: dict!["employmentId"] as! String, address: dict!["address"] as! String, dateOfBirth: dict!["dateOfBirth"] as! String, image_url: dict!["image_url"] as! String);
            model.setUid(uid: (snapshots as AnyObject).key as String)
            self.currentUser = model
            
          }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    @IBAction func onprofilePicPressed(_ sender: Any) {
        self.this.performSegue(withIdentifier: "DealsToProfile", sender: selectedUser)
    }
    

    @IBAction func onPayNowPressed(_ sender: Any) {
        
        var dict = [String: String]()
        dict["offer_id"] = self.model.offer_uid
        dict["user_id"] = self.selectedUser.uid
        dict["currentUser"] = self.currentUser.name
        dict["type"] = self.model.type
        dict["token"] = self.selectedUser.device_token
        dict["loan_agreement"] = self.model.loan_agreement
        dict["amount"] = self.model.amount
        
        
        self.this.performSegue(withIdentifier: "LoanPay1", sender: dict)
    }
    
    @IBAction func onWithdrawPressed(_ sender: Any) {
        if let popupViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "DialogWithdrawOfferViewController") as? DialogWithdrawOfferViewController {
        popupViewController.modalPresentationStyle = .custom
        popupViewController.modalTransitionStyle = .crossDissolve
            
            if(model.type=="lend"){
                popupViewController.type="offers"
            }else{
                popupViewController.type="requests"
            }
            popupViewController.id=model.offer_uid
            popupViewController.selectedUser=self.selectedUser
            popupViewController.currentUser=self.currentUser
            popupViewController.navigationControllers=self.this.navigationController!
            
            self.this.present(popupViewController, animated: true)
    }
    }
    @IBAction func onPaymentDetailsPressed(_ sender: Any) {
        if let popupViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "DialogProposedPaymentsViewController") as? DialogProposedPaymentsViewController {
        popupViewController.modalPresentationStyle = .custom
        popupViewController.modalTransitionStyle = .crossDissolve
            popupViewController.money_array=self.model.proposed_money;
        //presenting the pop up viewController from the parent viewController
            self.this.present(popupViewController, animated: true)
    }
    }
    override func layoutSubviews() {

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.user_image.image =  UIImage(systemName: "person")
        // Set cell to initial state here, reset or set values
    }

}
