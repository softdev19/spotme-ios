//
//  OffersCell.swift
//  test
//
//  Created by Rana Muneeb on 12/11/2020.
//

import UIKit
import Firebase
import SDWebImage

class ThreadCell: UITableViewCell {
    
    @IBOutlet weak var profile_image: CircleImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var last_message: UILabel!
    @IBOutlet weak var notif_card: CardView!
    @IBOutlet weak var notif_count_label: UILabel!
    @IBOutlet weak var cardView: CardView!
    var ref:DatabaseReference!
    var uid:String = ""
    var this=UIViewController()
    var selectedUser=UserModel()
    var model=ThreadModel()
    
    func setData(model:ThreadModel,this:UIViewController)
    {
        self.model=model
        last_message.text=model.last_message
        self.this=this
        
        if(model.notification_count==0)
        {
            notif_card.isHidden=true
        }else{
            notif_card.isHidden=false
            notif_count_label.text=String(model.notification_count)
        }
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(cameraTapped))
        cardView.isUserInteractionEnabled = true
        cardView.addGestureRecognizer(backTap)
        
        ref = Database.database().reference();
        ref.child("users").child(model.chat_with).observeSingleEvent(of: .value, with: { (snapshots) in
              let dict = snapshots.value as? [String : AnyObject];
            
            let model=UserModel(name: dict!["name"] as! String, username: dict!["username"] as! String, phone: dict!["phone"] as! String, email:  dict!["email"] as! String, password: dict!["password"] as! String, socialSecurityNo: dict!["socialSecurityNo"] as! String, employmentId: dict!["employmentId"] as! String, address: dict!["address"] as! String, dateOfBirth: dict!["dateOfBirth"] as! String, image_url: dict!["image_url"] as! String);
            model.setUid(uid: (snapshots as AnyObject).key as String)
            model.setDeviceToken(token: dict!["device_token"] as! String)
            self.selectedUser = model
        
            self.name.text = dict!["name"] as? String
            if(model.image_url==""){
            
            }else{
                self.profile_image.sd_setImage(with: URL(string:  model.image_url))
                self.profile_image.contentMode = .scaleAspectFill
                self.profile_image.layer.masksToBounds = true
            }
            
          }) { (error) in
            print(error.localizedDescription)
        }
        
//        if(model.image_url==""){
//
//        }else{
//            self.profile_image.sd_setImage(with: URL(string: user.image_url))
//            self.profile_image.contentMode = .scaleAspectFill
//            self.profile_image.layer.masksToBounds = true
//        }
        
       
    }
    
    @objc func cameraTapped() {
        print("yesss")
        let vc = SendMessageViewController(uid1: Auth.auth().currentUser!.uid, uid2: model.chat_with, thread_id_notification: model.thread_id,count:model.notification_count,selectedUser: self.selectedUser)
        self.this.navigationController!.pushViewController(vc, animated: true)
    }
}


