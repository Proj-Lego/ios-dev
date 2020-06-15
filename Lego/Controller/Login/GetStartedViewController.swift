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
    
    override func viewWillAppear(_ animated: Bool) {
//        Testing Create User Code :
//        if (Auth.auth().currentUser != nil) {
//            print("User already logged in, can navigate away...")
//            let user = User.init()
//            user.createUser()
//            user.setPOIGender(gender: "Female")
//            user.setGender(gender: "Male")
//            user.setBio(bio: "New Bio!")
//            user.loadFromDB()
//        }
        
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
    }

}
