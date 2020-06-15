//
//  User.swift
//  Lego
//
//  Created by Abhinav Pottabathula on 6/12/20.
//  Copyright © 2020 Lego. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation
import FirebaseAuth
import FirebaseFirestoreSwift

struct UserData {
    var privateData: UserPrivate
    var publicData: UserPublic
}

//users is a top level collection of UserPrivate documents
struct UserPrivate : Codable {
    @DocumentID var id: String? = UUID().uuidString
    var phoneNumber: String = ""
    var email: String? = ""
    var password: String? = ""
    var latitude: Double? = 0.0
    var longitude: Double? = 0.0
    var chats: [UUID]? = []
    var poiGender: String? = ""
    //Any additional user specific features (ie. matchRate, favoriteHosts, etc...)
}

//UserPrivate documents are attached to a public_profile collection which contains a document with public information
struct UserPublic : Codable {
    @DocumentID var id: String? = UUID().uuidString
    var firstname: String? = ""
    var lastname: String? = ""
    //profile pic? or we can just select the first pic in pictures below
    //pictures will contain links to fetch images, possibly berkeley drive?
    var pictures: [String]? = []
    var bio: String? = ""
    var dateOfBirth: Date? = Date.init()
    var gender: String? = ""
}

class User {
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    let privUserDoc: DocumentReference
    let pubUserDoc: DocumentReference
    var myPrivData: UserPrivate?
    var myPubData: UserPublic?
    
    init() {
        if (user == nil) {
            print("no user")
            //TODO: navigate to signin/signup
        }
        privUserDoc = db.collection(LegoFSConsts.usersPrivColl).document(user!.uid)
        pubUserDoc = privUserDoc.collection(LegoFSConsts.usersPubColl).document(user!.uid)
        self.loadFromDB()
    }
    
    func createUser() {
        print("creating user...")
        privUserDoc.setData(["phoneNumber": user!.phoneNumber!])
        pubUserDoc.setData(["firstname": "Abhinav", "lastname": "Pottabathula", "bio": "myBio", "gender": "myGender"])
        
//        Temp for testing:
//        let privData = UserPrivate(phoneNumber: user!.phoneNumber!)
//        var pubData = UserPublic(id: user!.uid)
//        let pubData = UserPublic(firstname: "Abhinav", lastname: "Pottabathula", bio: "myBio", gender: "myGender")
//        do {
//            let privData = try JSONEncoder().encode(privData)
//            let pubData = try JSONEncoder().encode(pubData)
//            try newPrivUser.setData(from: privData)
//            try newPubUser.setData(from: pubData)
//        } catch {
//            //TODO: throw some exception if JSON encoding failed
//            print(error)
//        }
    }

    func setEmail(email: String) {
        self.reauthorizePopUp()
        user?.updateEmail(to: email) { (error) in
            if error != nil {
                print("Failed to update email: \(String(describing: error))")
                return
            }
        }
        privUserDoc.updateData(["email": email])
    }
    
    func setPassword(pass: String) {
        self.reauthorizePopUp()
        user?.updatePassword(to: pass) { (error) in
            if error != nil {
                print("Failed to update password: \(String(describing: error))")
                return
            }
        }
        privUserDoc.updateData(["password": pass])
    }
    
    func reauthorizePopUp() {
        //TODO: Make the user sign-in again
    }
    
    func setLocation(loc: CLLocation) {
        self.setLocation(lat: loc.coordinate.latitude, long: loc.coordinate.longitude)
    }
    
    func setLocation(lat: Double, long: Double) {
        privUserDoc.updateData(["location": GeoPoint.init(latitude: lat, longitude: long)])
    }
    
    //TODO: Function to add a chat to chats
    
    func setPOIGender(gender: String) {
        privUserDoc.updateData(["poiGender": gender])
    }
    
    func setFirstname(firstname: String) {
        pubUserDoc.updateData(["firstname": firstname])
    }
    
    func setLastname(lastname: String) {
        pubUserDoc.updateData(["lastname": lastname])
    }
    
    //TODO: Function to set/upload pics
    
    func setBio(bio: String) {
        pubUserDoc.updateData(["bio": bio])
    }
    
    func setDOB(dob: Date) {
        pubUserDoc.updateData(["dateOfBirth": dob])
    }
    
    func setGender(gender: String) {
        pubUserDoc.updateData(["gender": gender])
    }
    
    func loadFromDB() {
        myPrivData = getPrivData()
        myPubData = getPubData()
    }
    
    func getPrivData() -> UserPrivate {
        var privData = UserPrivate()
        privUserDoc.getDocument { (document, error) in
            let result = Result {
                try document?.data(as: UserPrivate.self)
            }
            switch result {
            case .success(let data):
                if let data = data {
                    print(data)
                    privData = data
                } else {
                    print("Document does not exist, got nil DocumentSnapshot")
                }
            case .failure(let error):
                print("Error decoding UserPrivate: \(error)")
            }
        }
        return privData
    }
    
    func getPubData() -> UserPublic {
        var pubData = UserPublic()
        pubUserDoc.getDocument { (document, error) in
            let result = Result {
              try document?.data(as: UserPublic.self)
            }
            switch result {
            case .success(let data):
                if let data = data {
                    print(data)
                    pubData = data
                } else {
                    print("Document does not exist, got nil DocumentSnapshot")
                }
            case .failure(let error):
                print("Error decoding UserPrivate: \(error)")
            }
        }
        return pubData
    }
}
