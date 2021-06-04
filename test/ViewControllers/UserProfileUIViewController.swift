//
//  UserProfileUIViewController.swift
//  test
//
//  Created by Rana Muneeb on 17/12/2020.
//

import UIKit
import Firebase

class UserProfileUIViewController: BaseViewController {

    @IBOutlet weak var msg_card: CardView!
    var user:UserModel=UserModel()
    @IBOutlet weak var total_borrowed: UILabel!
    @IBOutlet weak var total_loaned: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phone_no: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var user_profile_image: UIImageView!
    @IBOutlet weak var borrower_rating: UILabel!
    @IBOutlet weak var lender_rating: UILabel!
    var ref:DatabaseReference!
    @IBOutlet weak var tableView: UITableView!
    var revies: [ReviewModel]=[];
    @IBOutlet weak var backBtn: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    override func viewWillDisappear(_ animated: Bool) {
        if #available(iOS 13, *)
              {
                  let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
                  statusBar.backgroundColor = #colorLiteral(red: 0.9796079993, green: 0.9797213674, blue: 0.9795572162, alpha: 1)
                  UIApplication.shared.keyWindow?.addSubview(statusBar)
              } else {
                 // ADD THE STATUS BAR AND SET A CUSTOM COLOR
                 let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
                 if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
                    statusBar.backgroundColor = #colorLiteral(red: 0.9796079993, green: 0.9797213674, blue: 0.9795572162, alpha: 1)
                 }
                 UIApplication.shared.statusBarStyle = .lightContent
              }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let msgTap = UITapGestureRecognizer(target: self, action: #selector(msgTapped))
        msg_card.isUserInteractionEnabled = true
        msg_card.addGestureRecognizer(msgTap)
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(cameraTapped))
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(backTap)
        
      //  showLoading()
        name.text=user.name
        username.text="@"+user.username
        phone_no.text=user.phone
        email.text=user.email
        if(user.image_url==""){
        
        }else{
            self.user_profile_image.sd_setImage(with: URL(string:   user.image_url))
            self.user_profile_image.contentMode = .scaleAspectFill
            self.user_profile_image.layer.masksToBounds = true
        }
        
//        showLoading()
        ref = Database.database().reference();
        
        var total_loaned_value:Int=0
        var total_borrowed_value:Int=0
        
