//
//  DialogProposedPaymentsViewController.swift
//  test
//
//  Created by Rana Muneeb on 19/11/2020.
//

import UIKit
import Firebase
import WebKit
import Alamofire
import SwiftyJSON

class MyProfileViewController: BaseViewController {

    @IBOutlet weak var pin_switch: UISwitch!
    @IBOutlet weak var tableview: UITableView!
    var ref:DatabaseReference!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profile_image: CircleImageView!
    @IBOutlet weak var lender_rating: UILabel!
    @IBOutlet weak var borrower_rating: UILabel!
    var revies: [ReviewModel]=[];
    var currentUser:UserModel=UserModel()
    
    override func viewDidAppear(_ animated: Bool) {
       if #available(iOS 13, *)
              {
                  let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
                  statusBar.backgroundColor = #colorLiteral(red: 0.3431670666, green: 0.9492903352, blue: 0.5059015751, alpha: 1)
                  UIApplication.shared.keyWindow?.addSubview(statusBar)
              } else {
                 // ADD THE STATUS BAR AND SET A CUSTOM COLOR
                 let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
                 if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
                    statusBar.backgroundColor = #colorLiteral(red: 0.3431670666, green: 0.9492903352, blue: 0.5059015751, alpha: 1)
                 }
                 UIApplication.shared.statusBarStyle = .lightContent
              }
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference();
       
        var total_loaned_value:Int=0
        var total_borrowed_value:Int=0
        
        let defaults = UserDefaults.standard
        let switch_on:Bool = defaults.bool(forKey: "pin_enabled") 
        
        pin_switch.setOn(switch_on, animated: false)
        
        ref.child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshots) in
            let dict = snapshots.value as? [String : AnyObject];
            let model=UserModel(name: dict!["name"] as! String, username: dict!["username"] as! String, phone: dict!["phone"] as! String, email:  dict!["email"] as! String, password: dict!["password"] as! String, socialSecurityNo: dict!["socialSecurityNo"] as! String, employmentId: dict!["employmentId"] as! String, address: dict!["address"] as! String, dateOfBirth: dict!["dateOfBirth"] as! String, image_url: dict!["image_url"] as! String);
            model.setUid(uid: (snapshots as AnyObject).key as String)
            self.currentUser = model
            self.username.text="(@"
            self.username.text!.append(dict!["username"] as! String)
            self.username.text!.append(") ")
            self.name.text=(dict!["name"] as! String)
            if(self.currentUser.image_url==""){
            
            }else{
                self.profile_image.sd_setImage(with: URL(string:   self.currentUser.image_url))
                self.profile_image.contentMode = .scaleAspectFill
                self.profile_image.layer.masksToBounds = true
            }
          }) { (error) in
            print(error.localizedDescription)
        }
        

        ref.child("reviews").child(Auth.auth().currentUser!.uid).queryOrdered(byChild: "review_type").queryEqual(toValue: "lender").observeSingleEvent(of: .value, with: { (snapshots) in
            print(snapshots.childrenCount)
            var a:Int=0;
            for child in snapshots.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject];
                let model=ReviewModel(review: dict!["review"] as! String, type: dict!["review_type"] as! String, review_by: dict!["review_by"] as! String, rating: dict!["rating"] as! Double);
                a += Int(model.rating)
                self.revies.append(model)
            }
            if(a==0) {
                self.lender_rating.text=String("N/A")
            } else
            {
                let lender_rating_value = a/Int(snapshots.childrenCount)
                self.lender_rating.text=String(lender_rating_value)
        
            }
                self.tableview.reloadData()
    
          }) { (error) in
            self.hideLoading()
            print(error.localizedDescription)
        }
        
        
        ref.child("reviews").child(Auth.auth().currentUser!.uid).queryOrdered(byChild: "review_type").queryEqual(toValue: "borrower").observeSingleEvent(of: .value, with: { (snapshots) in
            print(snapshots.childrenCount)
            var a:Int=0
            for child in snapshots.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject];
                let model=ReviewModel(review: dict!["review"] as! String, type: dict!["review_type"] as! String, review_by: dict!["review_by"] as! String, rating: dict!["rating"] as! Double);
                a += Int(model.rating)
                self.revies.append(model)
            }
            if(a==0) {
                self.borrower_rating.text=String("N/A")
            } else
            {
                let lender_rating_value = a/Int(snapshots.childrenCount)
                self.borrower_rating.text=String(lender_rating_value)
        
            }
            self.tableview.reloadData()
           // self.hideLoading()
    
          }) { (error) in
            self.hideLoading()
            print(error.localizedDescription)
        }
        
    }    
    @IBAction func onPinClicked(_ sender: Any) {
//        pin_switch.setOn(!pin_switch.isOn, animated: true)
//        if(pin_switch.isOn)
//        {
//            self.performSegue(withIdentifier: "toPIN", sender: nil)
//        }else{
//            UserDefaults.standard.set(false, forKey: "pin_enabled")
//        }
    }
    
    @IBAction func onSwitchChanged(_ sender: Any) {
        if(pin_switch.isOn)
        {
            self.performSegue(withIdentifier: "toPIN", sender: nil)
        }else{
            UserDefaults.standard.set(false, forKey: "pin_enabled")
        }
    }
    @IBAction func onlogout(_ sender: Any) {
        // create the alert
               let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: UIAlertController.Style.alert)

               // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Logout", style: UIAlertAction.Style.default, handler: {(action) in
               
            let firebaseAuth = Auth.auth()
              do {
                try firebaseAuth.signOut()
              } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
              }

            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "Main1") as! UIViewController
            self.navigationController?.pushViewController(newViewController, animated: true)
        }))
               alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
               // show the alert
               self.present(alert, animated: true, completion: nil)
    }
}

extension MyProfileViewController:UITableViewDataSource,UITableViewDelegate{

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("reviews",revies.count)
        return revies.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let offer=revies[indexPath.row]
        let cell=tableView.dequeueReusableCell(withIdentifier: "ReviewsCell") as! ReviewsCell
        cell.setReview(offer: offer)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

