//
//  OffersCell.swift
//  test
//
//  Created by Rana Muneeb on 12/11/2020.
//

import UIKit
import Firebase

class MyDealsCell: UITableViewCell {
  

    @IBOutlet weak var grant_ext_btn: Button!
    @IBOutlet weak var request_ext_btn: Button!
    @IBOutlet weak var upcoming_payment_status: UILabel!
    @IBOutlet weak var messageBtn: CardView!
    @IBOutlet weak var user_image: CircleImageView!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var interest_rate: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var amountAfterInterest: UILabel!
    @IBOutlet weak var currentPayment_index: UILabel!
    @IBOutlet weak var currentPayment_dueDate: UILabel!
    @IBOutlet weak var currentPayment_amount: UILabel!
    @IBOutlet weak var currentPayment_month: UILabel!
    @IBOutlet weak var payNowButton: Button!
    @IBOutlet weak var loan_paid_card: CardView!
    @IBOutlet weak var loan_pending_card: CardView!
    @IBOutlet weak var rate_btn: Button!
    
    var current_payment_date:Date=Date()
    var current_payment_id=""
    var current_index:String="0"
    var current_amount:String="0"
    var ref:DatabaseReference!
    var uid:String = ""
    var this=UIViewController()
    var model=MyDealsModel()
    var payments_done:Bool=true
    var selectedUser=UserModel()
    var currentUser=UserModel()

    @IBOutlet weak var report_view: UIStackView!
    
    func setOffer(offer:MyDealsModel,this:UIViewController,position:Int)
    {
        if(offer.type=="lend"){
            type.text="Loaned"
            uid=offer.borrower
            payNowButton.isHidden=true
            rate_btn.setTitle("Rate\nBorrower", for: .normal)
            rate_btn.titleLabel?.textAlignment = .center
        }else{
            type.text="Borrowed"
            uid=offer.lender
            payNowButton.isHidden=false
            rate_btn.setTitle("Rate\nLender", for: .normal)
            rate_btn.titleLabel?.textAlignment = .center
        }
        self.grant_ext_btn.isHidden=true
        self.request_ext_btn.isHidden=true
        self.this=this
        self.model=offer
        
        if(self.model.type=="lend"){
//            if(self.model.reported==0)
//            {
//                self.report_view.isHidden=false
//            }else{
//                self.report_view.isHidden=true
//            }
        }else{
            self.report_view.isHidden=true
        }
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(cameraTapped))
        messageBtn.isUserInteractionEnabled = true
        messageBtn.addGestureRecognizer(backTap)
        
        amount.text="$"+offer.amount+".00"
        interest_rate.text=offer.interestRate+"%"
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
                        self.user_image.sd_setImage(with: URL(string:   self.selectedUser.image_url))
                        self.user_image.contentMode = .scaleAspectFill
                        self.user_image.layer.masksToBounds = true
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

        if(offer.proposed_money.count>0){
            for item in offer.proposed_money
            {
                if(item.status==0)
                {
                    self.current_index = String(item.index)
                    self.current_amount = String(item.amount)
                    self.currentPayment_index.text=String(item.index)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "EE MMM dd HH:mm:ss ZZZ yyyy"
                    let date = dateFormatter.date(from: item.due_date)
                    self.current_payment_date=date!;
                    dateFormatter.dateFormat="dd-MMM-yyyy"
                    
                    self.currentPayment_dueDate.text=dateFormatter.string(from: date!)
                    self.currentPayment_month.text=item.month
                    var int_value1=Int(item.amount)
                    self.currentPayment_amount.text="$"+String(int_value1)+".00"
                    let currentDateTime = Date()
                 
                    if(currentDateTime<date!){
                        self.upcoming_payment_status.text="Upcoming Payment"
                        self.upcoming_payment_status.textColor=UIColor.systemOrange
                    }else{
                        self.upcoming_payment_status.text="Late Payment"
                        self.upcoming_payment_status.textColor=UIColor.systemRed
                    }
                    payments_done=false
                    self.current_payment_id=item.uid
                    
                    if(offer.type=="lend"){
                        if(item.extension_requested==1){
                            self.grant_ext_btn.isHidden=false
                            self.request_ext_btn.isHidden=true
                            
                        }else{
                            self.grant_ext_btn.isHidden=true
                            self.request_ext_btn.isHidden=true
                    
                        }
                    }else{
                        if(item.extension_requested==0){
                            let date = Calendar.current.date(byAdding: .day, value: -7, to: self.current_payment_date)!
                            let dateFormatter1 = DateFormatter()
                            dateFormatter1.dateFormat = "EE MMM dd HH:mm:ss ZZZ yyyy"
                    //        popupViewController.due_date=dateFormatter1.string(from: date!)\
                            if date < Date()  {
                                self.grant_ext_btn.isHidden=true
                                self.request_ext_btn.isHidden=false
                            }
                           
                        }else{
                            self.grant_ext_btn.isHidden=true
                            self.request_ext_btn.isHidden=true
                    
                        }
                    }
                    
                  
                    
                    break
                }
            }
        }
        
