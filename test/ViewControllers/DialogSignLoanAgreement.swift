//
//  DialogProposedPaymentsViewController.swift
//  test
//
//  Created by Rana Muneeb on 19/11/2020.
//

import UIKit
import WebKit
import SignaturePad
import Firebase
import UICheckbox_Swift

class DialogSignLoanAgreement: BaseViewController {

    @IBOutlet weak var checkbox: UICheckbox!
    var counter_offer=false
    var previous_offer_id=""
    @IBOutlet weak var sign_agreement_layout: UIView!
    @IBOutlet weak var loan_agreement_layout: UIView!
    var loan_agreement:String=""
    var ref:DatabaseReference!
    var navigationControllers:UINavigationController=UINavigationController()
    var amount=""
    var types=""
    var request_message=""
    var amountAfterInterest=""
    var interestRate=""
    var duration=""
    var status=0
    var timeStamp=""
    var agreement_signed_lender=false
    var agreement_signed_borrower=false
    var proposed_money:[PropsedMoneyModel]=[]
    
    var last_stage:Bool=false
    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var signaturePad: SignaturePad!
    var selectedUser:UserModel=UserModel()
    var currentUser:UserModel=UserModel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference();
        
        loan_agreement_layout.isHidden=false
        sign_agreement_layout.isHidden=true
        
