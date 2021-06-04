//
//  OffersCell.swift
//  test
//
//  Created by Rana Muneeb on 12/11/2020.
//

import UIKit
import Firebase
import SDWebImage

class UserNameCell: UITableViewCell {

    @IBOutlet weak var profile_image: CircleImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var name: UILabel!
    
    var ref:DatabaseReference!
    var uid:String = ""
    var this=UIViewController()
//    var user_model=UserModel
    
    func setUser(user:UserModel,this:UIViewController)
    {
        username.text=user.username
        name.text=user.name
        if(user.image_url==""){
        
        }else{
            self.profile_image.sd_setImage(with: URL(string: user.image_url))
            self.profile_image.contentMode = .scaleAspectFill
            self.profile_image.layer.masksToBounds = true
        }
      
    }
}


