//
//  User.swift
//  Lego
//
//  Created by Abhinav Pottabathula on 6/12/20.
//  Copyright © 2020 Lego. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseStorage

var user: User!

//users is a top level collection of UserPrivate documents
struct PrivateProfile : Codable {
    @DocumentID var id: String? = UUID().uuidString
    var phoneNumber: String = ""
    var email: String = ""
    var password: String = ""
    var location: GeoPoint = GeoPoint.init(latitude: 0, longitude: 0)
    var chats: Set<String> = []
    var poiGender: String = ""
    //Any additional user specific features (ie. matchRate, favoriteHosts, etc...)
}

//UserPrivate documents are attached to a public_profile collection which contains a document with public information
struct PublicProfile : Codable {
    @DocumentID var id: String? = UUID().uuidString
    var firstname: String = ""
    var lastname: String = ""
    var profPic: String = ""
    var pictures: [String] = []
    var bio: String = ""
    var dateOfBirth: Date = Date.init()
    var gender: String = ""
    var isVerified: Bool = false
}


class User {
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    var privUserDoc: DocumentReference
    var pubUserDoc: DocumentReference
    let storageRef: StorageReference
    var privProfile = PrivateProfile()
    var pubProfile = PublicProfile()
    
    init() {
        privUserDoc = db.collection(LegoFSConsts.usersPrivColl).document(currentUser!.uid)
        pubUserDoc = privUserDoc.collection(LegoFSConsts.usersPubColl).document(currentUser!.uid)
        storageRef = Storage.storage().reference()
//        self.loadFromDB() //Include if no listeners are declared to load user data
    }
    
    func createUser(email: String, password: String, location: CLLocation, poiGender: String, firstname: String, lastname: String, bio: String, dateOfBirth: Date, gender: String) {
        print("creating user...")
        let geoLoc = GeoPoint.init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let privData = PrivateProfile(phoneNumber: currentUser!.phoneNumber!, email: email, password: password, location: geoLoc, poiGender: poiGender)
        let pubData = PublicProfile(firstname: firstname, lastname: lastname, bio: bio, dateOfBirth: dateOfBirth, gender: gender)
        do {
            try privUserDoc.setData(from: privData)
            try pubUserDoc.setData(from: pubData)
        } catch {
            //TODO: throw some exception if JSON encoding failed
            print(error)
        }
    }
    
    func createTestUser() {
        print("creating test user...")
//        Temp for testing:
        let privData = PrivateProfile(phoneNumber: currentUser!.phoneNumber!)
        let pubData = PublicProfile(firstname: "Abhinav", lastname: "Pottabathula", bio: "myBio", gender: "myGender")
        do {
            try privUserDoc.setData(from: privData)
            try pubUserDoc.setData(from: pubData)
        } catch {
            //TODO: throw some exception if JSON encoding failed
            print(error)
        }
    }

    
    //TODO: Consolidate set operations into a single write request based on Views
    func setEmail(email: String) {
        self.reauthorizePopUp()
        currentUser?.updateEmail(to: email) { (error) in
            if error != nil {
                print("Failed to update email: \(String(describing: error))")
                return
            }
        }
        privUserDoc.updateData(["email": email])
    }
    
    func getEmail() -> String {
        return (currentUser?.email)!
    }
    
