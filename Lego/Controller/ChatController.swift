//
//  ChatController.swift
//  Lego
//
//  Created by Abhinav Pottabathula on 6/27/20.
//  Copyright © 2020 Lego. All rights reserved.
//

import Foundation
import FirebaseFirestore

class ChatController {
    var user: User
    var chats = [Chat]()
    private var db = Firestore.firestore()
    
    init(user: User) {
        self.user = user
    }
    
    func getChats() {
        //This should be somewhere else:
        
        for id in user.getChatIDs() {
            
        }
        
        let chatID: String = user.getChatIDWith(otherUserID: otherUserID)
        let chatDoc = db.collection(LegoFSConsts.chatsColl).whereField(<#T##field: String##String#>, isEqualTo: <#T##Any#>)
    }
}
