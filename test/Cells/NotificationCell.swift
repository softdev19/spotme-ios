//
//  NotificationCell.swift
//  test
//
//  Created by Rana Muneeb on 12/12/2020.
//

import UIKit
import Firebase

class NotificationCell: UITableViewCell {
    
    weak var delegate: CustomCellUpdater?
    @IBOutlet weak var notification_txt: UILabel!
    var ref:DatabaseReference!
    var index=0;
    var notification=NotificationModel(notifcation: "")

    
    func setNotification(notification:NotificationModel,index:Int)
    {
        self.notification=notification
        ref = Database.database().reference();
        self.index=index;
        notification_txt.text=notification.notifcation
        
    }

    @IBAction func cleared_notif(_ sender: Any) {
        delegate?.showLoading()
        delegate?.notifications.remove(at: index)
        ref.child("notifications").child( Auth.auth().currentUser!.uid).child(notification.uid).removeValue()
        delegate?.updateTableView()
        delegate?.hideLoading()
    }
}
protocol CustomCellUpdater: HomeViewController { // the name of the protocol you can put any
    func updateTableView()
}
