//
//  LendMoneyViewController.swift
//  test
//
//  Created by Rana Muneeb on 30/11/2020.
//

import UIKit
import Firebase
import iOSDropDown

class RequestMoneyViewController: BaseViewController {

    let suggestionsArray = [ "black", "blue", "green", "yellow", "orange", "purple" ]
    var users: [UserModel]=[];
    var selectedUser:UserModel=UserModel()
    var currentUser:UserModel=UserModel()
    var selected_username=""
    var proposed_money:[PropsedMoneyModel]=[]
    
    @IBOutlet weak var dropDown: DropDown!
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var amount: EditText!
    @IBOutlet weak var username: EditText!
    
    
    @IBOutlet weak var layoutInterestRate: CardView!
    @IBOutlet weak var interestStack: UIStackView!
    @IBOutlet weak var interestCard: CardView!
    @IBOutlet weak var amountAfterInterestLabel: UILabel!
    @IBOutlet weak var amountAfterInterest: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var interestRate: EditText!
    var ref:DatabaseReference!
    var selected_duration:Int=0
    var selected_duration_text:String=""
    var amountAfterInterestValue:Int=0
    @IBOutlet weak var proposedPaymentsStack: UIStackView!
    @IBOutlet weak var proposedPaymentsCard: CardView!
    @IBOutlet weak var backbtn: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backTap = UITapGestureRecognizer(target: self, action: #selector(cameraTapped))
        backbtn.isUserInteractionEnabled = true
        backbtn.addGestureRecognizer(backTap)
        
        ref = Database.database().reference();
        
        let defaults = UserDefaults.standard
        let stringOne:Bool = defaults.bool(forKey: "charges_enabled")
        if(stringOne)
        {
                
        }else{
            let alertController = UIAlertController(title: "Alert", message: "Please complete your payment setup before sending request", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                self.navigationController?.popViewController(animated: true)
            })
                alertController.addAction(OKAction)
                self.navigationController?.present(alertController, animated: true, completion: nil)
        }
        
