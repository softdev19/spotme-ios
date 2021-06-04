//
//  DialogProposedPaymentsViewController.swift
//  test
//
//  Created by Rana Muneeb on 19/11/2020.
//

import UIKit
import Firebase

class DialogReportUserViewController: BaseViewController {

    var type:String="";
    var id:String="";
    var ref:DatabaseReference!
    var navigationControllers:UINavigationController=UINavigationController()
    var selectedUser=UserModel()
    var currentUser=UserModel()
    @IBOutlet weak var report_msg: EditText!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference();
        
       view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
       
    }
    
    @IBAction func onWithdrawPressed(_ sender: Any) {
        
        if(self.report_msg.text == "")
        {
            showMessage(msg: "Please enter your issue")
        }else{
            self.ref.child(type).child(id).child("reported").setValue(1);
            self.ref.child("users").child(selectedUser.uid).child("reported").setValue(1);
            
            self.ref.child("user_reported").child(selectedUser.uid).child(id).child("info").setValue(report_msg.text)
            self.ref.child("user_reported").child(selectedUser.uid).child(id).child("reported_by").setValue(currentUser.uid)
       
            self.dismiss(animated: false, completion: {
            let alertController = UIAlertController(title: "Success", message: "User Reported succesfully", preferredStyle: .alert)
               let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
              
                self.navigationControllers.loadView()
               })
               alertController.addAction(OKAction)
            self.navigationControllers.present(alertController, animated: true, completion: nil)
           
        })
        }
    }
    
    @IBAction func onCancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
