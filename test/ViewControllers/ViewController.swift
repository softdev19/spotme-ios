//
//  ViewController.swift
//  test
//
//  Created by Rana Muneeb on 03/11/2020.
//

import UIKit
import Firebase

class ViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.\
        
        if Auth.auth().currentUser != nil {
            if(Auth.auth().currentUser!.isEmailVerified){
                let defaults = UserDefaults.standard
                print(defaults.bool(forKey: "Verified"))
                if(defaults.bool(forKey: "Verified")){
                    if(defaults.bool(forKey: "pin_enabled"))
                    {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3 ){
                        self.performSegue(withIdentifier: "toPin1", sender: nil)
                        }
                    }else{
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3 ){
                                let storyBoard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                                let newViewController = storyBoard.instantiateViewController(withIdentifier: "Home") as! UITabBarController
                                self.navigationController?.pushViewController(newViewController, animated: true)}
                    }
                }else{
                let firebaseAuth = Auth.auth()
                  do {
                    try firebaseAuth.signOut()
                  } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                  }
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3 ){
                            self.performSegue(withIdentifier: "loginPage", sender: nil)
                    }
            }
        }else{
                let firebaseAuth = Auth.auth()
                  do {
                    try firebaseAuth.signOut()
                  } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                  }
            
            let alert = UIAlertController(title: "Alert", message: "Please verify the link sent to your email & login again", preferredStyle: UIAlertController.Style.alert)

            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in
                self.performSegue(withIdentifier: "loginPage", sender: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
          
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3 ){
                self.performSegue(withIdentifier: "loginPage", sender: nil)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "OTPSeague1") {
            let vc = segue.destination as! OTPViewController
            let stataus=sender as! Bool
            vc.login=stataus
        }
    }
    
}

