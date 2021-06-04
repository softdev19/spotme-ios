//
//  ViewController.swift
//  test
//
//  Created by Rana Muneeb on 03/11/2020.
//

import UIKit
import Firebase
import OTPFieldView

class OTPViewController: BaseViewController, OTPFieldViewDelegate {
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
    var resolver:MultiFactorResolver!;
    var login=false
    var verificationId=""
    var otp=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.\
        self.setupOtpView()
        
        let user = Auth.auth().currentUser
        let defaults = UserDefaults.standard
        let phone:String = defaults.string(forKey: "Phone") ?? ""
        
        showLoading()
        if(login)
        {
            
            let hint = resolver.hints[0] as! PhoneMultiFactorInfo
                // Send SMS verification code
                PhoneAuthProvider.provider().verifyPhoneNumber(
                  with: hint,
                  uiDelegate: nil,
                  multiFactorSession: resolver.session) { (verificationId, error) in
                    if error != nil {
                        self.hideLoading()
                        self.showMessage(msg: error!.localizedDescription)
                    }else{
                        self.hideLoading()
                        self.verificationId=verificationId ?? ""
                        self.showMessage(msg: "OTP sent to registered phone number")
                    }
                   
                }
            
        }else{
           
                user?.multiFactor.getSessionWithCompletion({ (session, error) in
                  // Send SMS verification code.
                  PhoneAuthProvider.provider().verifyPhoneNumber(
                    phone,
                    uiDelegate: nil,
                    multiFactorSession: session) { (verificationId, error) in
                      // verificationId will be needed for enrollment completion.
                      // Ask user for the verification code.
                    if let e=error{
                     //   print(e)
                        let alert = UIAlertController(title: "Alert", message: e.localizedDescription, preferredStyle: UIAlertController.Style.alert)

                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                        // show the alert
                        DispatchQueue.main.async {
                            self.hideLoading()
                            self.present(alert, animated: true, completion: nil)
                           }
                        
                    }else{
                        DispatchQueue.main.async {
                            self.hideLoading()
                            self.showMessage(msg: "OTP sent")
                            self.verificationId=verificationId ?? ""
                           }
                       
                    }
                     
                  }
                })
        }
    
    }
    @IBAction func onVeriify(_ sender: Any) {
        showLoading()
        
        if(login)
        {
            if(otp != ""){
                // Ask user for the SMS verification code.
                let credential = PhoneAuthProvider.provider().credential(
                    withVerificationID: self.verificationId,
                  verificationCode: otp)
                let assertion = PhoneMultiFactorGenerator.assertion(with: credential);
                // Complete sign-in.
                resolver.resolveSignIn(with: assertion) { (authResult, error) in
                  if error != nil {
                    DispatchQueue.main.async {
                        self.hideLoading()
                        self.showMessage(msg: error!.localizedDescription)
                       }
                   
                  }else{
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(true, forKey: "Verified")
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1 ){
                            self.hideLoading()
                     
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                        let newViewController = storyBoard.instantiateViewController(withIdentifier: "Home") as! UITabBarController
                        self.navigationController?.pushViewController(newViewController, animated: true)
                       }
                    }
                    
                  }
                }
            }else{
                self.hideLoading()
                self.showMessage(msg: "Please enter the OTP")
            }
            
        }else{
            if(otp != ""){
            let user = Auth.auth().currentUser
            let defaults = UserDefaults.standard
            let phone:String = defaults.string(forKey: "Phone") ?? ""
            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: self.verificationId,
                        verificationCode: otp)
                      let assertion = PhoneMultiFactorGenerator.assertion(with: credential)
                      
            user?.multiFactor.enroll(with: assertion, displayName: phone) { (error) in
                        if let e=error{
                         //   print(e)
                           
                            let alert = UIAlertController(title: "Alert", message: e.localizedDescription, preferredStyle: UIAlertController.Style.alert)

                            // add an action (button)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                            // show the alert
                          
                            DispatchQueue.main.async {
                                self.hideLoading()
                                self.present(alert, animated: true, completion: nil)
                               }
                        }else{
                            DispatchQueue.main.async {
                               
                                UserDefaults.standard.set(true, forKey: "Verified")
                           
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1 ){
                                    self.hideLoading()
                                    let storyBoard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                                let newViewController = storyBoard.instantiateViewController(withIdentifier: "Home") as! UITabBarController
                                self.navigationController?.pushViewController(newViewController, animated: true)
                                }
                               }
                           
                        
                        }
                      }
            }else{
                self.hideLoading()
                self.showMessage(msg: "Please enter the OTP")
            }
        }
    }
    func setupOtpView() {
               self.otpView.fieldsCount = 6
               self.otpView.fieldBorderWidth = 2
               self.otpView.defaultBorderColor = UIColor.black
               self.otpView.filledBorderColor = UIColor.green
               self.otpView.cursorColor = UIColor.red
               self.otpView.displayType = .underlinedBottom
               self.otpView.fieldSize = 40
               self.otpView.separatorSpace = 8
               self.otpView.shouldAllowIntermediateEditing = false
               self.otpView.otpInputType = .numeric
               self.otpView.delegate = self
              self.otpView.initializeUI()

           }
}


