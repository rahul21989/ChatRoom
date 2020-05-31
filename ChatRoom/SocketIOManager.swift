//
//  SocketIOManager.swift
//  ChatRoom
//
//  Created by Rahul Goyal on 31/05/20.
//  Copyright © 2020 Rahul Goyal. All rights reserved.
//

import UIKit
import SocketIO

final class SocketIOManager {
    
    static let sharedInstance = SocketIOManager()
//    var messageCallback:((Message)-> Void)?
    private let manager: SocketManager
    private var socket: SocketIOClient

    init() {
        manager = SocketManager(socketURL: URL(string: "http://localhost:3000/")!,config: [.log(true), .compress])
        socket = manager.defaultSocket
        setSocketEvents()
    }
    
    fileprivate func setSocketEvents() {
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
    }
        
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func sendMessage(data:[String:Any]) {
        socket.emit("newChatMessage", data)
    }
        
    func getChatMessage(completionHandler: @escaping(Message) -> Void) {
        socket.on("newChatMessage") { (dataArray, socketAck) -> Void in
            let data = dataArray[0] as AnyObject
            let message = Message.init(userId: data["id"] as! String, name: data["name"] as! String, content: data["message"] as! String)
            completionHandler(message)
        }
    }
}