    func setPassword(pass: String) {
        self.reauthorizePopUp()
        currentUser?.updatePassword(to: pass) { (error) in
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
    
    func getLocation() -> (lat: Double, long: Double) {
        return (privProfile.location.latitude, privProfile.location.longitude)
    }
    
    func createChat(otherUserID: String) {
        let newChatID: String = getChatIDWith(otherUserID: otherUserID)
        let chatDoc = db.collection(LegoFSConsts.chatsColl).document(newChatID)
        chatDoc.setData(["chatName": "Get Chatting ;)", "messages": []])
        privUserDoc.updateData(["chats": FieldValue.arrayUnion([newChatID])])
        db.collection(LegoFSConsts.usersPrivColl).document(otherUserID).updateData(["chats": FieldValue.arrayUnion([newChatID])])
    }
    
    func sendMessageTo(otherUserID: String, message: String) {
        let chatID: String = getChatIDWith(otherUserID: otherUserID)
        db.collection(LegoFSConsts.chatsColl).document(chatID).updateData(["messages": FieldValue.arrayUnion([["timestamp": Timestamp(date: Date()), "senderID": currentUser!.uid, "message": message]])])
        //TODO: Write a cloud function to send otherUser a push notification
    }
    
    func getChatIDWith(otherUserID: String) -> String {
        if currentUser!.uid > otherUserID {
            return currentUser!.uid + otherUserID
        } else {
            return otherUserID + currentUser!.uid
        }
    }
    
    func getChatIDs() -> Set<String> {
        return privProfile.chats
    }
    
    func setPOIGender(gender: String) {
        privUserDoc.updateData(["poiGender": gender])
    }
    
    func getPOIGender() -> String {
        return privProfile.poiGender
    }
    
    func setFirstname(firstname: String) {
        pubUserDoc.updateData(["firstname": firstname])
    }
    
    func getFirstname() -> String {
        return pubProfile.firstname
    }
    
    func setLastname(lastname: String) {
        pubUserDoc.updateData(["lastname": lastname])
    }
    
    func getLastname() -> String {
        return pubProfile.lastname
    }
    
    func setProfPic(pic: URL) -> StorageUploadTask {
        let imageRef = storageRef.child(currentUser!.uid).child("prof_pic")
        let uploadTask = imageRef.putFile(from: pic, metadata: nil) { metadata, error in
            if error != nil {
                print("Failed to upload profile picture \(String(describing: error))")
                return
            }
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Failed to get downloadURL reference for profile picture")
                    return
                }
                self.pubUserDoc.updateData(["pictures": downloadURL])
            }
        }
        return uploadTask
    }
    
    func getProfPic() -> StorageReference {
        return storageRef.child(currentUser!.uid).child("prof_pic")
    }
    
    func getProfPic(otherUserID: String) -> StorageReference {
        return storageRef.child(otherUserID).child("prof_pic")
    }
    
    func setPictures(pics: [URL]) -> [StorageUploadTask] {
        var tasks: [StorageUploadTask] = []
        for index in 0...(pics.count - 1) {
            let imageRef = storageRef.child(currentUser!.uid).child(String(index))
            let uploadTask = imageRef.putFile(from: pics[index], metadata: nil) { metadata, error in
                if error != nil {
                    print("Failed to upload picture \(String(describing: error))")
                    return
                }
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print("Failed to get url reference for picture \(String(describing: error))")
                        return
                    }
                    self.pubUserDoc.updateData(["pictures": FieldValue.arrayUnion([downloadURL])])
                }
            }
            tasks.append(uploadTask)
        }
        return tasks
    }
    
    func getPictures() -> [StorageReference] {
        //Use firebaseUI when calling this method: https://firebase.google.com/docs/storage/ios/download-files#downloading_images_with_firebaseui
        var pics: [StorageReference] = []
        for index in 0...(pubProfile.pictures.count - 1) {
            pics.append(storageRef.child(currentUser!.uid).child(String(index)))
        }
        return pics
    }
    
    func getPictures(otherUserID: String) -> [StorageReference] {
        //Use firebaseUI when calling this method: https://firebase.google.com/docs/storage/ios/download-files#downloading_images_with_firebaseui
        var pics: [StorageReference] = []
        for index in 0...(pubProfile.pictures.count - 1) {
            pics.append(storageRef.child(otherUserID).child(String(index)))
        }
        return pics
    }
    
    func setBio(bio: String) {
        pubUserDoc.updateData(["bio": bio])
    }
    
    func getBio() -> String {
        return pubProfile.bio
    }
    
    func setDOB(dob: Date) {
        pubUserDoc.updateData(["dateOfBirth": dob])
    }
    
    func getDOB() -> Date {
        return pubProfile.dateOfBirth
    }
    
    func setGender(gender: String) {
        pubUserDoc.updateData(["gender": gender])
    }
    
    func getGender() -> String {
        return pubProfile.gender
    }
    
    func setVerified(isVerified: Bool) {
        pubUserDoc.updateData(["isVerified": isVerified])
    }
    
    func getVerified() -> Bool {
        return pubProfile.isVerified
    }
    
    func loadFromDB() {
        privProfile = getPrivData()
        pubProfile = getPubData()
    }
    
    func getPrivData() -> PrivateProfile {
        var privData = PrivateProfile()
        privUserDoc.getDocument { (document, error) in
            let result = Result {
                try document?.data(as: PrivateProfile.self)
            }
            switch result {
            case .success(let data):
                if let data = data {
//                    print(data)
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
    
    func getPubData() -> PublicProfile {
        var pubData = PublicProfile()
        pubUserDoc.getDocument { (document, error) in
            let result = Result {
              try document?.data(as: PublicProfile.self)
            }
            switch result {
            case .success(let data):
                if let data = data {
//                    print(data)
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
