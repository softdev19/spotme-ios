//
//  ViewController.swift
//  test
//
//  Created by Rana Muneeb on 03/11/2020.
//

import UIKit
import Firebase
import OTPFieldView

class SetupPinViewController: BaseViewController, OTPFieldViewDelegate {
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
    

    @IBOutlet weak var back_btn: UIImageView!
    @IBOutlet weak var otpView: OTPFieldView!
    var otp=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(cameraTapped))
        back_btn.isUserInteractionEnabled = true
        back_btn.addGestureRecognizer(backTap)
        
        // Do any additional setup after loading the view.\
        self.setupOtpView()
        
    }
    @IBAction func onVeriify(_ sender: Any) {
        if(otp=="")
        {
            showMessage(msg: "Please enter Pin")
        }else{
        UserDefaults.standard.set(self.otp, forKey: "Pin")
        UserDefaults.standard.set(true, forKey: "pin_enabled")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1 ){
                    self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func cameraTapped() {
        self.navigationController?.popViewController(animated: true)
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