        ref.child("requests").queryOrdered(byChild: "lender").queryEqual(toValue:user.uid).observeSingleEvent(of: .value, with: { (snapshots) in
           
            for child in snapshots.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject];
                var model=OffersModel(type: dict!["type"] as! String, amount: dict!["amount"] as! String, amountAfterInterest: dict!["amountAfterInterest"] as! String, interestRate: dict!["interestRate"] as! String, duration: dict!["duration"] as! String, status: dict!["status"] as! Int, timeStamp: dict!["date"] as! String, agreement_signed_lender: dict!["agreement_signed_lender"] as! Bool, agreement_signed_borrower: dict!["agreement_signed_borrower"] as! Bool, loan_agreement: dict!["loan_agreement"] as! String, lender: dict!["lender"] as! String, borrower: dict!["borrower"] as! String);
                model.setOfferUid(uid: (child as AnyObject).key as String)
                if(model.status==2){
                    total_loaned_value+=Int(model.amount)!
                }
            }
            self.total_loaned.text="$"+String(total_loaned_value)+".0"
        
          }) { (error) in
            self.hideLoading()
            print(error.localizedDescription)
        }

        
        ref.child("offers").queryOrdered(byChild: "lender").queryEqual(toValue: user.uid).observeSingleEvent(of: .value, with: { (snapshots) in
          
            for child in snapshots.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject];
                var model=OffersModel(type: dict!["type"] as! String, amount: dict!["amount"] as! String, amountAfterInterest: dict!["amountAfterInterest"] as! String, interestRate: dict!["interestRate"] as! String, duration: dict!["duration"] as! String, status: dict!["status"] as! Int, timeStamp: dict!["date"] as! String, agreement_signed_lender: dict!["agreement_signed_lender"] as! Bool, agreement_signed_borrower: dict!["agreement_signed_borrower"] as! Bool, loan_agreement: dict!["loan_agreement"] as! String, lender: dict!["lender"] as! String, borrower: dict!["borrower"] as! String);
                model.setOfferUid(uid: (child as AnyObject).key as String)
                if(model.status==2){
                    total_loaned_value+=Int(model.amount)!
                }
            }
            self.total_loaned.text="$"+String(total_loaned_value)+".0"
        
          }) { (error) in
            self.hideLoading()
            print(error.localizedDescription)
        }
        
        ref.child("offers").queryOrdered(byChild: "borrower").queryEqual(toValue: user.uid).observeSingleEvent(of: .value, with: { (snapshots) in
          
            for child in snapshots.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject];
                var model=OffersModel(type: dict!["type"] as! String, amount: dict!["amount"] as! String, amountAfterInterest: dict!["amountAfterInterest"] as! String, interestRate: dict!["interestRate"] as! String, duration: dict!["duration"] as! String, status: dict!["status"] as! Int, timeStamp: dict!["date"] as! String, agreement_signed_lender: dict!["agreement_signed_lender"] as! Bool, agreement_signed_borrower: dict!["agreement_signed_borrower"] as! Bool, loan_agreement: dict!["loan_agreement"] as! String, lender: dict!["lender"] as! String, borrower: dict!["borrower"] as! String);
                model.setOfferUid(uid: (child as AnyObject).key as String)
                if(model.status==2){
                    total_borrowed_value+=Int(model.amount)!
                }
            }
            self.total_borrowed.text="$"+String(total_borrowed_value)+".0"
        
          }) { (error) in
            self.hideLoading()
            print(error.localizedDescription)
        }
        
        
        ref.child("requests").queryOrdered(byChild: "borrower").queryEqual(toValue: user.uid).observeSingleEvent(of: .value, with: { (snapshots) in
           
            for child in snapshots.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject];
                var model=OffersModel(type: dict!["type"] as! String, amount: dict!["amount"] as! String, amountAfterInterest: dict!["amountAfterInterest"] as! String, interestRate: dict!["interestRate"] as! String, duration: dict!["duration"] as! String, status: dict!["status"] as! Int, timeStamp: dict!["date"] as! String, agreement_signed_lender: dict!["agreement_signed_lender"] as! Bool, agreement_signed_borrower: dict!["agreement_signed_borrower"] as! Bool, loan_agreement: dict!["loan_agreement"] as! String, lender: dict!["lender"] as! String, borrower: dict!["borrower"] as! String);
                model.setOfferUid(uid: (child as AnyObject).key as String)
                if(model.status==2){
                    total_borrowed_value+=Int(model.amount)!
                }
            }
            self.total_borrowed.text="$"+String(total_borrowed_value)+".0"
        
          }) { (error) in
            self.hideLoading()
            print(error.localizedDescription)
        }
        
        
        ref.child("reviews").child(user.uid).queryOrdered(byChild: "review_type").queryEqual(toValue: "lender").observeSingleEvent(of: .value, with: { (snapshots) in
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
                self.tableView.reloadData()
    
          }) { (error) in
            self.hideLoading()
            print(error.localizedDescription)
        }
        
        
        ref.child("reviews").child(user.uid).queryOrdered(byChild: "review_type").queryEqual(toValue: "borrower").observeSingleEvent(of: .value, with: { (snapshots) in
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
            self.tableView.reloadData()
           // self.hideLoading()
    
          }) { (error) in
            self.hideLoading()
            print(error.localizedDescription)
        }
        

    }
    
    @IBAction func onRequestPressed(_ sender: Any) {
    }
    @IBAction func onOfferPressed(_ sender: Any) {
    }
    @objc func cameraTapped() {
        print("yesss")
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func msgTapped() {
        print("yesss")
        let vc = SendMessageViewController(uid1: Auth.auth().currentUser!.uid, uid2:self.user.uid, thread_id_notification: "0",count:0,selectedUser: self.user)
        self.navigationController!.pushViewController(vc, animated: true)
    }

}
extension UserProfileUIViewController:UITableViewDataSource,UITableViewDelegate{

    
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
