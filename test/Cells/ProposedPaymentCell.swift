//
//  OffersCell.swift
//  test
//
//  Created by Rana Muneeb on 12/11/2020.
//

import UIKit
import Firebase

class ProposedPaymentCell: UITableViewCell {
    
    @IBOutlet weak var index: UILabel!
    @IBOutlet weak var dueDate: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var status: UILabel!
    let cardView = UIView()
    var ref:DatabaseReference!
    var uid:String = ""
   
    
   
    func setOffer(offer:PropsedMoneyModel)
    {
        index.text=String(offer.index)
        month.text=offer.month
        var int_value=Int(offer.amount)
        amount.text="$"+String(int_value)+".00"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE MMM dd HH:mm:ss ZZZ yyyy"
        let date = dateFormatter.date(from: offer.due_date)
        let currentDateTime = Date()
        dateFormatter.dateFormat="dd-MMM-yyyy"
        dueDate.text=dateFormatter.string(from: date!)
        if(offer.showStatus)
        {
            if(offer.status==0)
            {
                if(currentDateTime<date!){
                    status.text="Pending"
                }else{
                    status.text="Late"
                    status.textColor=UIColor.red
                }
                
            }else{
                status.textColor=UIColor.systemGreen
                status.text="Paid"
            }
        }else{
            status.isHidden=true
        }
    }

}
