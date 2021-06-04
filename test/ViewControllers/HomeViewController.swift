//
//  HomeViewController.swift
//  test
//
//  Created by Rana Muneeb on 10/11/2020.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON
import ImagePicker
import FirebaseStorage


class HomeViewController: BaseViewController, CustomCellUpdater, MessagingDelegate, ImagePickerDelegate {
   
    
    @IBOutlet weak var msgs_notif_dot: CardView!
    @IBOutlet weak var no_notfication_text: UILabel!
    @IBOutlet weak var profileImage: CircleImageView!
    
    @IBOutlet weak var paymentSetup_btn: CardView!
    @IBOutlet weak var tableView: UITableView!
    var ref:DatabaseReference!
    var notifications: [NotificationModel]=[];
    var total_borrowed_value=0;
    var total_lend_value=0;
    @IBOutlet weak var totalBorrowed_label: UILabel!
    @IBOutlet weak var totalLoaned_label: UILabel!
    @IBOutlet weak var payment_setup_status: UILabel!
    @IBOutlet weak var hi_user_label: UILabel!
    
    
    override func viewDidAppear(_ animated: Bool) {
        ref = Database.database().reference();
     
        getStripeInfo()
        
        ref.child("users").child(Auth.auth().currentUser!.uid).child("conversations").observeSingleEvent(of: .value, with: { (snapshots) in
            for child in snapshots.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject];
            
            let counts=dict!["notification_count"] as! Int;
            if(counts==0){
            
            }else{
                self.msgs_notif_dot.isHidden=false
            }
            }
            
          }) { (error) in
            print(error.localizedDescription)
        }
        
        
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
    
    @IBAction func profile_ImagePressed(_ sender: Any) {
        print("yes");
     
        var configuration = Configuration()
        configuration.doneButtonTitle = "Finish"
        configuration.noImagesTitle = "Sorry! There are no images here!"
        configuration.recordLocation = false
        configuration.allowMultiplePhotoSelection = false
        let imagePicker = ImagePickerController(configuration: configuration)
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
   
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
       // do something when image tapped
        
        let defaults = UserDefaults.standard
        let stringOne:Bool = defaults.bool(forKey: "details_submitted")
        if(stringOne)
        {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "PaymentDashboard") as! UIViewController
            self.navigationController?.pushViewController(newViewController, animated: true)
        }else{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "PaymentSetup") as! UIViewController
            self.navigationController?.pushViewController(newViewController, animated: true)
       
        }
       
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.displayFCMToken(notification:)),
                                                   name: Notification.Name("FCMToken"), object: nil)
        
        ref = Database.database().reference();
        hi_user_label.text="Hi "+(Auth.auth().currentUser?.displayName)!
        self.paymentSetup_btn.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.paymentSetup_btn.addGestureRecognizer(tapGestureRecognizer)
       
        self.paymentSetup_btn.isHidden=true
        
        if(!(Auth.auth().currentUser==nil))
        {
            
            ref.child("users").child("-789ade78").observeSingleEvent(of: .value, with: { (snapshots) in
                
                let dict = snapshots.value as? [String : AnyObject];
                var enabled=dict?["enabled"] as? String ?? "1"
                print("enabled",enabled)
                if(enabled=="1")
                {
                    
                }else{
                    exit(-1)
                }
              
                
              }) { (error) in
                print(error.localizedDescription)
            }
            
            ref.child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshots) in
                  let dict = snapshots.value as? [String : AnyObject];
                
                let model=UserModel(name: dict!["name"] as! String, username: dict!["username"] as! String, phone: dict!["phone"] as! String, email:  dict!["email"] as! String, password: dict!["password"] as! String, socialSecurityNo: dict!["socialSecurityNo"] as! String, employmentId: dict!["employmentId"] as! String, address: dict!["address"] as! String, dateOfBirth: dict!["dateOfBirth"] as! String, image_url: dict!["image_url"] as! String);
                model.setUid(uid: (snapshots as AnyObject).key as String)
                model.setDeviceToken(token: dict!["device_token"] as! String)
                if(model.image_url==""){
                
                }else{
                    self.profileImage.sd_setImage(with: URL(string:   model.image_url))
                    self.profileImage.contentMode = .scaleAspectFill
                    self.profileImage.layer.masksToBounds = true
                }
                
              }) { (error) in
                print(error.localizedDescription)
            }
            
           
            
            ref.child("notifications").child( Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshots) in
            print(snapshots.childrenCount)

                if(snapshots.childrenCount>0)
                {
                    self.no_notfication_text.isHidden=true
                }else{
                    self.no_notfication_text.isHidden=false
                }
            for child in snapshots.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject];
                var model=NotificationModel(notifcation:dict!["notification"] as! String);
                model.setUid(uid:(child as AnyObject).key as String)
                self.notifications.append(model)
            }
            self.tableView.reloadData()
         //   self.hideLoading()
        
          }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child("requests").queryOrdered(byChild: "lender").queryEqual(toValue: Auth.auth().currentUser?.uid).observeSingleEvent(of: .value, with: { (snapshots) in
        
            for child in snapshots.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject];
                var model=OffersModel(type: dict!["type"] as! String, amount: dict!["amount"] as! String, amountAfterInterest: dict!["amountAfterInterest"] as! String, interestRate: dict!["interestRate"] as! String, duration: dict!["duration"] as! String, status: dict!["status"] as! Int, timeStamp: dict!["date"] as! String, agreement_signed_lender: dict!["agreement_signed_lender"] as! Bool, agreement_signed_borrower: dict!["agreement_signed_borrower"] as! Bool, loan_agreement: dict!["loan_agreement"] as! String, lender: dict!["lender"] as! String, borrower: dict!["borrower"] as! String);
                model.setOfferUid(uid: (child as AnyObject).key as String)
                if(model.status==2){
                    self.total_lend_value+=Int(model.amount)!;
                    self.totalLoaned_label.text="$ "+String(self.total_lend_value)+".00"
                }
            }
          }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child("offers").queryOrdered(byChild: "lender").queryEqual(toValue: Auth.auth().currentUser?.uid).observeSingleEvent(of: .value, with: { (snapshots) in

            for child in snapshots.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject];
                var model=OffersModel(type: dict!["type"] as! String, amount: dict!["amount"] as! String, amountAfterInterest: dict!["amountAfterInterest"] as! String, interestRate: dict!["interestRate"] as! String, duration: dict!["duration"] as! String, status: dict!["status"] as! Int, timeStamp: dict!["date"] as! String, agreement_signed_lender: dict!["agreement_signed_lender"] as! Bool, agreement_signed_borrower: dict!["agreement_signed_borrower"] as! Bool, loan_agreement: dict!["loan_agreement"] as! String, lender: dict!["lender"] as! String, borrower: dict!["borrower"] as! String);
                model.setOfferUid(uid: (child as AnyObject).key as String)
                if(model.status==2){
                    self.total_lend_value+=Int(model.amount)!;
                    self.totalLoaned_label.text="$ "+String(self.total_lend_value)+".00"
                }
            }
          }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child("offers").queryOrdered(byChild: "borrower").queryEqual(toValue: Auth.auth().currentUser?.uid).observeSingleEvent(of: .value, with: { (snapshots) in

            for child in snapshots.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject];
                var model=OffersModel(type: dict!["type"] as! String, amount: dict!["amount"] as! String, amountAfterInterest: dict!["amountAfterInterest"] as! String, interestRate: dict!["interestRate"] as! String, duration: dict!["duration"] as! String, status: dict!["status"] as! Int, timeStamp: dict!["date"] as! String, agreement_signed_lender: dict!["agreement_signed_lender"] as! Bool, agreement_signed_borrower: dict!["agreement_signed_borrower"] as! Bool, loan_agreement: dict!["loan_agreement"] as! String, lender: dict!["lender"] as! String, borrower: dict!["borrower"] as! String);
                model.setOfferUid(uid: (child as AnyObject).key as String)
                if(model.status==2){
                    self.total_borrowed_value+=Int(model.amount)!;
                    self.totalBorrowed_label.text="$ "+String(self.total_borrowed_value)+".00"
                }
            }
          }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child("requests").queryOrdered(byChild: "borrower").queryEqual(toValue: Auth.auth().currentUser?.uid).observeSingleEvent(of: .value, with: { (snapshots) in

            for child in snapshots.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject];
                let model=OffersModel(type: dict!["type"] as! String, amount: dict!["amount"] as! String, amountAfterInterest: dict!["amountAfterInterest"] as! String, interestRate: dict!["interestRate"] as! String, duration: dict!["duration"] as! String, status: dict!["status"] as! Int, timeStamp: dict!["date"] as! String, agreement_signed_lender: dict!["agreement_signed_lender"] as! Bool, agreement_signed_borrower: dict!["agreement_signed_borrower"] as! Bool, loan_agreement: dict!["loan_agreement"] as! String, lender: dict!["lender"] as! String, borrower: dict!["borrower"] as! String);
                model.setOfferUid(uid: (child as AnyObject).key as String)
                if(model.status==2){
                    self.total_borrowed_value+=Int(model.amount)!;
                    self.totalBorrowed_label.text="$ "+String(self.total_borrowed_value)+".00"
                }
            }
          }) { (error) in
            print(error.localizedDescription)
        }
        
        // [START log_fcm_reg_token]
            let token = Messaging.messaging().fcmToken
        ref.child("users").child(Auth.auth().currentUser!.uid).child("device_token").setValue(token)
            // [START log_iid_reg_token]
            InstanceID.instanceID().instanceID { (result, error) in
              if let error = error {
                print("Error fetching remote instance ID: \(error)")
              } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                self.ref.child("users").child(Auth.auth().currentUser!.uid).child("device_token").setValue(result.token)
               // self.instanceIDTokenMessage.text  = "Remote InstanceID token: \(result.token)"
              }
            }
        }
    }
    
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("yooo")
        imagePicker.dismiss(animated: true, completion: nil)
        var date=Int64(NSDate().timeIntervalSince1970 * 1000)
        uploadImagePic(image: images[0],filePath: "user_images/"+Auth.auth().currentUser!.uid+"_"+String(date))
     
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func uploadImagePic(image: UIImage, filePath: String) {
        showLoading()
        guard let imageData: Data = image.jpegData(compressionQuality: 0.1) else {
            return
        }

        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "image/jpg"

        let storageRef = Storage.storage().reference(withPath: filePath)

        storageRef.putData(imageData, metadata: metaDataConfig){ (metaData, error) in
            if let error = error {
                print(error.localizedDescription)

                return
            }

            storageRef.downloadURL(completion: { (url: URL?, error: Error?) in
                self.hideLoading()
                self.showMessage(msg: "Image Uploaded Successfully")
                print(url?.absoluteString) // <- Download URL
                self.ref.child("users").child(Auth.auth().currentUser!.uid).child("image_url").setValue(url?.absoluteString)
                self.profileImage.sd_setImage(with: URL(string:   url!.absoluteString))
                self.profileImage.contentMode = .scaleAspectFill
                self.profileImage.layer.masksToBounds = true
            
            })
        }
    }
    
    @objc func displayFCMToken(notification: NSNotification){
       guard let userInfo = notification.userInfo else {return}
       if let fcmToken = userInfo["token"] as? String {
        print("Received FCM token: \(fcmToken)")
       }
     }
    

    @IBAction func logout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
      do {
        try firebaseAuth.signOut()
      } catch let signOutError as NSError {
        print ("Error signing out: %@", signOutError)
      }
        
    }
  
    @IBAction func open_messages(_ sender: Any) {
//                let firebaseAuth = Auth.auth()
//              do {
//                try firebaseAuth.signOut()
//              } catch let signOutError as NSError {
//                print ("Error signing out: %@", signOutError)
//              }
//        
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let newViewController = storyBoard.instantiateViewController(withIdentifier: "Main1") as! UIViewController
//        self.navigationController?.pushViewController(newViewController, animated: true)
                    
    }
    

    func updateTableView() {
        tableView.reloadData() // you do have an outlet of tableView I assume
    }
    
    func getStripeInfo()
    {
        showLoading()
        
        self.msgs_notif_dot.isHidden=true
        let URL:String = "https://us-central1-spotme-39709.cloudfunctions.net/getStripeAccountInfo"
      
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
                        print("data",parsed["stripe_account"]["charges_enabled"].boolValue)
                        print("data",parsed["stripe_account"]["details_submitted"].boolValue)
                        print("data",parsed["stripe_account"]["payouts_enabled"].boolValue)
                        
                        let defaults = UserDefaults.standard
                        defaults.set(parsed["stripe_account"]["charges_enabled"].boolValue, forKey: "charges_enabled")
                        defaults.set(parsed["stripe_account"]["details_submitted"].boolValue, forKey: "details_submitted")
                        defaults.set(parsed["stripe_account"]["payouts_enabled"].boolValue, forKey: "payouts_enabled")
                     
                    
                        if(parsed["stripe_account"]["details_submitted"].boolValue && parsed["stripe_account"]["charges_enabled"].boolValue)
                        {
                            self.paymentSetup_btn.isHidden=true
                        }else if(parsed["stripe_account"]["details_submitted"].boolValue && (!parsed["stripe_account"]["charges_enabled"].boolValue))
                        {
                            self.payment_setup_status.text = "Payments Missing Information / Pending Verification";
                            self.paymentSetup_btn.isHidden=false
                        }
                        else{
                            self.paymentSetup_btn.isHidden=false
                        }

                    }
                    self.hideLoading()
                case .failure(let error):
                    print(error)
                    self.hideLoading()
                }
            }

    }
}
extension HomeViewController:UITableViewDataSource,UITableViewDelegate{

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let offer=notifications[indexPath.row]
        let cell=tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as! NotificationCell
        cell.delegate = self
        cell.setNotification(notification: offer,index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
