//
//  Chats.swift
//  Lego
//
//  Created by Abhinav Pottabathula on 6/27/20.
//  Copyright © 2020 Lego. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation
import FirebaseAuth
import FirebaseFirestoreSwift


struct Chat: Codable {
    var chatName: String = "NO CHAT NAME"
    var messages: [Message] = []
}

struct Message: Codable {
    var message: String = ""
    var senderID: String = ""
    var timestamp: Timestamp = Timestamp.init()
}


class Chats {
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    var privUserDoc: DocumentReference
    var pubUserDoc: DocumentReference
    var privProfile: PrivateProfile
    var pubProfile: PublicProfile

    init() {
        if (user == nil) {
            print("no user")
            //TODO: navigate to signin/signup
        }
        privUserDoc = db.collection(LegoFSConsts.usersPrivColl).document(user!.uid)
        pubUserDoc = privUserDoc.collection(LegoFSConsts.usersPubColl).document(user!.uid)
        
        
        //TODO: The following two listeners are better placed in a ViewDidLoad function
        privUserDoc.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            let result = Result {
                try document.data(as: PrivateProfile.self)
            }
            switch result {
            case .success(let data):
                if let data = data {
                    self.privProfile = data
                } else {
                    print("Document does not exist, got nil DocumentSnapshot")
                }
            case .failure(let error):
                print("Error decoding UserPrivate: \(error)")
            }
        }
        
        pubUserDoc.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            let result = Result {
                try document.data(as: PublicProfile.self)
            }
            switch result {
            case .success(let data):
                if let data = data {
                    self.pubProfile = data
                } else {
                    print("Document does not exist, got nil DocumentSnapshot")
                }
            case .failure(let error):
                print("Error decoding UserPrivate: \(error)")
            }
        }
    }
}
