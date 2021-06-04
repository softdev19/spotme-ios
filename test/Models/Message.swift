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

import Firebase
import MessageKit

struct Message: MessageType {
  
  let id: String?
  let content: String
  let sentDate: Date
  var sender: SenderType
  
  var kind: MessageKind {
      return .text(content)
  }
  
  var messageId: String {
    return id ?? UUID().uuidString
  }
  
  var image: UIImage? = nil
  var downloadURL: URL? = nil
  
  init(user: UserModel, content: String) {
    sender = Sender(senderId: user.uid, displayName: "AppSettings.displayName")
    self.content = content
    sentDate = Date()
    id = nil
  }
  
    init?(id:String,content:String,sentDate:Date,senderName:String,senderId:String) {
    self.sentDate=sentDate
    self.id = id
    self.content = content
    self.sender = Sender(senderId: senderId, displayName: senderName)

  }
  
}

//extension Message: DatabaseRepresentation {
//
//  var representation: [String : Any] {
//    var rep: [String : Any] = [
//      "created": sentDate,
//      "senderID": sender.senderId,
//      "senderName": sender.displayName
//    ]
//
//    if let url = downloadURL {
//      rep["url"] = url.absoluteString
//    } else {
//      rep["content"] = content
//    }
//
//    return rep
//  }
//
//}

extension Message: Comparable {
  
  static func == (lhs: Message, rhs: Message) -> Bool {
    return lhs.id == rhs.id
  }
  
  static func < (lhs: Message, rhs: Message) -> Bool {
    return lhs.sentDate < rhs.sentDate
  }
  
}
