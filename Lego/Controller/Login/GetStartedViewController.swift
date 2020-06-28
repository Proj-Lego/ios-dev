//
//  GetStartedViewController.swift
//  Lego
//
//  Created by Shreyas Patankar on 3/23/20.
//  Copyright © 2020 Lego. All rights reserved.
//

import UIKit
import FirebaseAuth

class GetStartedViewController: UIViewController {

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var getStartedBtn: UIButton!
    let user = User.init()
    
    override func viewWillAppear(_ animated: Bool) {
        if (Auth.auth().currentUser != nil) {
            print("signed in already")
            //TODO: Navigate to main screen
            print("User already logged in, can navigate away...")
//            user.setBio(bio: "hello guys!")
            print("My bio is: " + user.getBio())
//            let shreyasID = "VAon5tawOJ1G4rKaGr28"
//            user.createChat(otherUserID: shreyasID)
//            user.sendMessageTo(otherUserID: shreyasID, message: "Hello wanker")
        }
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = LegoColorConstants.aqua
        navigationController?.navigationBar.barStyle = .black
        
        logoImage.image = UIImage(named: "logo.png")
        logoImage.layer.cornerRadius = logoImage.frame.height / 8
        getStartedBtn.layer.cornerRadius = getStartedBtn.frame.height / 2
        
        view.backgroundColor = LegoColorConstants.darkBlue
        getStartedBtn.backgroundColor = LegoColorConstants.red
        getStartedBtn.setTitleColor(LegoColorConstants.white, for: .normal)
        
        
        //TODO: The following two listeners should be placed in any view which needs User Data
        self.user.privUserDoc.addSnapshotListener { documentSnapshot, error in
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
                    self.user.privProfile = data
                    print("Updated priv data")
                } else {
                    print("Document does not exist, got nil DocumentSnapshot")
                }
            case .failure(let error):
                print("Error decoding UserPrivate: \(error)")
            }
        }

        self.user.pubUserDoc.addSnapshotListener { documentSnapshot, error in
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
                    self.user.pubProfile = data
                    print("updated pub data")
                    print(self.user.getBio())
                } else {
                    print("Document does not exist, got nil DocumentSnapshot")
                }
            case .failure(let error):
                print("Error decoding UserPrivate: \(error)")
            }
        }
    }
}
