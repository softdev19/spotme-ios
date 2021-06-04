//
//  OffersViewController.swift
//  test
//
//  Created by Rana Muneeb on 12/11/2020.
//

import UIKit
import Firebase

class OffersViewController: BaseViewController {
    @IBOutlet weak var noData_text: UILabel!
    var ref:DatabaseReference!
    @IBOutlet weak var tableView: UITableView!
    var offers: [OffersModel]=[];

    override func viewDidAppear(_ animated: Bool) {
        showLoading()
        ref = Database.database().reference();
       
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
        
        ref.child("offers").queryOrdered(byChild: "borrower").queryEqual(toValue: Auth.auth().currentUser?.uid).observeSingleEvent(of: .value, with: { (snapshots) in
            print(snapshots.childrenCount)
            self.offers.removeAll()
            for child in snapshots.children.allObjects as! [DataSnapshot] {
              
                let dict = child.value as? [String : AnyObject];
                var model=OffersModel(type: dict!["type"] as! String, amount: dict!["amount"] as! String, amountAfterInterest: dict!["amountAfterInterest"] as! String, interestRate: dict!["interestRate"] as! String, duration: dict!["duration"] as! String, status: dict!["status"] as! Int, timeStamp: dict!["date"] as! String, agreement_signed_lender: dict!["agreement_signed_lender"] as! Bool, agreement_signed_borrower: dict!["agreement_signed_borrower"] as! Bool, loan_agreement: dict!["loan_agreement"] as! String, lender: dict!["lender"] as! String, borrower: dict!["borrower"] as! String);
                model.setOfferUid(uid: (child as AnyObject).key as String)
                if(model.status==0 || model.status==1){
                    self.noData_text.isHidden=true
                    self.offers.append(model)
                }
            }
            self.tableView.reloadData()
            self.hideLoading()
        
          }) { (error) in
            self.hideLoading()
            print(error.localizedDescription)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "MainToCounter") {
            let vc = segue.destination as! CounterOfferViewController
            let offer_model=sender as! OffersModel
            vc.type="offer"
            vc.offersData = offer_model
            vc.previous_amount_value = offer_model.amount
            vc.previous_interest_value = offer_model.interestRate
            vc.previous_total_value = offer_model.amountAfterInterest
        }else if(segue.identifier == "OffersToProfile")
        {
            let vc = segue.destination as! UserProfileUIViewController
            let user=sender as! UserModel
            vc.user = user
        
        }
    }
}
extension OffersViewController:UITableViewDataSource,UITableViewDelegate{

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     //   print(offers.count)
        return offers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let offer=offers[indexPath.row]
        let cell=tableView.dequeueReusableCell(withIdentifier: "OffersCell") as! OffersCell
        cell.setOffer(offer: offer,this: self,position: indexPath.row)
        cell.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


