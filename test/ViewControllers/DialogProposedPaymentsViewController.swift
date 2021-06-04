//
//  DialogProposedPaymentsViewController.swift
//  test
//
//  Created by Rana Muneeb on 19/11/2020.
//

import UIKit

class DialogProposedPaymentsViewController: BaseViewController {

    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var tableView: UITableView!
    var money_array: [PropsedMoneyModel]=[];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(money_array.count)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
       
    }
    
    @IBAction func okPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}

extension DialogProposedPaymentsViewController:UITableViewDataSource,UITableViewDelegate{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(money_array.count)
        return money_array.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let offer=money_array[indexPath.row]
        let cell=tableView.dequeueReusableCell(withIdentifier: "ProposedPaymentCell") as! ProposedPaymentCell
        cell.setOffer(offer: offer)
        return cell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
