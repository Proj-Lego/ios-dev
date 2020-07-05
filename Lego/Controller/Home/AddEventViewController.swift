//
//  AddEventViewController.swift
//  Lego
//
//  Created by Shreyas Patankar on 7/1/20.
//  Copyright © 2020 Lego. All rights reserved.
//

import UIKit
import CoreLocation

class AddEventViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var eventNameField: UITextField!
    @IBOutlet weak var eventDescField: UITextField!
    @IBOutlet weak var eventLocationField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    var curLoc = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Add an Event"
        updateAddressFromLatLon(pdblLatitude: String(curLoc.coordinate.latitude), withLongitude: String(curLoc.coordinate.longitude))
        eventLocationField.isUserInteractionEnabled = false
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        let eventName = eventNameField.text!
        let eventDesc = eventDescField.text!
        let event = Event(name: eventName, description: eventDesc, location: curLoc, hostID: "hostID")
        print(event.getPicture())
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func updateAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        //21.228124
        let lon: Double = Double("\(pdblLongitude)")!
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon

        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]

                if pm.count > 0 {
                    let pm = placemarks![0]
                    var addressString : String = ""
                    if pm.subThoroughfare != nil {
                        addressString = addressString + pm.subThoroughfare! + " "
                    }
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality!
                    }

                    print("Address String: \(addressString)")
                    self.eventLocationField.text = addressString
              }
        })
    }
}
