//
//  ViewController.swift
//  test
//
//  Created by Rana Muneeb on 03/11/2020.
//

import UIKit
import Firebase
import OTPFieldView

class VerifyPinViewController: BaseViewController, OTPFieldViewDelegate {
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otp: String) {
        print("OTP? \(otp)")
        self.otp=otp;
        
    }
    
    func hasEnteredAllOTP(hasEnteredAll: Bool) -> Bool {
        print("Has entered all OTP? \(hasEnteredAll)")
        return false
    }
    
 @IBOutlet weak var otpView: OTPFieldView!
    var otp=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        // Do any additional setup after loading the view.\
        self.setupOtpView()
        
    }
    @IBAction func onLoginAgain(_ sender: Any) {
        let firebaseAuth = Auth.auth()
          do {
            try firebaseAuth.signOut()
          } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
          }
        let defaults = UserDefaults.standard
            let dictionary = defaults.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                defaults.removeObject(forKey: key)
            }
        self.performSegue(withIdentifier: "loginPage1", sender: nil)
    }
    @IBAction func onVeriify(_ sender: Any) {
        if(otp=="")
        {
            showMessage(msg: "Please enter Pin")
        }else{
            let defaults = UserDefaults.standard
            let pin:String = defaults.string(forKey: "Pin") ?? ""
            if(pin == otp)
            {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "Home") as! UITabBarController
                self.navigationController?.pushViewController(newViewController, animated: true)
            }else{
                showMessage(msg: "Pin verification failed")
            }
        }
    }

    func setupOtpView() {
               self.otpView.fieldsCount = 4
               self.otpView.fieldBorderWidth = 2
               self.otpView.defaultBorderColor = UIColor.black
               self.otpView.filledBorderColor = UIColor.green
               self.otpView.cursorColor = UIColor.green
               self.otpView.displayType = .underlinedBottom
               self.otpView.fieldSize = 40
               self.otpView.separatorSpace = 8
               self.otpView.shouldAllowIntermediateEditing = false
               self.otpView.otpInputType = .numeric
               self.otpView.delegate = self
              self.otpView.initializeUI()

           }
}


