import UIKit
import Stripe
import Alamofire
import Firebase
import SwiftyJSON

class AddCardViewController: BaseViewController {
    
    var offer_id:String=""
    var currentUserId=""
    var universal=false
    var universal_object=RequestsModel()
    var user_id:String=""
    var type:String=""
    var token:String=""
    var loan_agreement:String=""
    var cards:[CardsModel]=[]
    var amount:String=""
    var navigationControllers:UINavigationController=UINavigationController()
    var paymentIntentClientSecret:String=""
    var ref:DatabaseReference!
    @IBOutlet weak var tableView: UITableView!
    var currentUser:String = ""
    
    @IBOutlet weak var backBtn: UIImageView!
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
        card_view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalToSystemSpacingAfter: card_view.leftAnchor, multiplier: 2),
            card_view.rightAnchor.constraint(equalToSystemSpacingAfter: stackView.rightAnchor, multiplier: 2),
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: card_view.topAnchor, multiplier: 2),
        ])
        
        
    }

    @objc func onBackPressed() {
        print("yesss")
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    @objc
    func pay() {
        if((cardTextField.cardParams.number == nil) || cardTextField.cardParams.expYear == nil || cardTextField.cardParams.cvc == nil){
            showMessage(msg: "Please input valid card information")
        }else{
            
                self.showLoading()
                let URL:String = "https://us-central1-spotme-39709.cloudfunctions.net/saveNewCard"
       
                
                    let para = [ "user_id" : Auth.auth().currentUser?.uid] as [String : Any]
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
                               
                                        let cardParams = self.cardTextField.cardParams
                                        // Fill in any billing details...
                                        let billingDetails = STPPaymentMethodBillingDetails()

                                        // Create SetupIntent confirm parameters with the above
                                        let paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: billingDetails, metadata: nil)
                                        let setupIntentParams = STPSetupIntentConfirmParams(clientSecret: self.paymentIntentClientSecret)
                                        setupIntentParams.paymentMethodParams = paymentMethodParams
                                
                                        let paymentHandler = STPPaymentHandler.shared()
                                        paymentHandler.confirmSetupIntent(setupIntentParams, with: self) { status, setupIntent, error in
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
                                                self.hideLoading()
                                                let alertController = UIAlertController(title: "Success", message: "Card Added Successfully!", preferredStyle: .alert)
                                                   let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                                                    self.dismiss(animated: true, completion: nil)
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
        

        }
        
    }
    
    
}
extension AddCardViewController: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}

