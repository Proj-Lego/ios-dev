//
//  MapViewController.swift
//  Lego
//
//  Created by Shreyas Patankar on 6/30/20.
//  Copyright © 2020 Lego. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var eventBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Obtain current location
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        var currentLoc: CLLocation!
        
        // Create a GMSCameraPosition that tells the map to display the current location.
        var camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 15)
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
        CLLocationManager.authorizationStatus() == .authorizedAlways) {
           currentLoc = locationManager.location
            camera = GMSCameraPosition.camera(withLatitude: currentLoc.coordinate.latitude, longitude: currentLoc.coordinate.longitude, zoom: 15)
        }
        let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.view.addSubview(mapView)
        self.view.bringSubviewToFront(self.eventBtn)

        // Marker boilerplate code.
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
//        marker.map = mapView
    }
    
    @IBAction func addEventPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "mapToEventSegue", sender: sender)
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