       view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        webview.loadHTMLString(loan_agreement, baseURL: nil)
       
    }
    
    @IBAction func continue1_Pressed(_ sender: Any) {
        if(last_stage)
        {
            if(self.checkbox.isSelected){
              
            showLoading()
    
    
            if(types=="lend"){
                
                for item in proposed_money {
                    self.ref.child("payments").child(currentUser.uid+"_"+selectedUser.uid+"_"+String(timeStamp)).child(String(item.index)).setValue(["index": item.index,"amount":item.amount,"status":item.status,"due_date":item.due_date,"month":item.month,"uid":item.uid])
                }
                
            self.ref.child("offers").child(currentUser.uid+"_"+selectedUser.uid+"_"+String(timeStamp)).setValue(["type":types,"amount":amount,"amountAfterInterest":amountAfterInterest,"interestRate":interestRate,"duration":duration,"status":status,"date":timeStamp,"agreement_signed_lender":agreement_signed_lender,"agreement_signed_borrower":agreement_signed_borrower,"loan_agreement":loan_agreement,"lender":currentUser.uid,"borrower":selectedUser.uid])
            
                if(counter_offer)
                {
                    self.ref.child("notifications").child(selectedUser.uid).childByAutoId().child("notification").setValue(currentUser.name + " has made a counter offer to lend $" + amount);
                    sendNotification(notification:currentUser.name + " has made a counter offer to lend $" + amount, device_token: selectedUser.device_token)

                    self.ref.child("requests").child(previous_offer_id).child("status").setValue(-2);

                }else{
                    
                    self.ref.child("notifications").child(selectedUser.uid).childByAutoId().child("notification").setValue(currentUser.name + " has sent you an offer to lend $" + amount);
                    
                    sendNotification(notification:currentUser.name + " has sent you an offer to lend $" + amount, device_token: selectedUser.device_token)

                }
                
        
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3 ){
                self.hideLoading()
                        
                if self.presentingViewController != nil {
                    self.dismiss(animated: false, completion: {
                        let alertController = UIAlertController(title: "Success", message: "Offer sent succesfully", preferredStyle: .alert)
                           let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                                self.navigationControllers.popViewController(animated: true)
                            
                           })
                           alertController.addAction(OKAction)
                        self.navigationControllers.present(alertController, animated: true, completion: nil)
                       
                    })
                }
                else {
                    self.navigationControllers.popViewController(animated: true)
                }
            
                
//                self.view.makeToast("This is a piece of toast")
//                self.navigationController?.popToRootViewController(animated: true)
//                let storyBoard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
//                let newViewController = storyBoard.instantiateViewController(withIdentifier: "Home") as! UITabBarController
//                self.navigationController?.pushViewController(newViewController, animated: true)
            }
            }else{
                
                if(selectedUser.uid=="")
                {
                    for item in proposed_money {
                        self.ref.child("payments").child(currentUser.uid+"_"+String(timeStamp)).child(String(item.index)).setValue(["index": item.index,"amount":item.amount,"status":item.status,"due_date":item.due_date,"month":item.month,"uid":item.uid])
                    }
                    
                    self.ref.child("universal_requests").child(currentUser.uid+"_"+String(timeStamp)).setValue(["type":types,"amount":amount,"amountAfterInterest":amountAfterInterest,"interestRate":interestRate,"duration":duration,"status":status,"date":timeStamp,"agreement_signed_lender":agreement_signed_lender,"agreement_signed_borrower":agreement_signed_borrower,"loan_agreement":loan_agreement,"lender":"","borrower":currentUser.uid,"request_message":request_message])
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3 ){
                        self.hideLoading()
                                
                        if self.presentingViewController != nil {
                            self.dismiss(animated: false, completion: {
                                let alertController = UIAlertController(title: "Success", message: "Your request has been submitted for approval, this may up to 24 hours to process", preferredStyle: .alert)
                                   let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                                        self.navigationControllers.popViewController(animated: true)
                                   })
                                   alertController.addAction(OKAction)
                                self.navigationControllers.present(alertController, animated: true, completion: nil)
                               
                            })
                        }
                        else {
                            self.navigationControllers.popViewController(animated: true)
                        }
                    
                        
        //                self.view.makeToast("This is a piece of toast")
        //                self.navigationController?.popToRootViewController(animated: true)
        //                let storyBoard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
        //                let newViewController = storyBoard.instantiateViewController(withIdentifier: "Home") as! UITabBarController
        //                self.navigationController?.pushViewController(newViewController, animated: true)
                    }
                    
                }else{
                for item in proposed_money {
                    self.ref.child("payments").child(selectedUser.uid+"_"+currentUser.uid+"_"+String(timeStamp)).child(String(item.index)).setValue(["index": item.index,"amount":item.amount,"status":item.status,"due_date":item.due_date,"month":item.month,"uid":item.uid])
                }
                
                self.ref.child("requests").child(selectedUser.uid+"_"+currentUser.uid+"_"+String(timeStamp)).setValue(["type":types,"amount":amount,"amountAfterInterest":amountAfterInterest,"interestRate":interestRate,"duration":duration,"status":status,"date":timeStamp,"agreement_signed_lender":agreement_signed_lender,"agreement_signed_borrower":agreement_signed_borrower,"loan_agreement":loan_agreement,"lender":selectedUser.uid,"borrower":currentUser.uid])
                
                if(counter_offer)
                {
                    self.ref.child("notifications").child(selectedUser.uid).childByAutoId().child("notification").setValue(currentUser.name + " has made a counter offer to borrow $" + amount);
                    sendNotification(notification:currentUser.name + " has made a counter offer to borrow $" + amount, device_token: selectedUser.device_token)
                    self.ref.child("offers").child(previous_offer_id).child("status").setValue(-2);
                }else{
                    
                    self.ref.child("notifications").child(selectedUser.uid).childByAutoId().child("notification").setValue(currentUser.name + " has sent you an request to borrow $" + amount);
                    sendNotification(notification:currentUser.name + " has sent you an request to borrow $" + amount, device_token: selectedUser.device_token)
                }
             

                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3 ){
                    self.hideLoading()
                            
                    if self.presentingViewController != nil {
                        self.dismiss(animated: false, completion: {
                            let alertController = UIAlertController(title: "Success", message: "Request sent succesfully", preferredStyle: .alert)
                               let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                                    self.navigationControllers.popViewController(animated: true)
                               })
                               alertController.addAction(OKAction)
                            self.navigationControllers.present(alertController, animated: true, completion: nil)
                           
                        })
                    }
                    else {
                        self.navigationControllers.popViewController(animated: true)
                    }
                
                    
    //                self.view.makeToast("This is a piece of toast")
    //                self.navigationController?.popToRootViewController(animated: true)
    //                let storyBoard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
    //                let newViewController = storyBoard.instantiateViewController(withIdentifier: "Home") as! UITabBarController
    //                self.navigationController?.pushViewController(newViewController, animated: true)
                }
            }
        }
            }else{
                showMessage(msg: "Please agree to terms & conditions first")
            }
           
        }else{
            if(self.checkbox.isSelected){
                loan_agreement_layout.isHidden=true
                sign_agreement_layout.isHidden=false
            }else{
                showMessage(msg: "Please agree to terms & conditions first")
            }
        }
       
    }
    @IBAction func closeDialog(_ sender: Any) {
        self.dismiss(animated: false,completion: nil)
    }
    @IBAction func continue2_Pressed(_ sender: Any) {
        if(signaturePad.isSigned){
            
        let signature=signaturePad.getSignature()
        
            let sign=signature!.imageResized(to: CGSize(width: 60.0, height: 60.0))
            let imageData:NSData = sign.pngData()! as NSData
                
            let strBase64 = imageData.base64EncodedString()
            let strBase64_1="data:image/png;base64," + strBase64
        if(types=="lend")
        {
            self.loan_agreement=self.loan_agreement.replacingOccurrences(of: "{IMAGE_PLACEHOLDER}", with: strBase64_1)
        }else{
            self.loan_agreement=self.loan_agreement.replacingOccurrences(of: "{IMAGE_PLACEHOLDER1}", with: strBase64_1)
        }
        webview.loadHTMLString(loan_agreement, baseURL: nil)
            
        loan_agreement_layout.isHidden=false
        sign_agreement_layout.isHidden=true
        last_stage=true
        }else{
           //showMessage(msg: "Please sign above to continue")
        }
    }

    func popBack(_ nb: Int) {
        if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            guard viewControllers.count < nb else {
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - nb], animated: true)
                return
            }
        }
    }
}
