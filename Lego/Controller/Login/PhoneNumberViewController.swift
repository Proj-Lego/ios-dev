//
//  PhoneNumberViewController.swift
//  Lego
//
//  Created by Shreyas Patankar on 3/23/20.
//  Copyright © 2020 Lego. All rights reserved.
//

import UIKit

class PhoneNumberViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var phoneNumberTxtField: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var countryCodeBtn: UIButton!
    @IBOutlet weak var differentSignInBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        phoneNumberTxtField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        nextBtn.setImage(LegoDefaultImages.rightArrowForButton, for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.width / 2
        nextBtn.setTitle("", for: .normal)
        nextBtn.isHidden = true
        
        phoneNumberTxtField.clipsToBounds = true
        phoneNumberTxtField.layer.cornerRadius = phoneNumberTxtField.frame.height / 2
        phoneNumberTxtField.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        session.setDefaultCountry()
        countryCodeBtn.clipsToBounds = true
        countryCodeBtn.layer.cornerRadius = countryCodeBtn.frame.height / 2
        countryCodeBtn.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        countryCodeBtn.setTitleColor(LegoColorConstants.black, for: .normal)
        countryCodeBtn.setTitle(session.getCountryCodeString(withFlag: true), for: .normal)
        
        view.backgroundColor = LegoColorConstants.darkBlue
        titleLabel.textColor = LegoColorConstants.white
        instructionLabel.textColor = LegoColorConstants.white
        nextBtn.backgroundColor = LegoColorConstants.white
        countryCodeBtn.backgroundColor = LegoColorConstants.white
        differentSignInBtn.setTitleColor(LegoColorConstants.aqua, for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let verifyController = segue.destination as? PhoneVerifyViewController
        let (_, phoneTxt) = extractPhoneInfo()
        verifyController?.phoneNumber = session.getCountryCodeString(withFlag: false) + " " + session.cleanAndGeneratePhoneString(phone: phoneTxt)
    }
    
    // Returns country code and phone number separately
    func extractPhoneInfo() -> (String, String) {
        guard let phoneTxt = phoneNumberTxtField.text else { return ("", "") }
        guard let countryBtnContents = countryCodeBtn.titleLabel?.text else { return ("", phoneTxt)}
        return (String(countryBtnContents.split(separator: " ")[1]), phoneTxt)
    }
    
    @IBAction func differentSignInPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Oops!", message: "We currently only support phone sign in, check back later for more options.", preferredStyle: .alert)
                   let action = UIAlertAction(title: "Dismiss", style: .default) { (action) in
                       self.dismiss(animated: true, completion: nil)
                   }
                   alertController.addAction(action)
                   present(alertController, animated: false, completion: nil)
                   return
    }
    
    @IBAction func phoneNumberChanged(_ sender: UITextField) {
        let (_, phoneTxt) = extractPhoneInfo()
        phoneNumberTxtField.text = session.cleanAndGeneratePhoneString(phone: phoneTxt)
        if session.phoneIsValid(phone: phoneNumberTxtField.text!) {
            nextBtn.isHidden = false
        } else {
            nextBtn.isHidden = true
        }
    }
    
    @IBAction func nextPressed(_ sender: UIButton) {
        let (countryCode, phoneTxt) = extractPhoneInfo()
        session.processPhoneNumber(countryCode: countryCode, phone: phoneTxt) { (success, errMsg) in
            if !success {
                let alertController = UIAlertController(title: "Oops!", message: errMsg, preferredStyle: .alert)
                let action = UIAlertAction(title: "Dismiss", style: .default) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(action)
                self.present(alertController, animated: false, completion: nil)
                return
            }
            self.performSegue(withIdentifier: "phoneNumberToPhoneVerify", sender: sender)
        }
    }
    
    @IBAction func countryCodePressed(_ sender: Any) {
        let countryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectCountryViewController") as! SelectCountryViewController
        countryViewController.delegate = self
        
        present(countryViewController, animated: true)
    }
}

extension PhoneNumberViewController: SelectCountryDelegate {
    func changeCountry(country: Country) {
        self.dismiss(animated: true) {
            session.country = country
            self.countryCodeBtn.setTitle(session.getCountryCodeString(withFlag: true), for: .normal)
            let (_, phoneTxt) = self.extractPhoneInfo()
            self.phoneNumberTxtField.text = session.cleanAndGeneratePhoneString(phone: phoneTxt)
            if session.phoneIsValid(phone: self.phoneNumberTxtField.text!) {
                self.nextBtn.isHidden = false
            } else {
                self.nextBtn.isHidden = true
            }
        }
    }
}
