//
//  OffersCell.swift
//  test
//
//  Created by Rana Muneeb on 12/11/2020.
//

import UIKit
import Firebase

class ReviewsCell: UITableViewCell {
    
    @IBOutlet weak var profile_image: CircleImageView!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var username: UILabel!
    var ref:DatabaseReference!
    var uid:String = ""
   
    func setReview(offer:ReviewModel)
    {
        comment.text=offer.review
        if(offer.review_type=="lender")
        {
            
            type.text="Loaned"
            type.textColor=UIColor.systemOrange
        }else{
            
            type.text="Borrowed"
            type.textColor=UIColor.systemGreen
        }
        
        ref = Database.database().reference();
        ref.child("users").child(offer.review_by).observeSingleEvent(of: .value, with: { (snapshots) in
            if(snapshots.exists()){
              let dict = snapshots.value as? [String : AnyObject];
            
            let model=UserModel(name: dict!["name"] as! String, username: dict!["username"] as! String, phone: dict!["phone"] as! String, email:  dict!["email"] as! String, password: dict!["password"] as! String, socialSecurityNo: dict!["socialSecurityNo"] as! String, employmentId: dict!["employmentId"] as! String, address: dict!["address"] as! String, dateOfBirth: dict!["dateOfBirth"] as! String, image_url: dict!["image_url"] as! String);
            model.setUid(uid: (snapshots as AnyObject).key as String)
            model.setDeviceToken(token: dict!["device_token"] as! String)
         //   self.selectedUser = model
            
            self.username.text="(@"
            self.username.text!.append(dict!["username"] as! String)
            self.username.text!.append(") ")
            self.username.text!.append(dict!["name"] as! String)
            
            if(model.image_url==""){
            
            }else{
                self.profile_image.sd_setImage(with: URL(string:   model.image_url))
                self.profile_image.contentMode = .scaleAspectFill
                self.profile_image.layer.masksToBounds = true
                }
            }
          }) { (error) in
            print(error.localizedDescription)
        }
    
    }

}
