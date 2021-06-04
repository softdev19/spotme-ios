//
//  OffersCell.swift
//  test
//
//  Created by Rana Muneeb on 12/11/2020.
//

import UIKit
import Firebase

class OffersCell: UITableViewCell {

    @IBOutlet weak var profileImage: CircleImageView!
    
    @IBOutlet weak var msg_card: CardView!
    @IBOutlet weak var wating_for_payment_status: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var interestRate: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var amountAfterInterest: UILabel!
    @IBOutlet weak var propsedPayments_btn: CardView!
    @IBOutlet weak var declineBtn: UIButton!
    @IBOutlet weak var counterBtn: UIButton!
    @IBOutlet weak var acceptBtn: Button1!
    
    var ref:DatabaseReference!
    var uid:String = ""
    var this=UIViewController()
    var offer_model=OffersModel()
    var currentUser=UserModel()
    var selectedUser=UserModel()
    
    func setOffer(offer:OffersModel,this:UIViewController,position:Int)
    {
        acceptBtn.isHidden=false
        counterBtn.isHidden=false
        propsedPayments_btn.isHidden=false
        wating_for_payment_status.isHidden=true
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(cameraTapped))
        msg_card.isUserInteractionEnabled = true
        msg_card.addGestureRecognizer(backTap)
        
        self.offer_model=offer
        if(offer.type=="lend"){
            uid=offer.lender
        }else{
            uid=offer.borrower
        }
        self.this=this
        
        if(offer.status==1)
        {
            acceptBtn.isHidden=true
            counterBtn.isHidden=true
            propsedPayments_btn.isHidden=true
            wating_for_payment_status.isHidden=false
        }
        
        amount.text="$"+offer.amount+".00"
        interestRate.text=offer.interestRate+"%"
        duration.text=offer.duration;
        var dble=Double(offer.amountAfterInterest)!
        var int_value=Int(dble)
        amountAfterInterest.text="$"+String(int_value)+".00"
        
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
                        self.profileImage.sd_setImage(with: URL(string:   self.selectedUser.image_url))
                        self.profileImage.contentMode = .scaleAspectFill
                        self.profileImage.layer.masksToBounds = true
                    }
                })
                
               
            }
            
          }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshots) in
            let dict = snapshots.value as? [String : AnyObject];
            let model=UserModel(name: dict!["name"] as! String, username: dict!["username"] as! String, phone: dict!["phone"] as! String, email:  dict!["email"] as! String, password: dict!["password"] as! String, socialSecurityNo: dict!["socialSecurityNo"] as! String, employmentId: dict!["employmentId"] as! String, address: dict!["address"] as! String, dateOfBirth: dict!["dateOfBirth"] as! String, image_url: dict!["image_url"] as! String);
            model.setUid(uid: (snapshots as AnyObject).key as String)
            self.currentUser = model
            
          }) { (error) in
            print(error.localizedDescription)
        }
      
    }

    
    @IBAction func accept_pressed(_ sender: Any) {
        let defaults = UserDefaults.standard
        let stringOne:Bool = defaults.bool(forKey: "charges_enabled")
        if(stringOne)
        {
            if let popupViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "DialogSignResponseLoanAgreement") as? DialogSignResponseLoanAgreement {
            popupViewController.modalPresentationStyle = .custom
            popupViewController.modalTransitionStyle = .crossDissolve
            popupViewController.types=offer_model.type
            popupViewController.offer_id=offer_model.offer_uid
            popupViewController.amount=offer_model.amount
            popupViewController.currentUser=currentUser
                popupViewController.navigationControllers=self.this.navigationController!
            popupViewController.selectedUser=selectedUser
        
            popupViewController.loan_agreement = offer_model.loan_agreement
                
                self.this.present(popupViewController, animated: true)
        }
        }else{
            let alertController = UIAlertController(title: "Alert", message: "Please complete your payment setup before sending request", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                
            })
                alertController.addAction(OKAction)
            self.this.navigationController?.present(alertController, animated: true, completion: nil)
       
        }
        
    }
    @IBAction func counter_pressed(_ sender: Any) {
       
        let defaults = UserDefaults.standard
        let stringOne:Bool = defaults.bool(forKey: "charges_enabled")
        if(stringOne)
        {
            self.this.performSegue(withIdentifier: "MainToCounter", sender: offer_model)
        }else{
            let alertController = UIAlertController(title: "Alert", message: "Please complete your payment setup before sending request", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                    self.this.navigationController?.popViewController(animated: true)
            })
                alertController.addAction(OKAction)
            self.this.navigationController?.present(alertController, animated: true, completion: nil)
       
        }
    
    }
    @IBAction func decline_pressed(_ sender: Any) {
        if let popupViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "DialogWithdrawOfferViewController") as? DialogWithdrawOfferViewController {
        popupViewController.modalPresentationStyle = .custom
        popupViewController.modalTransitionStyle = .crossDissolve
            
            popupViewController.type="offers"
            popupViewController.id=offer_model.offer_uid
            popupViewController.selectedUser=selectedUser
            popupViewController.currentUser=currentUser
            popupViewController.navigationControllers=self.this.navigationController!
           // popupViewController.money_array=self.model.proposed_money;
        //presenting the pop up viewController from the parent viewController
            self.this.present(popupViewController, animated: true)
        }
    }
    
    @IBOutlet weak var onMessage_Pressed: CardView!
    @IBAction func profilePicPressed(_ sender: Any) {
        self.this.performSegue(withIdentifier: "OffersToProfile", sender: selectedUser)
    }
    
    @IBAction func btn_pressed(_ sender: Any) {
        if let popupViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "DialogProposedPaymentsViewController") as? DialogProposedPaymentsViewController {
        popupViewController.modalPresentationStyle = .custom
        popupViewController.modalTransitionStyle = .crossDissolve
            popupViewController.money_array=self.offer_model.proposed_money;
        //presenting the pop up viewController from the parent viewController
            self.this.present(popupViewController, animated: true)
    }
    }
    
    @objc func cameraTapped() {
        print("yesss")
        let vc = SendMessageViewController(uid1: Auth.auth().currentUser!.uid, uid2:self.selectedUser.uid, thread_id_notification: "0",count:0,selectedUser: self.selectedUser)
        self.this.navigationController!.pushViewController(vc, animated: true)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.profileImage.image = UIImage(systemName: "person")
        // Set cell to initial state here, reset or set values
    }
}


