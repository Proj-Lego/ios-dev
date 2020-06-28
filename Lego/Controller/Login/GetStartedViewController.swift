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

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var phoneArrow: UIImageView!
    @IBOutlet weak var phoneCircle: UIImageView!
    @IBOutlet weak var termsLabel: UILabel!
//    let user = User.init()
    
    override func viewWillAppear(_ animated: Bool) {
        if (Auth.auth().currentUser != nil) {
            print("signed in already")
            //TODO: Navigate to main screen
            print("User already logged in, can navigate away...")
//            user.setBio(bio: "hello guys!")
//            print("My bio is: " + user.getBio())
//            let shreyasID = "VAon5tawOJ1G4rKaGr28"
//            user.createChat(otherUserID: shreyasID)
//            user.sendMessageTo(otherUserID: shreyasID, message: "Hello wanker")
        }
        
        view.backgroundColor = LegoColorConstants.backgroundColor
        
        // TODO put 'welcome' in navigation bar title.
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = LegoColorConstants.purple
        navigationController?.navigationBar.barStyle = .black
        
        welcomeLabel.font = LegoFonts.SFProTextBold
        welcomeLabel.font = welcomeLabel.font.withSize(32)
        welcomeLabel.text = "Welcome"
        welcomeLabel.textColor = LegoColorConstants.white
        
        mainLabel.font = LegoFonts.SFProDisplayBold
        mainLabel.font = mainLabel.font.withSize(32)
        mainLabel.text = "Swipe \nUnlimited"
        mainLabel.textColor = LegoColorConstants.white
        mainLabel.numberOfLines = 0
        mainLabel.lineBreakMode = .byWordWrapping
        
        subLabel.font = LegoFonts.SFProTextBold
        subLabel.font = subLabel.font.withSize(14)
        subLabel.text = "Spin and get more than swipes"
        subLabel.textColor = LegoColorConstants.gray
        
        phoneBtn.setTitle("                    Phone login", for: .normal)
        phoneBtn.titleLabel?.font = LegoFonts.SFProTextMedium
        phoneBtn.titleLabel?.font = phoneBtn.titleLabel?.font.withSize(14)
        phoneBtn.contentHorizontalAlignment = .left
        phoneBtn.layer.cornerRadius = 15
        phoneBtn.backgroundColor = LegoColorConstants.buttonColor
        phoneBtn.setTitleColor(LegoColorConstants.white, for: .normal)
        
        phoneCircle.tintColor = LegoColorConstants.white
        
        phoneArrow.tintColor = LegoColorConstants.white
        phoneArrow.layer.cornerRadius = phoneArrow.frame.height / 2
        
        termsLabel.font = LegoFonts.SFProTextBold
        termsLabel.font = subLabel.font.withSize(14)
        termsLabel.text = "By joining you accept our\nterms and conditions"
        termsLabel.textColor = LegoColorConstants.gray
        termsLabel.numberOfLines = 0
        termsLabel.lineBreakMode = .byWordWrapping
        
        //TODO: The following two listeners should be placed in any view which needs User Data
//        self.user.privUserDoc.addSnapshotListener { documentSnapshot, error in
//            guard let document = documentSnapshot else {
//                print("Error fetching document: \(error!)")
//                return
//            }
//            let result = Result {
//                try document.data(as: PrivateProfile.self)
//            }
//            switch result {
//            case .success(let data):
//                if let data = data {
//                    self.user.privProfile = data
//                    print("Updated priv data")
//                } else {
//                    print("Document does not exist, got nil DocumentSnapshot")
//                }
//            case .failure(let error):
//                print("Error decoding UserPrivate: \(error)")
//            }
//        }
//        
//        self.user.pubUserDoc.addSnapshotListener { documentSnapshot, error in
//            guard let document = documentSnapshot else {
//                print("Error fetching document: \(error!)")
//                return
//            }
//            let result = Result {
//                try document.data(as: PublicProfile.self)
//            }
//            switch result {
//            case .success(let data):
//                if let data = data {
//                    self.user.pubProfile = data
//                    print("updated pub data")
//                    print(self.user.getBio())
//                } else {
//                    print("Document does not exist, got nil DocumentSnapshot")
//                }
//            case .failure(let error):
//                print("Error decoding UserPrivate: \(error)")
//            }
//        }
    }
}
