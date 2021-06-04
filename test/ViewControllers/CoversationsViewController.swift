//
//  OffersViewController.swift
//  test
//
//  Created by Rana Muneeb on 12/11/2020.
//

import UIKit
import Firebase

class ConversationsViewController: BaseViewController {
    var ref:DatabaseReference!
    @IBOutlet weak var backBtn: UIImageView!
    var messaeges: [ThreadModel]=[];
    @IBOutlet weak var noData_text: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
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
    override func viewDidAppear(_ animated: Bool) {
                
        let backTap = UITapGestureRecognizer(target: self, action: #selector(onBackPressed))
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(backTap)
        
        ref = Database.database().reference();
       
        ref.child("users").child(Auth.auth().currentUser!.uid).child("conversations").observeSingleEvent(of: .value, with: { (snapshots) in
            print(snapshots.childrenCount)
            self.messaeges.removeAll()
            for child in snapshots.children.allObjects as! [DataSnapshot] {
                
                let dict = child.value as? [String : AnyObject];
                var model=ThreadModel(chat_with: dict!["chat_with"] as! String, last_message: dict!["last_message"] as! String,  notification_count: dict!["notification_count"] as! Int);
                model.setThreadId(uid: (child as AnyObject).key as String)
                
                self.noData_text.isHidden=true
                self.messaeges.append(model)
            }
            self.tableView.reloadData()
            self.hideLoading()

          }) { (error) in
            self.hideLoading()
            print(error.localizedDescription)
        }
    }
   
    @objc func onBackPressed() {
        print("yesss")
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
}
extension ConversationsViewController:UITableViewDataSource,UITableViewDelegate{

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     //   print(offers.count)
        return messaeges.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let offer=messaeges[indexPath.row]
        let cell=tableView.dequeueReusableCell(withIdentifier: "ThreadCell") as! ThreadCell
        cell.setData(model: offer,this: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}
