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
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Add an Event"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        let eventName = eventNameField.text!
        let eventDesc = eventDescField.text!
        // TODO push strings to firebase (preferably via model)
        
        let event = Event(name: eventName, description: eventDesc, location: CLLocation.init(), hostID: "hostID")
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

}
