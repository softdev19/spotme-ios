/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Photos
import Firebase
import MessageKit
import InputBarAccessoryView

final class SendMessageViewController: MessagesViewController {
  
  private var ref: DatabaseReference
  private var messages: [Message] = []
  //private var messageListener: ListenerRegistration?
    private var currentUser: UserModel
    private var thread_id:String
    private var thread_id_notification:String
    private var uid1:String
    private var uid2:String
    private var count:Int
    private var selectedUser = UserModel()
  //private let channel: Channel
  

    init(uid1:String,uid2:String,thread_id_notification:String,count:Int,selectedUser:UserModel) {
    self.uid1 = uid1
    self.uid2=uid2
    self.currentUser=UserModel()
    self.ref = Database.database().reference();
    self.thread_id="1"
    self.selectedUser=selectedUser
    self.thread_id_notification=thread_id_notification
    self.count=count
    super.init(nibName: nil, bundle: nil)
    
    title = selectedUser.name
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.setNavigationBarHidden(false, animated: animated)
    navigationController?.navigationBar.barTintColor =  #colorLiteral(red: 0.3431670666, green: 0.9492903352, blue: 0.5059015751, alpha: 1)
    navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
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
    navigationController?.setNavigationBarHidden(true, animated: animated)
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
  
  override func viewDidLoad() {
    super.viewDidLoad()

        if(uid1 < uid2){
            self.thread_id=uid1+uid2;
        }
        else {
            self.thread_id=uid2+uid1;
        }
    
    if(!(thread_id_notification == "0")) {
        
        ref.child("users").child(uid1).child("conversations").child(thread_id_notification).child("notification_count").setValue(0)
    
    }
    
    ref.child("users").child(uid1).observeSingleEvent(of: .value, with: { (snapshots) in
          let dict = snapshots.value as? [String : AnyObject];
        
        let model=UserModel(name: dict!["name"] as! String, username: dict!["username"] as! String, phone: dict!["phone"] as! String, email:  dict!["email"] as! String, password: dict!["password"] as! String, socialSecurityNo: dict!["socialSecurityNo"] as! String, employmentId: dict!["employmentId"] as! String, address: dict!["address"] as! String, dateOfBirth: dict!["dateOfBirth"] as! String, image_url: dict!["image_url"] as! String);
        model.setUid(uid: (snapshots as AnyObject).key as String)
        model.setDeviceToken(token: dict!["device_token"] as! String)
        self.currentUser = model
        
      }) { (error) in
        print(error.localizedDescription)
    }


    ref.child("messages").child(thread_id).observeSingleEvent(of: .value, with: { (snapshots) in
        print(snapshots.childrenCount)
        for child in snapshots.children.allObjects as! [DataSnapshot] {
            let dict = child.value as? [String : AnyObject];
             
            var idd = (child as AnyObject).key as String
           
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE MMM d HH:mm:ss z yyyy"
            let date = dateFormatter.date(from: dict!["time"] as! String)
            
            self.insertNewMessage(Message(id: idd, content: dict!["text"] as! String, sentDate: date!, senderName: dict!["sender"] as! String, senderId: dict!["sender"] as! String)!)
        
        
        }
      }) { (error) in
        print(error.localizedDescription)
    }
//
//    messageListener = reference?.addSnapshotListener { querySnapshot, error in
//      guard let snapshot = querySnapshot else {
//        print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
//        return
//      }
//
//      snapshot.documentChanges.forEach { change in
//        self.handleDocumentChange(change)
//      }
//    }
    
    navigationItem.largeTitleDisplayMode = .always
  
    navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.3431670666, green: 0.9492903352, blue: 0.5059015751, alpha: 1)
    navigationController?.toolbar.backgroundColor = #colorLiteral(red: 0.3431670666, green: 0.9492903352, blue: 0.5059015751, alpha: 1)
   // navigationController?.navigationBar.backgroundColor = UIColor.systemGreen
    
    maintainPositionOnKeyboardFrameChanged = true
    messageInputBar.inputTextView.tintColor = #colorLiteral(red: 0.3431670666, green: 0.9492903352, blue: 0.5059015751, alpha: 1)
    messageInputBar.sendButton.setTitleColor(#colorLiteral(red: 0.3431670666, green: 0.9492903352, blue: 0.5059015751, alpha: 1), for: .normal)

    
    messageInputBar.delegate = self
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
    
    messagesCollectionView.contentInset.top = 60
    
    guard let flowLayout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else { return }

    flowLayout.attributedTextMessageSizeCalculator.outgoingAvatarSize = .zero
    flowLayout.attributedTextMessageSizeCalculator.incomingAvatarSize = .zero
  
    
  }
  
  // MARK: - Helpers
  
  private func save(_ message: Message) {
  
    let currentDate = Date()
    let since1970 = currentDate.timeIntervalSince1970
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE MMM d HH:mm:ss z yyyy"
    let result = dateFormatter.string(from: Date())
    
    let aa=String(Int(since1970 * 1000))
    ref.child("messages").child(thread_id).child(aa).setValue(["sender":uid1,"receiver":uid2,"text":message.content,"time":result])
    ref.child("users").child(uid1).child("conversations").child(thread_id).setValue(["chat_with":uid2,"last_message":message.content,"notification_count":0])
    ref.child("users").child(uid2).child("conversations").child(thread_id).setValue(["chat_with":uid1,"last_message":message.content,"notification_count":self.count+1])
    
  
    
    self.insertNewMessage(Message(id: aa, content: message.content, sentDate: message.sentDate, senderName: self.currentUser.name, senderId: uid1)!)
    
    
    
  }
  
  private func insertNewMessage(_ message: Message) {
    guard !messages.contains(message) else {
      return
    }
    
    messages.append(message)
    messages.sort()
    
    let isLatestMessage = messages.index(of: message) == (messages.count - 1)
    let shouldScrollToBottom =  isLatestMessage
    
    messagesCollectionView.reloadData()
    
    if shouldScrollToBottom {
      DispatchQueue.main.async {
        self.messagesCollectionView.scrollToBottom(animated: true)
      }
    }
  }
//
//  private func handleDocumentChange(_ change: DocumentChange) {
//    guard var message = Message(document: change.document) else {
//      return
//    }
//
//    switch change.type {
//    case .added:
//      if let url = message.downloadURL {
//        downloadImage(at: url) { [weak self] image in
//          guard let `self` = self else {
//            return
//          }
//          guard let image = image else {
//            return
//          }
//
//          message.image = image
//          self.insertNewMessage(message)
//        }
//      } else {
//        insertNewMessage(message)
//      }
//
//    default:
//      break
//    }
//  }
}

// MARK: - MessagesDisplayDelegate

extension SendMessageViewController: MessagesDisplayDelegate {
  