        if(payments_done)
        {
            print("inside",payments_done)
            loan_pending_card.isHidden=true
            loan_paid_card.isHidden=false
        }else{
            loan_pending_card.isHidden=false
            loan_paid_card.isHidden=true
        }
    
        
    }
    
    @IBAction func onRequesExtPressed(_ sender: Any) {
        if let popupViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "DialogRequestExtensionViewController") as? DialogRequestExtensionViewController {
        popupViewController.modalPresentationStyle = .custom
        popupViewController.modalTransitionStyle = .crossDissolve
         
            popupViewController.offer_id=model.offer_uid
            popupViewController.payment_id=self.current_payment_id
            popupViewController.navigationControllers=self.this.navigationController!
            popupViewController.currentUser=self.currentUser
            popupViewController.selectedUser=self.selectedUser
            
            self.this.present(popupViewController, animated: true)
    }
    }
    @IBAction func onGrantExtPressed(_ sender: Any) {
        
        if let popupViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "DialogGrantExtensionViewController") as? DialogGrantExtensionViewController {
        popupViewController.modalPresentationStyle = .custom
        popupViewController.modalTransitionStyle = .crossDissolve
         
            popupViewController.offer_id=model.offer_uid
            popupViewController.payment_id=self.current_payment_id
            let date = Calendar.current.date(byAdding: .day, value: 14, to: self.current_payment_date)
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "EE MMM dd HH:mm:ss ZZZ yyyy"
            popupViewController.due_date=dateFormatter1.string(from: date!)
            popupViewController.navigationControllers=self.this.navigationController!
            popupViewController.currentUser=self.currentUser
            popupViewController.selectedUser=self.selectedUser
            
            self.this.present(popupViewController, animated: true)
    }
        
    }
    @IBAction func reportPreseed(_ sender: Any) {
        if let popupViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "DialogReportUserViewController") as? DialogReportUserViewController {
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
    
    @objc func cameraTapped() {
        print("yesss")
        let vc = SendMessageViewController(uid1: Auth.auth().currentUser!.uid, uid2:self.selectedUser.uid, thread_id_notification: "0",count:0,selectedUser: self.selectedUser)
        self.this.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func rate_btnPressed(_ sender: Any) {
        
        if(self.model.type=="lend"){
            ref.child("reviews").child(self.model.borrower).queryOrdered(byChild: "review_by").queryEqual(toValue: self.currentUser.uid).observeSingleEvent(of: .value, with: { (snapshots) in
                
                if(!snapshots.exists())
                {
                    if let popupViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "DialogRate") as? DialogRate {
                    popupViewController.modalPresentationStyle = .custom
                    popupViewController.modalTransitionStyle = .crossDissolve
             
                    popupViewController.uid=self.model.borrower;
                    popupViewController.review_by=self.currentUser.uid;
                    popupViewController.review_type="borrower";
                    popupViewController.navigationControllers=self.this;
                    self.this.present(popupViewController, animated: true)
                    }
                    
                }else{
                    var flag=false
                    for child in snapshots.children.allObjects as! [DataSnapshot] {
                        let dict = child.value as? [String : AnyObject];
                        print(dict)
                    if(dict!["review_type"] as! String == "borrower")
                    {
                        let alertController = UIAlertController(title: "Alert", message: "Oops! You’ve already left a review", preferredStyle: .alert)
                            let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                            
                        })
                            alertController.addAction(OKAction)
                        self.this.navigationController?.present(alertController, animated: true, completion: nil)
                    }else{
                        flag=true
                    }
                }
                    if(flag)
                    {
                        if let popupViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "DialogRate") as? DialogRate {
                            
                            popupViewController.modalPresentationStyle = .custom
                            popupViewController.modalTransitionStyle = .crossDissolve
                            
                            popupViewController.uid=self.model.borrower;
                            popupViewController.review_by=self.currentUser.uid;
                            popupViewController.review_type="borrower";
                            popupViewController.navigationControllers=self.this;
                            self.this.present(popupViewController, animated: true)
                        }
                    }
                }
                
            }) { (error) in
              print(error.localizedDescription)
          }
        }else{
            ref.child("reviews").child(self.model.lender).queryOrdered(byChild: "review_by").queryEqual(toValue: self.currentUser.uid).observeSingleEvent(of: .value, with: { (snapshots) in
                
                if(!snapshots.exists())
                {
                    if let popupViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "DialogRate") as? DialogRate {
                    popupViewController.modalPresentationStyle = .custom
                    popupViewController.modalTransitionStyle = .crossDissolve
                        popupViewController.uid=self.model.lender;
                        popupViewController.review_by=self.currentUser.uid;
                        popupViewController.review_type="lender";
                        popupViewController.navigationControllers=self.this;
                        self.this.present(popupViewController, animated: true)
                    }
                }else{
                    var flag=false
                    for child in snapshots.children.allObjects as! [DataSnapshot] {
                        let dict = child.value as? [String : AnyObject];
                
                    if(dict!["review_type"] as! String == "lender")
                    {
                        let alertController = UIAlertController(title: "Alert", message: "Oops! You’ve already left a review", preferredStyle: .alert)
                            let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                            
                        })
                            alertController.addAction(OKAction)
                        self.this.navigationController?.present(alertController, animated: true, completion: nil)
                    }else{
                        flag=true
                    }
                }
                    
                    if(flag)
                    {
                        if let popupViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "DialogRate") as? DialogRate {
                        popupViewController.modalPresentationStyle = .custom
                        popupViewController.modalTransitionStyle = .crossDissolve
                            popupViewController.uid=self.model.lender;
                            popupViewController.review_by=self.currentUser.uid;
                            popupViewController.review_type="lender";
                            popupViewController.navigationControllers=self.this;
                            self.this.present(popupViewController, animated: true)
                        }
                    }
                }
                
            }) { (error) in
              print(error.localizedDescription)
          }
        }
    }
    
    @IBAction func profilePicPressed(_ sender: Any) {
        self.this.performSegue(withIdentifier: "DealsToProfile", sender: selectedUser)
    }
    
    
    @IBAction func onPayNowPressed(_ sender: Button) {
        var dict = [String: String]()
        dict["payment_id"] = self.model.offer_uid
        dict["user_id"] = self.selectedUser.uid
        dict["currentUser"] = self.currentUser.name
        dict["index"] = self.current_index
        dict["token"] = self.selectedUser.device_token
        dict["amount"] = self.current_amount
     
        self.this.performSegue(withIdentifier: "LoanPay2", sender: dict)
    }
    
    @IBAction func onLoanAgreementPressed(_ sender: Any) {
        if let popupViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "DialogLoanAgreement") as? DialogLoanAgreement {
        popupViewController.modalPresentationStyle = .custom
        popupViewController.modalTransitionStyle = .crossDissolve
            popupViewController.loan_agreement=self.model.loan_agreement;
        //presenting the pop up viewController from the parent viewController
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
