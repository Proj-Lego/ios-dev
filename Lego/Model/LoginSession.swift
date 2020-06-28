//
//  Login.swift
//  Lego
//
//  Created by Shreyas Patankar on 3/23/20.
//  Copyright © 2020 Lego. All rights reserved.
//

import Foundation
import Firebase
import PhoneNumberKit

var session = LoginSession()

struct Country {
    var name: String!
    var flag: String!
    var code: UInt64!
}

class LoginSession {
    
    var country: Country!
    var phoneNumber: String!
    var otp: String!
    var phoneValid: Bool!
    var otpValid: Bool!
    var countries: [Country]
    
    let phoneNumberKit = PhoneNumberKit()
    let otpLen = 6
    
    init() {
        countries = []
        for c in phoneNumberKit.allCountries() {
            let name = countryName(from: c)
            if name != "World" {
                countries.append(Country(name: name, flag: flag(country: c), code: phoneNumberKit.countryCode(for: c)))
            }
        }
        
        setDefaultCountry()
    }
    
    func setDefaultCountry() {
        if let countryAbbrev = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            country = Country(name: countryName(from: countryAbbrev), flag: flag(country: countryAbbrev), code: phoneNumberKit.countryCode(for: countryAbbrev))
        } else {
            country = Country(name: "United States", flag: "🇺🇸", code: 1)
        }
    }
    
    func getCountryCodeString(withFlag: Bool) -> String {
        if withFlag {
            return session.country.flag + " +" + String(session.country.code)
        } else {
            return "+" + String(session.country.code)
        }
    }
    
    func flag(country:String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
    
    func countryName(from countryCode: String) -> String {
        if let name = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: countryCode) {
            return name
        } else {
            return countryCode
        }
    }
    
    func processPhoneNumber(countryCode: String, phone: String, completion: @escaping (Bool, String) -> ()) {
        if !self.phoneIsValid(phone: phone) { // phone invalid
            completion(false, "Phone number was in an invalid format.")
        }
        self.phoneNumber = countryCode + phone
        var phoneNumber: PhoneNumber
        do {
            phoneNumber = try phoneNumberKit.parse("+" + String(self.country.code) + phone)
        } catch {
            completion(false, "Could not parse phoneNumber to object")
            return
        }
        // Phone format validated, use Firebase to send push
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumberKit.format(phoneNumber, toType: .e164), uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            UserDefaults.standard.synchronize()
            completion(true, "")
        }
    }
    
    func processOTP(otp: String, completion: @escaping (Bool, String) -> ()){
        // verify otp
        if !self.otpIsValid(otp: otp) { // otp invalid
            completion(false, "Code was in an invalid format.")
            return
        }
        // OTP validated, now authenticate with Firebase
        self.otp = otp
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {
            completion(false, "Failed to unwrap verification ID")
            return
        }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: otp)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            completion(true, "")
        }
    }
    
    func phoneIsValid(phone: String) -> Bool {
        return phoneValid
    }
    
    func cleanAndGeneratePhoneString(phone phoneTxt: String) -> String {
        do {
            let phoneNumber = try phoneNumberKit.parse("+" + String(self.country.code) + phoneTxt)
            phoneValid = true
            return phoneNumberKit.format(phoneNumber, toType: .national)
        } catch {
            phoneValid = false
        }
        return PartialFormatter().formatPartial(phoneTxt)
    }
    
    func otpIsValid(otp numsTxt: String) -> Bool {
        return otpValid
    }
    
    func getCleanOTP(from numsTxt: String) -> String {
        var cleanedTxt = numsTxt
        
        // Make sure OTP is valid length
        if cleanedTxt.count > otpLen {
            cleanedTxt = String(cleanedTxt.prefix(otpLen))
        }
        
        // Make sure most recently entered character is valid
        if cleanedTxt.count > 0 && (cleanedTxt[cleanedTxt.count - 1] < "0" || cleanedTxt[cleanedTxt.count - 1] > "9") {
            cleanedTxt = String(cleanedTxt.prefix(cleanedTxt.count - 1))
        }
        
        // If after trimming, otp is otpLen characters long, then it is valid
        if cleanedTxt.count == otpLen {
            otpValid = true
        } else {
            otpValid = false
        }
        
        return cleanedTxt
    }
    
    // Construct the OTP string to be displayed
    func generateOTPString(from cleanedTxt: String) -> String {
        var result = ""
        for i in 0..<otpLen {
            if i < cleanedTxt.count {
                result += cleanedTxt[i]
            } else {
                result += "_"
            }
            if i < otpLen {
                result += " "
            }
        }
        return result
    }
}
