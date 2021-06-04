//
//  OffersViewController.swift
//  test
//
//  Created by Rana Muneeb on 12/11/2020.
//

import UIKit
import Firebase

class BrowseLenderViewController: BaseViewController {
    var ref:DatabaseReference!
    @IBOutlet weak var backBtn: UIImageView!
    var deals: [RequestsModel]=[];
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noData_text: UILabel!
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(onBackPressed))
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(backTap)
        
        ref = Database.database().reference();
       
        
        showLoading()
        ref.child("universal_requests").observeSingleEvent(of: .value, with: { (snapshots) in
            print(snapshots.childrenCount)
            self.deals.removeAll()
            for child in snapshots.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject];
                var model=RequestsModel(type: dict!["type"] as! String, amount: dict!["amount"] as! String, amountAfterInterest: dict!["amountAfterInterest"] as! String, interestRate: dict!["interestRate"] as! String, duration: dict!["duration"] as! String, status: dict!["status"] as! Int, timeStamp: dict!["date"] as! String, agreement_signed_lender: dict!["agreement_signed_lender"] as! Bool, agreement_signed_borrower: dict!["agreement_signed_borrower"] as! Bool, loan_agreement: dict!["loan_agreement"] as! String, lender: dict!["lender"] as! String, borrower: dict!["borrower"] as! String);
                model.setOfferUid(uid: (child as AnyObject).key as String)
                model.setRequestMessage(msg: dict!["request_message"] as! String)
                if(model.status==0 || model.status==1){
                    if(!(model.borrower==Auth.auth().currentUser!.uid)){
                        self.noData_text.isHidden=true
                        self.deals.append(model)
                    }
                }
            }
    
            self.deals.reverse()
            self.hideLoading()
            self.tableView.reloadData()
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "MainToCounter2") {
            let vc = segue.destination as! CounterOfferViewController
            let offer_model=sender as! RequestsModel
            vc.type="request"
            vc.requestData = offer_model
            vc.previous_amount_value = offer_model.amount
            vc.previous_interest_value = offer_model.interestRate
            vc.previous_total_value = offer_model.amountAfterInterest
        }else if(segue.identifier == "RequestsToProfile")
        {
            let vc = segue.destination as! UserProfileUIViewController
            let user=sender as! UserModel
            vc.user = user
        
        }else if(segue.identifier == "BrowseToProfile")
        {
            let vc = segue.destination as! UserProfileUIViewController
            let user=sender as! UserModel
            vc.user = user
        
        }
    }
}

extension BrowseLenderViewController:UITableViewDataSource,UITableViewDelegate{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deals.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let offer=deals[indexPath.row]
        let cell=tableView.dequeueReusableCell(withIdentifier: "MyDealsBrowseCell",for: indexPath) as! MyDealsBrowseCell
        cell.setOffer(offer: offer,this: self,position: indexPath.row)
        cell.tag = indexPath.row
        return cell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