        ref.child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshots) in
            let dict = snapshots.value as? [String : AnyObject];
            let model=UserModel(name: dict!["name"] as! String, username: dict!["username"] as! String, phone: dict!["phone"] as! String, email:  dict!["email"] as! String, password: dict!["password"] as! String, socialSecurityNo: dict!["socialSecurityNo"] as! String, employmentId: dict!["employmentId"] as! String, address: dict!["address"] as! String, dateOfBirth: dict!["dateOfBirth"] as! String, image_url: dict!["image_url"] as! String);
            model.setUid(uid: (snapshots as AnyObject).key as String)
            self.currentUser = model
            
          }) { (error) in
            print(error.localizedDescription)
        }
        
        proposedPaymentsStack.isHidden=true
        dropDown.optionArray = ["Please select duration","1 Month", "2 Months", "3 Months","4 Months","5 Months","6 Months","7 Months","8 Months","9 Months","10 Months","11 Months","1 Year"]
        
        dropDown.addTarget(self, action: #selector(LendMoneyViewController.dropDownChanged(_:)),
                                  for: .editingDidBegin)

        dropDown.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: dropDown.frame.height))
        dropDown.leftViewMode = .always
        
        dropDown.didSelect{(selectedText , index ,id) in
            if(index>0){
                self.proposed_money.removeAll()
                self.selected_duration_text=selectedText
            self.selected_duration=index
            for index in 0...self.selected_duration-1 {
                let a=self.amountAfterInterestValue/self.selected_duration
                let date = Calendar.current.date(byAdding: .month, value: (index+1), to: Date())
           
                let y = Double(round(Double(100*a))/100)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "LLLL"
                let nameOfMonth = dateFormatter.string(from: date!)
                
                let dateFormatter1 = DateFormatter()
                dateFormatter1.dateFormat = "EE MMM dd HH:mm:ss ZZZ yyyy"
        
                self.proposed_money.append(PropsedMoneyModel(amount:y , index: index+1, status:0 , due_date: dateFormatter1.string(from: date!), month: nameOfMonth , uid: "0",showStatus:false,extension_requested: 0));
                
            }
            
            self.proposedPaymentsStack.isHidden=false
            }
        }
        
        layoutInterestRate.isHidden=true
    
        self.cardView.frame = CGRect(x: 0, y: 0, width: self.cardView.frame.width, height: self.cardView.frame.height - 100.0)
        self.tableView.isHidden=true
        username.addTarget(self, action: #selector(LendMoneyViewController.textFieldDidChange(_:)),
                                  for: .editingChanged)
        
        amount.addTarget(self, action: #selector(LendMoneyViewController.amountDidChange(_:)),
                                  for: .editingChanged)
        
        interestRate.addTarget(self, action: #selector(LendMoneyViewController.interestRateDidChange(_:)),
                                  for: .editingChanged)
     
    }
    
    @objc func dropDownChanged(_ textField: UITextField) {
        dropDown.endEditing(true)
    }
    
    func calculateInterestAmount()
    {
        if(amount.text=="")
        {
            layoutInterestRate.isHidden=true
    
        }else if(interestRate.text=="")
        {
            layoutInterestRate.isHidden=true
    
        }else{
            let firstNumberConv :Int? = Int(amount.text!)
                let secondNumberConv :Int? = Int(interestRate.text!)
            
            let a=(firstNumberConv!*secondNumberConv!)/100
            let b=a+firstNumberConv!
            amountAfterInterestValue=b
            amountAfterInterestLabel.text="$"+String(b)
            layoutInterestRate.isHidden=false
        
        }
    }
    
    @objc func amountDidChange(_ textField: UITextField) {
        calculateInterestAmount()
    }
    
    @objc func interestRateDidChange(_ textField: UITextField) {
        interestRate.endEditing(true)
        calculateInterestAmount()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if(textField.text?.count ?? 0>2)
        {
            users.removeAll()
            selected_username=""
            ref = Database.database().reference();
            ref.child("users").queryOrdered(byChild: "username").queryStarting(atValue: textField.text).observeSingleEvent(of: .value, with: { (snapshots) in
                print(snapshots.childrenCount)

                for child in snapshots.children.allObjects as! [DataSnapshot] {
                    let dict = child.value as? [String : AnyObject];
                    var model=UserModel(name: dict!["name"] as! String, username: dict!["username"] as! String, phone: dict!["phone"] as! String, email:  dict!["email"] as! String, password: dict!["password"] as! String, socialSecurityNo: dict!["socialSecurityNo"] as! String, employmentId: dict!["employmentId"] as! String, address: dict!["address"] as! String, dateOfBirth: dict!["dateOfBirth"] as! String, image_url: dict!["image_url"] as! String);
                    model.setUid(uid: (child as AnyObject).key as String)
                    self.users.append(model)
                }
                self.tableView.reloadData()
                self.tableView.isHidden=false
            
              }) { (error) in
                print(error.localizedDescription)
            }
        }else{
            self.tableView.isHidden=true
        }
    }

    @IBAction func paymentDetailsPressed(_ sender: Any) {
        if let popupViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "DialogProposedPaymentsViewController") as? DialogProposedPaymentsViewController {
        popupViewController.modalPresentationStyle = .custom
        popupViewController.modalTransitionStyle = .crossDissolve
            popupViewController.money_array=self.proposed_money;
        //presenting the pop up viewController from the parent viewController
            self.present(popupViewController, animated: true)
    }
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        
        if let popupViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "DialogSignLoanAgreement") as? DialogSignLoanAgreement {
        popupViewController.modalPresentationStyle = .custom
        popupViewController.modalTransitionStyle = .crossDissolve
            
            let currentDate = Date()
            let since1970 = currentDate.timeIntervalSince1970
            let timez = Int(since1970 * 1000)
            
            popupViewController.amount=amount.text!
            popupViewController.types="borrow"
            popupViewController.amountAfterInterest=String(amountAfterInterestValue)
            popupViewController.interestRate=interestRate.text!
            popupViewController.duration=selected_duration_text
            popupViewController.status=0
            popupViewController.timeStamp=String(timez)
            popupViewController.agreement_signed_lender=false
            popupViewController.agreement_signed_borrower=true
            popupViewController.currentUser=currentUser
            popupViewController.navigationControllers=self.navigationController!
            popupViewController.selectedUser=selectedUser
            popupViewController.proposed_money=proposed_money
            popupViewController.loan_agreement += "<p><strong>SPOTME LOAN AGREEMENT</strong></p>\n <p>THIS LOAN AGREEMENT (the &ldquo;Agreement&rdquo;), is made and entered into by and between <u><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"+"(@"+selectedUser.username+") "+selectedUser.name+"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></u> (hereinafter, known as &ldquo;Lender&rdquo;) and  <u><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"+"(@"+currentUser.username+") "+currentUser.name+"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></u>, (hereinafter, known as &ldquo;Borrower&rdquo;). Both the Lender and the Borrower shall collectively be referred to herein as &ldquo;the Parties&rdquo;. This Agreement governs the process by which you may make a request or requests for a loan from other users of SpotMe through the website spotmeapp.us or the spotme app, including any subdomains thereof, or other application channels offered by us (collectively, the \"Site\"). If you make a loan request, and if that request results in a loan that is approved and funded by us, then your loan will be governed by the terms of the Loan Agreement.</p>\n<ol>\n"
            
            popupViewController.loan_agreement += "<li><strong>LOAN AND TERMS OF REPAYMENT</strong></li>\n</ol>\n<ol>\n"+"<li>Promise to pay: FOR VALUE RECEIVED, the undersigned; the borrowers, hereby promises to pay to the Lender, or registered assigns on the Maturity Date (as hereafter defined), such principal amount as from time to time may be advanced hereunder. &nbsp;Annexed hereto and made a part hereof is a schedule (the &ldquo;Loan and Repayment Schedule&rdquo;) on which shall be shown all loans of principal made by the Lender to the Borrower and all repayments of principal made by the Borrower to the Lender hereunder.</li>\n<li>Loan Amount: The Lender promises to loan <u><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$"+amount.text!
            
            popupViewController.loan_agreement += " USD&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></u>to the Borrower and the Borrower promises to repay this principal amount to the Lender according to the terms of this agreement.</li>\n<li>Interest<strong>:</strong> &nbsp;The Borrower shall also pay interest (calculated on the basis of a 360-day year of twelve 30-day months) on such principal amount or the portion thereof from time to time outstanding hereunder at a rate of <u><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"+interestRate.text!;
            
            popupViewController.loan_agreement += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></u> percent (<u><b>&nbsp;&nbsp;&nbsp;"+interestRate.text!
            
            popupViewController.loan_agreement += "&nbsp;&nbsp;&nbsp;</b></u>%) per annum; but in no event shall the interest exceed the maximum rate of nonusurious interest permitted by law to be paid by the Lender (and to the extent permitted by law, interest on any overdue principal or interest thereon).</li>\n</ol>\n<ol start=\"2\">\n<li><strong>SECURITY</strong></li>\n</ol>\n<p>There shall be no security put forth by the Borrower in this agreement.<span class=\"Apple-converted-space\">&nbsp;</span></p>\n<ol start=\"3\">\n<li><strong>PAYMENTS</strong></li>\n</ol>\n<p>Payments shall be made by (a) check made payable to the Lender, (b) an assignment of certain assets, or (c) by a combination of the foregoing.<span class=\"Apple-converted-space\">&nbsp; </span>All payments hereon shall be applied first, to costs and expenses and other amounts owing to the Lender under this Note; second, to accrued interest then payable; and third, to the principal.<span class=\"Apple-converted-space\">&nbsp; </span>The Lender shall have full recourse against the undersigned.</p>\n<ol start=\"4\">\n<li><strong>PREPAYMENT</strong></li>\n</ol>\n<p>The Borrower shall be entitled to prepay the Loan in whole or in part, at any time and from time to time; provided, however, that the Borrower shall give notice to the Lender of any such prepayment; and provided, further, that any partial prepayment of the Loan shall be in an amount not less than 20% of the total payment due. Any such prepayment shall be: (a) permanent and irrevocable; (b) accompanied by all accrued interest through the date of such prepayment; (c) made without premium or penalty; and (d) applied on the inverse order of the maturity of the installment thereof unless the Lender and the Borrower agree to apply such prepayments in some other order.</p>\n<p>If Borrower prepays this Note in part, Borrower agrees to continue to make regularly scheduled payments until all amounts due under this Note are paid. You may accept late payments or partial payments, even though marked \"paid in full\", without losing any rights under this Note.</p>\n<ol start=\"5\">\n<li><strong>LOAN FEES AND CHARGES</strong></li>\n</ol>\n<p>Borrower shall pay to SPotMe, at loan closing all loan fees payable by Borrower in connection with the Loan. Borrower is obligated to pay a Loan Fee, at the time of each loan disbursement, in the amount of 2% of amounts actually loaned to Borrower through the platform. The fee will be deducted from Borrower's loan proceeds, so the loan proceeds delivered to Borrower will be less than the face amount of Borrower's loan request.</p>\n<ol start=\"6\">\n<li><strong>USE OF FUNDS</strong></li>\n</ol>\n<p>The Borrower covenants that it shall apply the proceeds of the Loan solely for the purposes described in the Application. The undersigned acknowledges and agrees that by signing on behalf of the Borrower below he or she shall be personally liable for the repayment of the Loan if (1) any of the information submitted to the Lender or the Department of Economic Development in connection with the Loan is false or misleading, or (2) the proceeds of the Loan are applied for any purposes other than those described in the Application.</p>\n<ol start=\"7\">\n<li><strong>EVENTS OF DEFAULT</strong></li>\n</ol>\n<p>The entire unpaid principal of this agreement, and the interest then accrued thereon, shall become and be immediately due and payable upon the written demand of the Lender, without any other notice or demand of any kind or any presentment or protest, if any one of the following events (hereafter an &ldquo;Event of Default&rdquo;) shall occur and be continuing at the time of such demand, whether voluntarily or involuntarily, or without limitation, occurring or brought about by operation of law or pursuant to or in compliance with any judgment, decree or order of any court or any order, rules, or regulation of any administrative or governmental body.</p>\n<ol>\n<li>Nonpayment of loan: if the Borrower shall fail to make payment when due of the principal on the agreement, or interest accrued thereon, and if the default shall remain unremedied for 15 days.</li>\n<li>Incorrect representation: The Lender determines that any material representation, warranty or certification contained in, or made in connection with the Application, the execution and delivery of this Agreement, or in any document related hereto, including any disbursement request, shall prove to have been incorrect.</li>\n<li>Default in covenant: The Borrower shall default in the performance of any other term, covenant, or agreement contained in this Agreement, and such default shall continue unremedied for fifteen (15) days after either: (i) it becomes known to an executive officer of the Borrower; or (ii) written notice thereof shall have been given to the Borrower by the Lender.<span class=\"Apple-converted-space\">&nbsp;</span></li>\n<li>Insolvency: In the event that the Borrower become insolvent or shall cease to pay its debts as they mature or shall voluntarily file, or have filed against it, a petition seeking reorganization of, or the appointment of a receiver, trustee, or liquidation for it or a substantial portion of its assets, or to effect a plan or other arrangement with creditors, or shall be adjudicated bankrupt, or shall make a voluntary assignment for the benefit of creditors.</li>\n<li>Lender&rsquo;s right upon default: Upon the occurrence of an Event of Default, Lender may exercise all remedies available under applicable law and this Note, including without limitation, accelerate all amounts owed on this agreement and demand that Borrower immediately pay such amounts.<span class=\"Apple-converted-space\">&nbsp; </span>Lender may report information about Borrower's account to credit bureaus. Should there be more than one Borrower, Lender may report that loan account to the credit bureaus in the names of all Borrowers. Late payments, missed payments, or other defaults on an account may be reflected in Borrower's credit report. Borrower agrees to pay all costs of collecting any delinquent payments, including reasonable attorneys' fees, as permitted by applicable law.</li>\n</ol>\n<ol start=\"8\">\n<li><strong>WAIVERS</strong></li>\n</ol>\n<p>No failure or delay on the part of the Lender in exercising any right, power, or remedy hereunder shall operate as a waiver thereof, nor shall any single or partial exercise or any such right, power, or remedy preclude any other or further exercise thereof or the exercise of any other right, power, or remedy hereunder. No modification or waiver of any provision of this Agreement or of this Note, nor any consent to any departure by the Borrower therefrom, shall in any event be effective unless the same shall be in writing, and then such waiver or consent shall be effective only in the specific instance and for the specific purpose for which given. No notice to or demand on the Borrower in any case shall entitle the Borrower to any other or further notice or demand in similar or other circumstances.</p>\n<p>The Borrower hereby waives presentment, protest, demand for payment, notice of dishonor and all other notices or demands in connection with the delivery, acceptance, performance, default or endorsement of this Note.<span class=\"Apple-converted-space\">&nbsp; </span>No waiver by the Lender of any default shall be effective unless in writing nor shall it operate as a waiver of any other default or of the same default on a future occasion.</p>\n<ol start=\"9\">\n<li><strong>ELECTRONIC TRANSACTION NOTICE</strong></li>\n</ol>\n<p>THIS AGREEMENT IS FULLY SUBJECT TO BORROWER&rsquo;S CONSENT TO ELECTRONIC TRANSACTIONS AND DISCLOSURES, WHICH CONSENT IS SET FORTH IN THE TERMS OF USE FOR THE SITE. BORROWER EXPRESSLY AGREES THAT THE NOTE IS A \"TRANSFERABLE RECORD\" FOR ALL PURPOSES UNDER THE ELECTRONIC SIGNATURES IN GLOBAL AND NATIONAL COMMERCE ACT AND THE UNIFORM ELECTRONIC TRANSACTIONS ACT.<span class=\"Apple-converted-space\">&nbsp;</span></p>\n<ol start=\"10\">\n<li><strong>SUCCESSORS AND ASSIGNS</strong></li>\n</ol>\n<p>This agreement shall be binding upon the Borrower and its successors and assigns.</p>\n<ol start=\"11\">\n<li><strong> COUNTERPARTS</strong></li>\n</ol>\n<p>This Agreement may be executed in any number of counterparts, each of which shall be deemed an original, but all of which together shall constitute one and the same instrument.</p>\n<ol start=\"12\">\n<li><strong>BINDING EFFECT</strong></li>\n</ol>\n<p>This agreement will pass to the benefit of and shall be binding upon the executors, heir, administrators, successors and permitted assigns of the Borrower and Lender</p>\n<ol start=\"13\">\n<li><strong>COST OF COLLECTION</strong></li>\n</ol>\n<p>The Borrower agrees to pay all costs of collection of this agreement, including, without limitation, reasonable attorneys&rsquo; fees and costs, in the event it is not paid when due. <span class=\"Apple-converted-space\">&nbsp;</span></p>\n<ol start=\"14\">\n<li><strong>SEVERABILITY</strong></li>\n</ol>\n<p>The terms, paragraphs and clauses contained herein this agreement are intended to be read and construed independently of each other. In the event that any one or more provisions of this Agreement shall be held to be illegal, invalid or otherwise unenforceable, the same shall not affect any other provision of this Agreement and the remaining provisions of this Agreement shall remain in full force and effect.</p>\n<ol start=\"15\">\n<li><strong>AMENDMENTS</strong></li>\n</ol>\n<p>This Agreement may be amended and modified only by a writing executed by the Borrower and the Lender herein.</p>\n<ol start=\"16\">\n<li><strong>APPLICABLE LAW</strong></li>\n</ol>\n<p>This Agreement shall be interpreted and construed in accordance with, and all actions hereunder shall be governed by, the laws of the State of Colorado, without giving effect to principles thereof relating to conflicts of law.</p><div class='parent'>\n\n\n  <div style='display:inline-block'><center><img src='{IMAGE_PLACEHOLDER}'></br><u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"+selectedUser.name+"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</u></center></div>\n  <div style='display:inline-block'><center><img src='{IMAGE_PLACEHOLDER1}'></br><u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"+currentUser.name+"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</u></center></div>\n</div>";
            
            
        //presenting the pop up viewController from the parent viewController
            self.present(popupViewController, animated: true)
    }
    }
    
    @objc func cameraTapped() {
        print("yesss")
        self.navigationController?.popViewController(animated: true)
    }
    
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

}

extension RequestMoneyViewController:UITableViewDataSource,UITableViewDelegate{

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(users.count)
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let offer=users[indexPath.row]
        let cell=tableView.dequeueReusableCell(withIdentifier: "UserNameCell") as! UserNameCell
        cell.setUser(user: offer, this: self)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected cell \(indexPath.row)")
        self.username.text="@"+users[indexPath.row].username
        self.tableView.isHidden=true
        selectedUser=users[indexPath.row]
        self.username.textColor=UIColor.systemGreen
        selected_username=users[indexPath.row].username
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