  func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
    return isFromCurrentSender(message: message) ?  #colorLiteral(red: 0.3431670666, green: 0.9492903352, blue: 0.5059015751, alpha: 1) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
  }
  
  func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
    return false
  }
  
  func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
    let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
    return .bubbleTail(corner, .curved)
  }
  
}

// MARK: - MessagesLayoutDelegate

extension SendMessageViewController: MessagesLayoutDelegate {
  
  func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
    return .zero
  }
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout { layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero }
    }
  
  func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
    return CGSize(width: 0, height: 8)
  }
  
  func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    
    return 0
  }
  
}

// MARK: - MessagesDataSource

extension SendMessageViewController: MessagesDataSource {
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
  
  func currentSender() -> SenderType {
    return Sender(senderId: uid1, displayName: self.currentUser.name)
  }
  
  func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
    return messages.count
  }
  
  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return messages[indexPath.section]
  }
  
  func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    let name = message.sender.displayName
    return NSAttributedString(
      string: name,
      attributes: [
        .font: UIFont.preferredFont(forTextStyle: .caption1),
        .foregroundColor: UIColor(white: 0.3, alpha: 1)
      ]
    )
  }
  
}

// MARK: - MessageInputBarDelegate
//
//extension SendMessageViewController: InputBarAccessoryViewDelegate {
//
//    func messageInputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
//    let message = Message(user: user, content: text)
//    print("uesss")
//    save(message)
//    inputBar.inputTextView.text = ""
//  }
//
//}

extension SendMessageViewController: InputBarAccessoryViewDelegate {
  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    //Handle message input text here
    let message = Message(user: currentUser, content: text)
    print("uesss")
    save(message)
    inputBar.inputTextView.text = ""
  }
}


