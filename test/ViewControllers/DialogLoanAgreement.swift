//
//  DialogProposedPaymentsViewController.swift
//  test
//
//  Created by Rana Muneeb on 19/11/2020.
//

import UIKit
import WebKit

class DialogLoanAgreement: BaseViewController {

    var loan_agreement:String=""
    
    @IBOutlet weak var webivew: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
       view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        webivew.loadHTMLString(loan_agreement, baseURL: nil)
       
    }
    @IBAction func hideDialog(_ sender: Any) {
        self.dismiss(animated: false,completion: nil)
    }
    
    @IBAction func okPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
