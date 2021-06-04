//
//  NotificationCell.swift
//  test
//
//  Created by Rana Muneeb on 12/12/2020.
//

import UIKit
import Firebase

class PaymentCardCell: UITableViewCell {
    
    @IBOutlet weak var brand_image: CircleImageView!
    @IBOutlet weak var card_no: UILabel!
    @IBOutlet weak var expiry: UILabel!
    @IBOutlet weak var cardView: CardView!
    
    func setData(data:CardsModel)
    {
        self.card_no.text="**** **** **** "+data.last4
        self.expiry.text="Expiry : "+data.exp_month+"/"+data.exp_year
       
    }

}
