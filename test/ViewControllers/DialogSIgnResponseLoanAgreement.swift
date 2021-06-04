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

class DialogSignResponseLoanAgreement: BaseViewController {

    @IBOutlet weak var checkbox: UICheckbox!
    @IBOutlet weak var sign_agreement_layout: UIView!
    @IBOutlet weak var loan_agreement_layout: UIView!
    var loan_agreement:String=""
    var amount:String=""
    var offer_id:String=""
    var types:String=""
    var universal=false
    var universal_object = RequestsModel()
    var ref:DatabaseReference!
    var navigationControllers:UINavigationController=UINavigationController()
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
        
        if(universal){
            let replaced = loan_agreement.replacingOccurrences(of: "LENDER_NAME", with: currentUser.name)
            let replaced1 = replaced.replacingOccurrences(of: "LENDER_USERNAME", with: currentUser.username)
            loan_agreement=replaced1
            webview.loadHTMLString(loan_agreement, baseURL: nil)
        }else{
            webview.loadHTMLString(loan_agreement, baseURL: nil)
        }
    }
    
    @IBAction func continue1_Pressed(_ sender: Any) {
        if(last_stage)
        {
            if(checkbox.isSelected){
            
    
            if(types=="lend"){
                showLoading()
                
                self.ref.child("offers").child(offer_id).child("status").setValue(1)
                self.ref.child("offers").child(offer_id).child("agreement_signed_borrower").setValue(true)
                self.ref.child("offers").child(offer_id).child("loan_agreement").setValue(loan_agreement)
            
            self.ref.child("notifications").child(selectedUser.uid).childByAutoId().child("notification").setValue(currentUser.name + " has accepted your loan offer. You can now proceed to pay");
                sendNotification(notification:currentUser.name + " has accepted your loan offer. You can now proceed to pay", device_token: selectedUser.device_token)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3 ){
                self.hideLoading()
                        
                if self.presentingViewController != nil {
                    self.dismiss(animated: false, completion: {
                        let alertController = UIAlertController(title: "Success", message: "Offer Accepted succesfully", preferredStyle: .alert)
                           let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                                self.navigationControllers.loadView()
                           })
                           alertController.addAction(OKAction)
                        self.navigationControllers.present(alertController, animated: true, completion: nil)
                       
                    })
                }
                else {
                    self.navigationControllers.popViewController(animated: true)
                }
            }
                
        }else{
            print("data","inside")
            self.performSegue(withIdentifier: "LoanPaySegue", sender: selectedUser)
        }
            
            }else{
                let alertController = UIAlertController(title: "Alert", message: "Please agree to loan agreement to continue", preferredStyle: .alert)
                   let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                        
                   })
                alertController.addAction(OKAction)
             self.present(alertController, animated: true, completion: nil)
            }
        }else{
            if(checkbox.isSelected){
            loan_agreement_layout.isHidden=true
            sign_agreement_layout.isHidden=false
            }else{
                let alertController = UIAlertController(title: "Alert", message: "Please agree to loan agreement to continue", preferredStyle: .alert)
                   let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                        
                   })
                alertController.addAction(OKAction)
             self.present(alertController, animated: true, completion: nil)
            }
        }
       
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
            print("yes","yes")
            let replaced = loan_agreement.replacingOccurrences(of: "{IMAGE_PLACEHOLDER1}", with: strBase64_1)
            loan_agreement=replaced
            print("yes",replaced)
        }else{
            self.loan_agreement=self.loan_agreement.replacingOccurrences(of: "{IMAGE_PLACEHOLDER}", with:strBase64_1)
        }
    //        print(self.loan_agreement)
            webview.loadHTMLString("<html></html>", baseURL: nil)
        webview.loadHTMLString(self.loan_agreement, baseURL: nil)
                
        loan_agreement_layout.isHidden=false
        sign_agreement_layout.isHidden=true
        last_stage=true
        }else{
           //showMessage(msg: "Please sign above to continue")
        }
    }

    @IBAction func closeBtn(_ sender: Any) {
        
        self.dismiss(animated: false,completion: nil)
    }
    func popBack(_ nb: Int) {
        if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            guard viewControllers.count < nb else {
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - nb], animated: true)
                return
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "LoanPaySegue") {
            let vc = segue.destination as! PayLoanViewController
            vc.offer_id=self.offer_id
            vc.user_id = self.selectedUser.uid
            vc.currentUser = self.currentUser.name
            vc.currentUserId = self.currentUser.uid
            vc.universal=universal
            vc.universal_object=self.universal_object
            vc.navigationControllers = self.navigationControllers
            if(self.types=="lend")
            {
                vc.type = "offers"
            }else{
                vc.type = "requests"
            }
           
            vc.token = self.selectedUser.device_token
            vc.loan_agreement = self.loan_agreement
            vc.amount = self.amount
        }
    }
}

extension UIImage {
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
