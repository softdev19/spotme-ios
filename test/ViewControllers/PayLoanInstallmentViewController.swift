import UIKit
import Stripe
import Alamofire
import Firebase
import SwiftyJSON

class PayLoanInstallmentViewController: BaseViewController {
    
    var payment_id:String=""
    var user_id:String=""
    var token:String=""
    var amount:String=""
    var index:String="0"
    var navigationControllers:UINavigationController=UINavigationController()
    var paymentIntentClientSecret:String=""
    var ref:DatabaseReference!
    var currentUser:String = ""
    @IBOutlet weak var backBtn: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var customer_id:String = ""
    var cards:[CardsModel]=[]
    
    @IBOutlet weak var card_view: CardView!
    lazy var cardTextField: STPPaymentCardTextField = {
        let cardTextField = STPPaymentCardTextField()
        return cardTextField
    }()
    lazy var payButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 5
        button.backgroundColor = #colorLiteral(red: 0.3431670666, green: 0.9492903352, blue: 0.5059015751, alpha: 1)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        button.setTitle("Pay", for: .normal)
        button.addTarget(self, action: #selector(pay), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference();
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(onBackPressed))
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(backTap)
        
        view.backgroundColor = .white
        let stackView = UIStackView(arrangedSubviews: [cardTextField, payButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
//        card_view.addSubview(stackView)
//        NSLayoutConstraint.activate([
//            stackView.leftAnchor.constraint(equalToSystemSpacingAfter: card_view.leftAnchor, multiplier: 2),
//            card_view.rightAnchor.constraint(equalToSystemSpacingAfter: stackView.rightAnchor, multiplier: 2),
//            stackView.topAnchor.constraint(equalToSystemSpacingBelow: card_view.topAnchor, multiplier: 2),
//        ])
        ref = Database.database().reference();
        ref.child("users").child(Auth.auth().currentUser!.uid).child("customer").observeSingleEvent(of: .value, with: { (snapshots) in
            let dict = snapshots.value as? [String : AnyObject];
            self.customer_id=dict!["id"] as! String
            
          }) { (error) in
            print(error.localizedDescription)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        getSavedCards()
    }
    
    func getSavedCards()
    {
      //  showLoading()
        
        let URL1:String = "https://us-central1-spotme-39709.cloudfunctions.net/getCards"
        print(Auth.auth().currentUser!.uid)
        let par1a = [ "user_id" : Auth.auth().currentUser!.uid] as [String : Any]
        AF.request(URL1, method: .post, parameters: par1a, encoding: JSONEncoding.default, headers : nil)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print(value)
                    self.cards=[]
                    let json=JSON(value)
                    let parsed=JSON(parseJSON:json["data"].stringValue)
                    if(parsed["Error"].boolValue)
                    {

                    }else{
       
         
                    if let items = parsed["response"]["data"].array {
                        for item in items {
                            let model=CardsModel()

                            if let id = item["id"].string {
                                model.id=id
                            }

                            if let brand = item["card"]["brand"].string {
                                model.brand=brand
                            }

                            if let exp_month = item["card"]["exp_month"].int {
                                model.exp_month=String(exp_month)
                            }

                            if let exp_year = item["card"]["exp_year"].int {
                                model.exp_year=String(exp_year)
                            }

                            if let last4 = item["card"]["last4"].string {
                                model.last4=last4
                            }

                           self.cards.append(model)
                        }
                    }
                        
                        self.tableView.reloadData()
                    
                    }
                   // self.hideLoading()
                case .failure(let error):
                    print(error)
                    //self.hideLoading()
                }
            }

    }
    
