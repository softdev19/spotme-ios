//
//  MyDealsViewController.swift
//  test
//
//  Created by Rana Muneeb on 17/11/2020.
//

import UIKit
import Firebase

class MyDealsViewController: BaseViewController {
    var ref:DatabaseReference!
    @IBOutlet weak var tableViewPending: UITableView!
    @IBOutlet weak var tableView: UITableView!
    var deals: [MyDealsModel]=[];
    @IBOutlet weak var noData_text: UILabel!
   
    override func viewDidAppear(_ animated: Bool) {
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
        }else if(segue.identifier == "DealsToProfile")
        {
            let vc = segue.destination as! UserProfileUIViewController
            let user=sender as! UserModel
            vc.user = user
        
        }else if (segue.identifier == "LoanPay1") {
            
            let vc = segue.destination as! PayLoanViewController
            let model=sender as! [String: AnyObject]
            vc.offer_id=model["offer_id"] as! String
            vc.user_id = model["user_id"] as! String
            vc.currentUser = model["currentUser"] as! String
            vc.navigationControllers = self.navigationController!
            if(model["type"] as! String == "lend")
            {
                vc.type = "offers"
            }else{
                vc.type = "requests"
            }
           
            vc.token = model["token"] as! String
            vc.loan_agreement = model["loan_agreement"] as! String
            vc.amount = model["amount"] as! String
            
            print("data",model)
            
        }else if (segue.identifier == "LoanPay2") {
            
            let vc = segue.destination as! PayLoanInstallmentViewController
            
            let model=sender as! [String: AnyObject]
            vc.payment_id=model["payment_id"] as! String
            vc.user_id = model["user_id"] as! String
            vc.amount=model["amount"] as! String
            vc.currentUser = model["currentUser"] as! String
            vc.navigationControllers = self.navigationController!
            vc.token = model["token"] as! String
            vc.index = model["index"] as! String
            
            print("data",model)
            
        }
    }
    
    @IBAction func onFragmentChange(_ sender: UISegmentedControl) {
      
        switch sender.selectedSegmentIndex {
        case 0:
            print("test",0)
            self.noData_text.isHidden=false
            loadPendingData()
            break;
        case 1:
            self.noData_text.isHidden=false
            loadLoanedData()
            break;
        case 2:
            self.noData_text.isHidden=false
            loadBorrowedData()
            break;
        default:
           // loadPendingData()
            break;
        }
        
    }
    
    func loadBorrowedData(){
        self.tableView.isHidden=true
        self.tableViewPending.isHidden=true
        self.showLoading()
        self.deals.removeAll()
        self.tableViewPending.reloadData()
        self.tableView.reloadData()
        
        ref.child("requests").queryOrdered(byChild: "borrower").queryEqual(toValue: Auth.auth().currentUser?.uid).observeSingleEvent(of: .value, with: { (snapshots) in
            print(snapshots.childrenCount)

            for child in snapshots.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject];
                let model=MyDealsModel(type: "borrow", amount: dict!["amount"] as! String, amountAfterInterest: dict!["amountAfterInterest"] as! String, interestRate: dict!["interestRate"] as! String, duration: dict!["duration"] as! String, status: dict!["status"] as! Int, timeStamp: dict!["date"] as! String, agreement_signed_lender: dict!["agreement_signed_lender"] as! Bool, agreement_signed_borrower: dict!["agreement_signed_borrower"] as! Bool, loan_agreement: dict!["loan_agreement"] as! String, lender: dict!["lender"] as! String, borrower: dict!["borrower"] as! String,reported: dict?["reported"] as? Int ?? 0)
                model.setOfferUid(uid: (child as AnyObject).key as String)
                if(model.status==2){
                    self.noData_text.isHidden=true
                self.deals.append(model);
                }
                
            }
        
        
          }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child("offers").queryOrdered(byChild: "borrower").queryEqual(toValue: Auth.auth().currentUser?.uid).observeSingleEvent(of: .value, with: { (snapshots) in
            print(snapshots.childrenCount)

            for child in snapshots.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject];
                let model=MyDealsModel(type: "borrow", amount: dict!["amount"] as! String, amountAfterInterest: dict!["amountAfterInterest"] as! String, interestRate: dict!["interestRate"] as! String, duration: dict!["duration"] as! String, status: dict!["status"] as! Int, timeStamp: dict!["date"] as! String, agreement_signed_lender: dict!["agreement_signed_lender"] as! Bool, agreement_signed_borrower: dict!["agreement_signed_borrower"] as! Bool, loan_agreement: dict!["loan_agreement"] as! String, lender: dict!["lender"] as! String, borrower: dict!["borrower"] as! String,reported: dict?["reported"] as? Int ?? 0)
                model.setOfferUid(uid: (child as AnyObject).key as String)
                if(model.status==2){
                    self.noData_text.isHidden=true
                self.deals.append(model);
                }
                
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3 ){
                self.hideLoading()
                self.tableView.isHidden=false
                self.tableViewPending.isHidden=true
                self.tableView.reloadData()
            }
        
          }) { (error) in
            print(error.localizedDescription)
        }
    }
    func loadLoanedData()
    {
        self.tableView.isHidden=true
        self.tableViewPending.isHidden=true
        self.showLoading()
        self.deals.removeAll()
        self.tableViewPending.reloadData()
        self.tableView.reloadData()
       
        ref.child("requests").queryOrdered(byChild: "lender").queryEqual(toValue: Auth.auth().currentUser?.uid).observeSingleEvent(of: .value, with: { (snapshots) in
            print(snapshots.childrenCount)

            for child in snapshots.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject];
                let model=MyDealsModel(type: "lend", amount: dict!["amount"] as! String, amountAfterInterest: dict!["amountAfterInterest"] as! String, interestRate: dict!["interestRate"] as! String, duration: dict!["duration"] as! String, status: dict!["status"] as! Int, timeStamp: dict!["date"] as! String, agreement_signed_lender: dict!["agreement_signed_lender"] as! Bool, agreement_signed_borrower: dict!["agreement_signed_borrower"] as! Bool, loan_agreement: dict!["loan_agreement"] as! String, lender: dict!["lender"] as! String, borrower: dict!["borrower"] as! String,reported: dict?["reported"] as? Int ?? 0)
                model.setOfferUid(uid: (child as AnyObject).key as String)
                if(model.status==2) {
                    self.noData_text.isHidden=true
                    self.deals.append(model);
                }
            }
        
          }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child("offers").queryOrdered(byChild: "lender").queryEqual(toValue: Auth.auth().currentUser?.uid).observeSingleEvent(of: .value, with: { (snapshots) in
            print(snapshots.childrenCount)

            for child in snapshots.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject];
                let model=MyDealsModel(type: "lend", amount: dict!["amount"] as! String, amountAfterInterest: dict!["amountAfterInterest"] as! String, interestRate: dict!["interestRate"] as! String, duration: dict!["duration"] as! String, status: dict!["status"] as! Int, timeStamp: dict!["date"] as! String, agreement_signed_lender: dict!["agreement_signed_lender"] as! Bool, agreement_signed_borrower: dict!["agreement_signed_borrower"] as! Bool, loan_agreement: dict!["loan_agreement"] as! String, lender: dict!["lender"] as! String, borrower: dict!["borrower"] as! String,reported: dict?["reported"] as? Int ?? 0)
                model.setOfferUid(uid: (child as AnyObject).key as String)
                if(model.status==2) {
                    self.noData_text.isHidden=true
                    self.deals.append(model);
                }
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3 ){
                self.hideLoading()
                self.tableView.isHidden=false
                print("testing",self.deals.count)
                self.tableViewPending.isHidden=true
                self.tableView.reloadData()
            }
        
          }) { (error) in
            print(error.localizedDescription)
        }
    }

    func loadPendingData()
    {
        self.tableView.isHidden=true
        self.tableViewPending.isHidden=true
        self.showLoading()
        self.deals.removeAll()
        self.tableViewPending.reloadData()
        self.tableView.reloadData()
      
        ref.child("offers").queryOrdered(byChild: "lender").queryEqual(toValue: Auth.auth().currentUser?.uid).observeSingleEvent(of: .value, with: { (snapshots) in
            print(snapshots.childrenCount)

            for child in snapshots.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject];
                let model=MyDealsModel(type: "lend", amount: dict!["amount"] as! String, amountAfterInterest: dict!["amountAfterInterest"] as! String, interestRate: dict!["interestRate"] as! String, duration: dict!["duration"] as! String, status: dict!["status"] as! Int, timeStamp: dict!["date"] as! String, agreement_signed_lender: dict!["agreement_signed_lender"] as! Bool, agreement_signed_borrower: dict!["agreement_signed_borrower"] as! Bool, loan_agreement: dict!["loan_agreement"] as! String, lender: dict!["lender"] as! String, borrower: dict!["borrower"] as! String,reported: dict?["reported"] as? Int ?? 0)
                model.setOfferUid(uid: (child as AnyObject).key as String)
                if(model.status==0 || model.status==1) {
                    self.noData_text.isHidden=true
                    self.deals.append(model);
                }
            }
    
        }) { (error) in
            print(error.localizedDescription)
        }
    
        ref.child("requests").queryOrdered(byChild: "borrower").queryEqual(toValue: Auth.auth().currentUser?.uid).observeSingleEvent(of: .value, with: { (snapshots) in
        print(snapshots.childrenCount)

        for child in snapshots.children.allObjects as! [DataSnapshot] {
            let dict = child.value as? [String : AnyObject];
            let model=MyDealsModel(type: "borrow", amount: dict!["amount"] as! String, amountAfterInterest: dict!["amountAfterInterest"] as! String, interestRate: dict!["interestRate"] as! String, duration: dict!["duration"] as! String, status: dict!["status"] as! Int, timeStamp: dict!["date"] as! String, agreement_signed_lender: dict!["agreement_signed_lender"] as! Bool, agreement_signed_borrower: dict!["agreement_signed_borrower"] as! Bool, loan_agreement: dict!["loan_agreement"] as! String, lender: dict!["lender"] as! String, borrower: dict!["borrower"] as! String,reported: dict?["reported"] as? Int ?? 0)
            model.setOfferUid(uid: (child as AnyObject).key as String)
            if(model.status==0 || model.status==1) {
                self.noData_text.isHidden=true
                self.deals.append(model);
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3 ){
            self.hideLoading()
            self.tableView.isHidden=true
            self.tableViewPending.isHidden=false
            self.tableViewPending.reloadData()
            
        }
    
      }) { (error) in
        print(error.localizedDescription)
        }
    }

    
}

extension MyDealsViewController:UITableViewDataSource,UITableViewDelegate{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            print("test",deals.count)
            return deals.count
            }
        else if tableView == self.tableViewPending {
            print("test","pending")
            return deals.count
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableView {
            print("test","not pending1")
            let offer=deals[indexPath.row]
            let cell=tableView.dequeueReusableCell(withIdentifier: "MyDealsCell",for: indexPath) as! MyDealsCell
            cell.setOffer(offer: offer,this: self,position: indexPath.row)
            cell.tag = indexPath.row
            return cell
            }
        else if tableView == self.tableViewPending {
            print("test","pending1")
            let offer=deals[indexPath.row]
            let cell=tableView.dequeueReusableCell(withIdentifier: "MyDealsPendingCell",for: indexPath) as! MyDealsPendingCell
            cell.setOffer(offer: offer,this: self,position: indexPath.row)
            cell.tag = indexPath.row
            return cell
        }else{
            let offer=deals[indexPath.row]
            let cell=tableView.dequeueReusableCell(withIdentifier: "MyDealsCell",for: indexPath) as! MyDealsCell
            cell.setOffer(offer: offer,this: self,position: indexPath.row)
            cell.tag = indexPath.row
            return cell
        }
       
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
