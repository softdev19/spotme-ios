//
//  DialogProposedPaymentsViewController.swift
//  test
//
//  Created by Rana Muneeb on 19/11/2020.
//

import UIKit
import Firebase
import Cosmos

class DialogRate: BaseViewController {

    @IBOutlet weak var ratings: CosmosView!
    @IBOutlet weak var review: EditText!
    var uid:String="";
    var review_by:String="";
    var review_type:String="";
    var ref:DatabaseReference!
    var navigationControllers=UIViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference();
        
       view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
       
    }
    
    @IBAction func onRate_Pressed(_ sender: Any) {
        
        if(!review.hasText)
        {
            let alertController = UIAlertController(title: "Alert", message: "Please enter review", preferredStyle: .alert)
               let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                  
               })
               alertController.addAction(OKAction)
            self.navigationControllers.present(alertController, animated: true, completion: nil)
        }else{
        ref.child("reviews").child(self.uid).childByAutoId().setValue(["rating":ratings.rating,"review":review.text,"review_by":review_by,"review_type":review_type])
        
        self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onCancel_Pressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
