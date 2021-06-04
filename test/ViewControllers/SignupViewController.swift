//
//  SignupViewController.swift
//  test
//
//  Created by Rana Muneeb on 03/11/2020.
//

import UIKit
import Firebase
import DatePickerDialog
import Alamofire
import SwiftyJSON
import CountryPickerView

class SignupViewController: BaseViewController,UITextFieldDelegate,CountryPickerViewDelegate, CountryPickerViewDataSource {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        country_code=country.phoneCode;
        print(country_code)
    }
    
    var country_code="+1"
    @IBOutlet weak var name: EditText!
    @IBOutlet weak var username: EditText!
    @IBOutlet weak var phone: EditText!
    @IBOutlet weak var email: EditText!
    @IBOutlet weak var password: EditText!
    @IBOutlet weak var confirmPassword: EditText!
    @IBOutlet weak var address: EditText!
    @IBOutlet weak var address2: EditText!
    @IBOutlet weak var zipcode: EditText!
    @IBOutlet weak var city: EditText!
    var ref: DatabaseReference!
    @IBOutlet weak var state: EditText!
    @IBOutlet weak var dateOf_birth: EditText!
    var username_available:Bool=true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        username.delegate = self
        username.addTarget(self, action: #selector(LendMoneyViewController.textFieldDidChange(_:)),
                                  for: .editingChanged)
        
        let cpv = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 15))
        cpv.delegate=self
        cpv.dataSource=self
        cpv.showCountryCodeInView=false
        phone.leftView = cpv
        phone.leftView?.layer.sublayerTransform = CATransform3DMakeTranslation(20.0, 0.0, 0.0);
  //      phone.leftView?.frame = CGRect(x: 0.0, y: 0.0, width: (phone.leftView!.frame.width) + 20.0, height: (phone.leftView!.frame.height))
        phone.leftViewMode = .always
        
      }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if(textField.text?.count ?? 0>1)
        {
            print("yess")

            ref = Database.database().reference();
            ref.child("users").queryOrdered(byChild: "username").queryEqual(toValue: textField.text).observeSingleEvent(of: .value, with: { (snapshots) in
                if(snapshots.exists()){
                for child in snapshots.children.allObjects as! [DataSnapshot] {
                    self.username_available = false;
                }
                    self.username.textColor = .systemRed
                }else{
                    self.username_available = true;
                    self.username.textColor = .systemGreen
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }else{
        
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

    if string == " " {
        return false
    }
    return true
    }
    
    @IBAction func signup(_ sender: Any) {
        
        if(!name.hasText)
        {
            showAlert(messasg: "Please enter your full name")
        }else if(!username.hasText)
        {
            showAlert(messasg: "Please enter username")
        }else if(!username_available)
        {
            showAlert(messasg: "This username is already taken")
        }else if(!phone.hasText)
        {
            showAlert(messasg: "Please enter phone number")
        }else if(!email.hasText)
        {
            showAlert(messasg: "Please enter email")
        }else if(!password.hasText)
        {
            showAlert(messasg: "Please enter password")
        }else if(!confirmPassword.hasText)
        {
            showAlert(messasg: "PLease enter confirm password")
        }else if(username.text!==confirmPassword.text)
        {
            showAlert(messasg: "Password don't match")
        }else{
        
            showLoading()
        if let email_st=email.text,let password_st=password.text {
        Auth.auth().createUser(withEmail: email_st, password: password_st) { (authResultData, error) in
            if let e=error{
                self.showAlert(messasg: e.localizedDescription)
            }else{
                
                let actionCodeSettings = ActionCodeSettings()
                actionCodeSettings.url = URL(string: "https://us-central1-spotme-39709.cloudfunctions.net/loginEmailLink?uid="+Auth.auth().currentUser!.uid)
                // The sign-in operation has to always be completed in the app.
                actionCodeSettings.handleCodeInApp = true
                actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
                actionCodeSettings.setAndroidPackageName("com.munib.spotme",
                                                         installIfNotAvailable: true, minimumVersion: "12")
               
                Auth.auth().sendSignInLink(toEmail:email_st,
                                           actionCodeSettings: actionCodeSettings) { error in
                 
                    if let error = error {
                            print(error.localizedDescription)
                          self.showMessage(msg: error.localizedDescription)
                          return
                        }
                    
                    UserDefaults.standard.set(email_st, forKey: "Email")
                    UserDefaults.standard.set(self.country_code+self.phone.text!, forKey: "Phone")
                   
                    let currentDate = Date()
                    let since1970 = currentDate.timeIntervalSince1970
                    let timez = Int(since1970 * 1000)
                    
                    var data=["name": self.name.text!, "username": self.username.text!, "phone": self.country_code+self.phone.text!, "email": self.email.text!, "password": self.password.text!, "socialSecurityNo": "", "employmentId": "", "address": self.address.text!,"address2": self.address2.text!,"zip": self.zipcode.text!,"city": self.city.text!,"state": self.state.text!, "dateOfBirth": self.dateOf_birth.text!,"image_url":"","created_date":String(timez)]

                    self.ref.child("users").child(Auth.auth().currentUser!.uid).setValue(data)
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = self.name.text!
                    changeRequest?.commitChanges { (error) in
                    
                        }
                    self.makeStripeAccount()
                    }
                }
            }
        }
    }
        
    }
    
    @IBAction func showDateOfBirthPicker(_ sender: Any) {
        print("inside")
    
        
        DatePickerDialog().show("Date of birth", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) { date in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyyy"
                self.dateOf_birth.text = formatter.string(from: dt)
            }
        }
    }
    func showAlert(messasg:String)
    {
        let alert = UIAlertController(title: "Alert", message: messasg, preferredStyle: UIAlertController.Style.alert)

        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func makeStripeAccount()
    {
        let URL:String = "https://us-central1-spotme-39709.cloudfunctions.net/createAccount"
      
      //  let headers  :HTTPHeaders  = [ "Content-Type" : "application/json", "Authorization": serverKey]
        print("id",Auth.auth().currentUser?.uid)
        let para = [ "user_id" : Auth.auth().currentUser?.uid] as [String : Any]
        AF.request(URL, method: .post, parameters: para, encoding: JSONEncoding.default, headers : nil)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                
                    let json=JSON(value)
                    let parsed=JSON(parseJSON:json["data"].stringValue)
                    if(parsed["Error"].boolValue)
                    {
                        
                    }else{
//                        let storyBoard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
//                        let newViewController = storyBoard.instantiateViewController(withIdentifier: "Home") as! UITabBarController
//                        self.navigationController?.pushViewController(newViewController, animated: true)
                        
                    }
                    self.hideLoading()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2 ){
                        let alertController = UIAlertController(title: "Success", message: "Email sent! Please verify the link sent to your email", preferredStyle: .alert)
                            let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                            self.navigationController?.popViewController(animated: true)
                        })
                            alertController.addAction(OKAction)
                            self.navigationController?.present(alertController, animated: true, completion: nil)
                    }
                  
                case .failure(let error):
                    print(error)
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "Main1") as! UIViewController
                    self.navigationController?.pushViewController(newViewController, animated: true)
                    self.hideLoading()
                }

        }
    }


}
