//
//  DialogProposedPaymentsViewController.swift
//  test
//
//  Created by Rana Muneeb on 19/11/2020.
//

import UIKit
import Firebase
import WebKit
import Alamofire
import SwiftyJSON

class PaymentDashboardViewController: BaseViewController {

    @IBOutlet weak var webview: WKWebView!
    
    @IBOutlet weak var backbtn: UIImageView!
    var ref:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(cameraTapped))
        backbtn.isUserInteractionEnabled = true
        backbtn.addGestureRecognizer(backTap)
        
        ref = Database.database().reference();
        self.webview.navigationDelegate = self
        getLoginLink(uid: Auth.auth().currentUser!.uid)
    }
    
    @objc func cameraTapped() {
        print("yesss")
        self.navigationController?.popViewController(animated: true)
    }
    func getLoginLink(uid:String)
    {
        showLoading()
        self.webview.isHidden=true
        let URL:String = "https://us-central1-spotme-39709.cloudfunctions.net/getLoginLink"
      
        let para = [ "user_id" : uid] as [String : Any]
        AF.request(URL, method: .post, parameters: para, encoding: JSONEncoding.default, headers : nil)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                
                    let json=JSON(value)
                    let parsed=JSON(parseJSON:json["data"].stringValue)
                    if(parsed["Error"].boolValue)
                    {
                        
                    }else{
                        print("data",parsed["url"]["url"].stringValue)
                        let url_str=parsed["url"]["url"].stringValue
                    
                        self.webview.load(NSURLRequest(url: NSURL(string: url_str)! as URL) as URLRequest)
                    
                
                    }
                    
                case .failure(let error):
                    print(error)
                    self.hideLoading()
                
                    let alertController = UIAlertController(title: "Alert", message: "Please complete on-boarding to access payouts dashboard", preferredStyle: .alert)
                       let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                        self.navigationController?.popViewController(animated: true)
                       })
                       alertController.addAction(OKAction)
                    self.navigationController?.present(alertController, animated: true, completion: nil)
                }
            }
    }
    
    @IBAction func backPressed(_ sender: Any) {
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

extension PaymentDashboardViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let removeElementIdScript = "document.getElementsByClassName('db-FooterLayout-footer')[0].remove(); document.getElementsByClassName('Box-root Padding-top--4 Flex-flex Flex-alignItems--baseline Flex-direction--row')[0].remove(); document.getElementsByClassName('Text-color--default Text-fontSize--14 Text-lineHeight--20 Text-numericSpacing--proportional Text-typeface--base Text-wrap--wrap Text-display--inline')[0].remove(); document.getElementById('manage-team').remove(); document.getElementsByClassName('ContentListItem-container Box-root Box-background--white Box-divider--light-bottom-1 Flex-flex Flex-direction--row')[0].remove();"
        webView.evaluateJavaScript(removeElementIdScript) { (response, error) in
            debugPrint("Am here")
            self.webview.isHidden=false
            self.hideLoading()
        }
    }
}
