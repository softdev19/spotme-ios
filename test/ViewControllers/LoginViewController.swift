//
//  LoginViewController.swift
//  test
//
//  Created by Rana Muneeb on 03/11/2020.
//

import UIKit
import Firebase

class LoginViewController: BaseViewController {

    @IBOutlet weak var email: EditText!
    @IBOutlet weak var password: EditText!
    var ref:DatabaseReference!
    var resolver:MultiFactorResolver!;
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference();

        
    }  

    @IBAction func loginPressed(_ sender: UIButton) {
       
        if(!email.hasText)
        {
            let alert = UIAlertController(title: "Alert", message: "Please enter an email", preferredStyle: UIAlertController.Style.alert)

            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

            // show the alert
            self.present(alert, animated: true, completion: nil)
        }else if(!password.hasText)
        {
            let alert = UIAlertController(title: "Alert", message: "Please enter your password", preferredStyle: UIAlertController.Style.alert)

            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

            // show the alert
            self.present(alert, animated: true, completion: nil)
        }else{
        
        if let email_st=email.text,let password_st=password.text {
            showLoading()
            
            Auth.auth().signIn(withEmail: email_st, password: password_st) { (authResultData, error) in
                let authError = error as NSError?
                print("error",authError?.code)
                var is_error=false
                if (authError == nil) {
              
                   // User is not enrolled with a second factor and is successfully signed in.
                   // ...
                    if(authError?.code != AuthErrorCode.secondFactorRequired.rawValue){
                        print("error1",authError?.code)
                        if(Auth.auth().currentUser!.isEmailVerified){
                            self.ref = Database.database().reference();
                            self.ref.child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshots) in
                                  let dict = snapshots.value as? [String : AnyObject];
                                
                                self.hideLoading()
                                
                            
                                let model=UserModel(name: dict!["name"] as! String, username: dict!["username"] as! String, phone: dict!["phone"] as! String, email:  dict!["email"] as! String, password: dict!["password"] as! String, socialSecurityNo: dict!["socialSecurityNo"] as! String, employmentId: dict!["employmentId"] as! String, address: dict!["address"] as! String, dateOfBirth: dict!["dateOfBirth"] as! String, image_url: dict!["image_url"] as! String);
                                model.setBlocked(blocked: dict!["blocked"] as? Int ?? 0)
                                model.setUid(uid: (snapshots as AnyObject).key as String)
                                model.setDeviceToken(token: dict!["device_token"] as? String ?? "")
                                
                                if(model.blocked==1)
                                {
                                    self.showMessage(msg: "User Blocked, Please contact customer support")
                                }else{
                                    UserDefaults.standard.set(dict!["email"] as! String, forKey: "Email")
                                    UserDefaults.standard.set(dict!["phone"] as! String, forKey: "Phone")
                                    self.performSegue(withIdentifier: "OTPSeague", sender: false)
//                                    let storyBoard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
//                                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "Home") as! UITabBarController
//                                    self.navigationController?.pushViewController(newViewController, animated: true)
                                }
                               
                              }) { (error) in
                                self.hideLoading()
                                print(error.localizedDescription)
                            }
                            
                            self.hideLoading()
                        }else{
                            self.hideLoading()
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2 ){
                                let alertController = UIAlertController(title: "Success", message: "Please verify the link sent to your email & try again", preferredStyle: .alert)
                                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                                    
                                })
                                    alertController.addAction(OKAction)
                                    self.navigationController?.present(alertController, animated: true, completion: nil)
                            }
                        
                        }
                        
                    }else{
                        print("error",authError?.localizedDescription)
            
                    }
                    
                }
              
                if let e=error{
                    print(e)
                    if(authError?.code == AuthErrorCode.secondFactorRequired.rawValue){
                    
                        self.resolver = authError!.userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                        self.performSegue(withIdentifier: "OTPSeague", sender: true)
                    }else{
                   
                        self.hideLoading()
                    let alert = UIAlertController(title: "Alert", message: e.localizedDescription, preferredStyle: UIAlertController.Style.alert)

                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            }else{
                print("inside")
                let alert = UIAlertController(title: "Alert", message: "Please enter an email", preferredStyle: UIAlertController.Style.alert)

                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "OTPSeague") {
            let vc = segue.destination as! OTPViewController
            let stataus=sender as! Bool
            vc.login=stataus
            vc.resolver=self.resolver;
        }
    }
}
