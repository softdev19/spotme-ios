//
//  BaseViewController.swift
//  test
//
//  Created by Rana Muneeb on 18/11/2020.
//

import UIKit
import Alamofire

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(dismissKeyboard))
               tap.cancelsTouchesInView = false
               view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard() {
            view.endEditing(true)
        }


    func showLoading()
    {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    func hideLoading() {
        dismiss(animated: false, completion: nil)
    }
    
    func showMessage(msg: String){
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: UIAlertController.Style.alert)

        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)
     //   self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func sendNotification(notification:String,device_token:String)
    {
        let FCM_API:String = "https://fcm.googleapis.com/fcm/send"
        let serverKey = "key=" + "AAAAaRmFqg4:APA91bGGUM14NFLhCSleYZ7EwqCteCL46NbfJ-i8OcE6GXfu-fM5-s5IUdmux8lRolqrkwTSV8jfH1oPaUHLgedjF4npJEMhRSIXnrUnqZ9LvoDPhrTHvSIHx69r5Q_DrBMaumuLD0zR"

        let headers  :HTTPHeaders  = [ "Content-Type" : "application/json", "Authorization": serverKey]
    
        let para = [ "to" : device_token,"data":["title":notification,"message":notification],"notification":["title":notification,"message":notification,"sound":"default"]] as [String : Any]
        AF.request(FCM_API, method: .post, parameters: para, encoding: JSONEncoding.default, headers : headers)
            .responseJSON { response in

                print(response)
                print(response.result)

        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
