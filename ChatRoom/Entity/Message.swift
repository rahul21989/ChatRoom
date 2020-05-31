//
//  Message.swift
//  ChatRoom
//
//  Created by Rahul Goyal on 31/05/20.
//  Copyright © 2020 Rahul Goyal. All rights reserved.
//

import SocketIO
import Firebase
import MessageKit
import FirebaseFirestore


struct Sender: SenderType{
    var senderId: String
    var displayName: String
}

struct Message: MessageType, SocketData {
    let id: String?
    let content: String
    let sender: SenderType
    
    var sentDate: Date {
        return Date()
    }
    var kind: MessageKind {
        return .text(content)
    }
    var messageId: String {
        return id ?? UUID().uuidString
    }
    var downloadURL: URL? = nil
    
    init(user: User, content: String) {
        sender = Sender(senderId: user.uid, displayName: AppSettings.displayName)
        self.content = content
        id = nil
    }
    
    
    init(userId: String, name: String, content: String) {
        sender = Sender(senderId: userId, displayName: name)
        self.content = content
        id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        let senderID = data["senderID"] as! String
        let senderName = data["senderName"] as! String
        id = document.documentID
        
        //    self.sentDate = sentDate
        sender = Sender(senderId: senderID, displayName: senderName)
        
        if let content = data["content"] as? String {
            self.content = content
            downloadURL = nil
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            downloadURL = url
            content = ""
        } else {
            return nil
        }
    }
}

extension Message: DatabaseRepresentation {
    
    var representation: [String : Any] {
        var rep: [String : Any] = [
            "created": sentDate,
            "senderID": sender.senderId,
            "senderName": sender.displayName
        ]
        
        if let url = downloadURL {
            rep["url"] = url.absoluteString
        } else {
            rep["content"] = content
        }
        
        return rep
    }
}

extension Message: Comparable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
}

protocol DatabaseRepresentation {
    var representation: [String: Any] { get }
}


//struct Message : SocketData {
//    let member: Member
//    let text: String
//    let messageId: String
//
//    func socketRepresentation() -> SocketData {
//        return ["member": member, "text": text, "messageId":messageId]
//    }
//}

//extension Message: MessageType {
//    var sender: SenderType {
//        return Sender(senderId: member.name, displayName: member.name)
//    }
//
//    var sentDate: Date {
//        return Date()
//    }
//
//    var kind: MessageKind {
//        return .text(text)
//    }
//}

