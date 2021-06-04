//
//  DialogProposedPaymentsViewController.swift
//  test
//
//  Created by Rana Muneeb on 19/11/2020.
//

import UIKit
import Firebase

class DialogGrantExtensionViewController: BaseViewController {

    var offer_id:String="";
    var payment_id:String="";
    var due_date:String="";
    var ref:DatabaseReference!
    var navigationControllers:UINavigationController=UINavigationController()
    var selectedUser=UserModel()
    var currentUser=UserModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference();
        
       view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
       
    }
    
    @IBAction func onWithdrawPressed(_ sender: Any) {

        self.ref.child("payments").child(offer_id).child(payment_id).child("extension_requested").setValue(2);
        self.ref.child("payments").child(offer_id).child(payment_id).child("due_date").setValue(due_date);
       
        self.dismiss(animated: false, completion: {
            let alertController = UIAlertController(title: "Success", message: "Extension Granted succesfully", preferredStyle: .alert)
               let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                self.ref.child("notifications").child(self.selectedUser.uid).childByAutoId().child("notification").setValue(self.currentUser.name + " has accepted your extension request for the current loan installment");
                self.sendNotification(notification:self.currentUser.name + " has accepted your extension request for the current loan installment", device_token: self.selectedUser.device_token)
                
                self.navigationControllers.loadView()
               })
               alertController.addAction(OKAction)
            self.navigationControllers.present(alertController, animated: true, completion: nil)
           
        })
    }
    
    @IBAction func onCancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
