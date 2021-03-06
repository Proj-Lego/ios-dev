//
//  PhoneVerifyViewController.swift
//  Lego
//
//  Created by Shreyas Patankar on 3/23/20.
//  Copyright © 2020 Lego. All rights reserved.
//

import UIKit

class PhoneVerifyViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var otpLabel: UILabel!
    @IBOutlet weak var otpTxtField: UITextField!
    @IBOutlet weak var resendBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    var phoneNumber: String!
    var phoneTxt: String!
    
    override func viewWillAppear(_ animated: Bool) {
        otpTxtField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        if self.phoneNumber == nil {
            self.phoneNumber = "ERROR"
        }
        
        nextBtn.setImage(LegoDefaultImages.rightArrowForButton, for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.width / 2
        nextBtn.setTitle("", for: .normal)
        
        instructionLabel.text = "Enter the code sent to: " + phoneNumber
        otpTxtField.isHidden = true
        nextBtn.isHidden = true
        
        view.backgroundColor = LegoColorConstants.backgroundColor
        titleLabel.textColor = LegoColorConstants.white
        instructionLabel.textColor = LegoColorConstants.white
        otpLabel.textColor = LegoColorConstants.white
        resendBtn.setTitleColor(LegoColorConstants.white, for: .normal)
        nextBtn.backgroundColor = LegoColorConstants.white
    }
    
    
    @IBAction func otpEdited(_ sender: UITextField) {
        guard let numsTxt = otpTxtField.text else { return }
        otpTxtField.text = loginSession.getCleanOTP(from: numsTxt)
        otpLabel.text = loginSession.generateOTPString(from: otpTxtField.text!)
        if loginSession.otpIsValid(otp: otpTxtField.text!) {
            nextBtn.isHidden = false
        } else {
            nextBtn.isHidden = true
        }
    }
    
    @IBAction func resendCode(_ sender: UIButton) {
        loginSession.processPhoneNumber(countryCode: loginSession.getCountryCodeString(withFlag: false), phone: phoneTxt) { (success, errMsg) in
            var alertTxt = "Hang tight!"
            var errTxt = "We have resent the verification code"
            if !success {
                alertTxt = "Oops!"
                errTxt = errMsg
            }
            let alertController = UIAlertController(title: alertTxt, message: errTxt, preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(action)
            self.present(alertController, animated: false, completion: nil)
            return
        }
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        guard let numsTxt = otpTxtField.text else { return }
        loginSession.processOTP(otp: numsTxt) { (success, errMsg) in
            // TODO segue to home screen...
            var title = "Success"
            if !success {
                title = "Oops!"
            }
            let alertController = UIAlertController(title: title, message: errMsg, preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(action)
            self.present(alertController, animated: false, completion: nil)
            return
        }
    }
}

extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}
