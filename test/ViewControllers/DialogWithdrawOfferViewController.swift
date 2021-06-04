//
//  DialogProposedPaymentsViewController.swift
//  test
//
//  Created by Rana Muneeb on 19/11/2020.
//

import UIKit
import Firebase

class DialogWithdrawOfferViewController: BaseViewController {

    var type:String="";
    var id:String="";
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
        self.ref.child(type).child(id).child("status").setValue(-1);
        self.dismiss(animated: false, completion: {
            let alertController = UIAlertController(title: "Success", message: "Offer withdrawn succesfully", preferredStyle: .alert)
               let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                self.ref.child("notifications").child(self.selectedUser.uid).childByAutoId().child("notification").setValue(self.currentUser.name + " has withdrawn from the offer");
                self.sendNotification(notification:self.currentUser.name + " has withdrawn from the offer", device_token: self.selectedUser.device_token)
                
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