    @objc func onBackPressed() {
        print("yesss")
        self.navigationController?.popViewController(animated: true)
    }
    @objc
    func pay() {
        if((cardTextField.cardParams.number == nil) || cardTextField.cardParams.expYear == nil || cardTextField.cardParams.cvc == nil){
            showMessage(msg: "Please input valid card information")
        }else{
            
            let alert = UIAlertController(title: "Alert", message: "Submit Payment? SpotMe charges a 5% service fee", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "Pay", style: UIAlertAction.Style.default, handler: {(action) in
            
                self.showLoading()
                let URL:String = "https://us-central1-spotme-39709.cloudfunctions.net/makePayment"
              
             
                let para = [ "user_id" : self.user_id,"amount":self.amount] as [String : Any]
                AF.request(URL, method: .post, parameters: para, encoding: JSONEncoding.default, headers : nil)
                    .responseJSON { response in
                        switch response.result {
                        case .success(let value):
                        
                            let json=JSON(value)
                            let parsed=JSON(parseJSON:json["data"].stringValue)
                            if(parsed["Error"].boolValue)
                            {
                                print("clientSecret",parsed["Message"].stringValue)
                            }else{
                                print("clientSecret",parsed["clientSecret"].stringValue)
                                self.paymentIntentClientSecret = parsed["clientSecret"].stringValue
                                // Collect card details
                                let cardParams = self.cardTextField.cardParams
                                      let paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: nil, metadata: nil)
                                let paymentIntentParams = STPPaymentIntentParams(clientSecret: self.paymentIntentClientSecret)
                                      paymentIntentParams.paymentMethodParams = paymentMethodParams

                                      // Submit the payment
                                      let paymentHandler = STPPaymentHandler.shared()
                                      paymentHandler.confirmPayment(withParams: paymentIntentParams, authenticationContext: self) { (status, paymentIntent, error) in
                                          switch (status) {
                                          case .failed:
                                                self.hideLoading()
                                              self.showMessage(msg: error?.localizedDescription ?? "")
                                              break
                                          case .canceled:
                                                self.hideLoading()
                                              self.showMessage(msg: error?.localizedDescription ?? "")
                                              break
                                          case .succeeded:
                                        
                                            self.ref.child("payments").child(self.payment_id).child(self.index).child("status").setValue(1)
                                        
                                            self.ref.child("payments").child(self.payment_id).child(self.index).child("payment_intent").setValue(paymentIntent?.allResponseFields)
                                            
                                            self.ref.child("notifications").child(self.user_id).childByAutoId().child("notification").setValue(self.currentUser + " has paid the loan installment of $"+self.amount);
                                            self.sendNotification(notification:self.currentUser + " has paid the loan installment of $"+self.amount, device_token: self.token)
                                            
                                                self.hideLoading()
                                            
                                            let alertController = UIAlertController(title: "Success", message: "Payment Successfull", preferredStyle: .alert)
                                               let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                                              
                                                let storyBoard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                                                let newViewController = storyBoard.instantiateViewController(withIdentifier: "Home") as! UITabBarController
                                                self.navigationControllers.pushViewController(newViewController, animated: true)
                                            //    self.navigationControllers.loadView()
                                               })
                                            
                                            alertController.addAction(OKAction)
                                            self.present(alertController, animated: true, completion: nil)
                                            
                                              break
                                          @unknown default:
                                                self.hideLoading()
                                              fatalError()
                                              break
                                          }
                                      }

                            }
                        case .failure(let error):
                            print(error)
                            self.hideLoading()
                        }
                    }
               
                    
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        
        
        }
        
    }
}
extension PayLoanInstallmentViewController: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}
extension PayLoanInstallmentViewController:UITableViewDataSource,UITableViewDelegate{

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data=cards[indexPath.row]
        let cell=tableView.dequeueReusableCell(withIdentifier: "PaymentCardCell") as! PaymentCardCell
      //  cell.delegate = self
        cell.setData(data: data)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Alert", message: "Submit Payment? SpotMe charges a 5% service fee", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Pay", style: UIAlertAction.Style.default, handler: {(action) in
        
            self.showLoading()
            let URL:String = "https://us-central1-spotme-39709.cloudfunctions.net/makePaymentWithCard"
            let para = [ "user_id" : self.user_id,"amount":self.amount,"customer_id":self.customer_id,"method_id":self.cards[indexPath.row].id] as [String : Any]
               AF.request(URL, method: .post, parameters: para, encoding: JSONEncoding.default, headers : nil)
                   .responseJSON { response in
                       switch response.result {
                       case .success(let value):
                       
                           let json=JSON(value)
                           let parsed=JSON(parseJSON:json["data"].stringValue)
                           if(parsed["Error"].boolValue)
                           {
                               print("Something wrong with the payment.Please check your card for funds Or contact your bank")
                           }else{
                             //  print("clientSecret",parsed["clientSecret"].stringValue)
                            //   self.paymentIntentClientSecret = parsed["clientSecret"].stringValue
                       
                            if(!(parsed["clientSecret"]["id"].stringValue == ""))
                            {
                                self.ref.child("payments").child(self.payment_id).child(self.index).child("status").setValue(1)
                            
                               // self.ref.child("payments").child(self.payment_id).child(self.index).child("payment_intent").setValue(paymentIntent?.allResponseFields)
                                
                                self.ref.child("notifications").child(self.user_id).childByAutoId().child("notification").setValue(self.currentUser + " has paid the loan installment of $"+self.amount);
                                self.sendNotification(notification:self.currentUser + " has paid the loan installment of $"+self.amount, device_token: self.token)
                                
                                    self.hideLoading()
                                
                                let alertController = UIAlertController(title: "Success", message: "Payment Successfull", preferredStyle: .alert)
                                   let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                                  
                                    let storyBoard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "Home") as! UITabBarController
                                    self.navigationControllers.pushViewController(newViewController, animated: true)
                                //    self.navigationControllers.loadView()
                                   })
                                
                                alertController.addAction(OKAction)
                                self.present(alertController, animated: true, completion: nil)
                                
                            }

                           }
                       case .failure(let error):
                           print(error)
                           self.hideLoading()
                       }
                   }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
       
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

