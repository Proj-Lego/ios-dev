//
//  MapViewController.swift
//  Lego
//
//  Created by Shreyas Patankar on 6/30/20.
//  Copyright © 2020 Lego. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import CoreLocation
import FirebaseStorage

class MapViewController: UIViewController {
    
    @IBOutlet weak var eventBtn: UIButton!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0

    var events: [Event] = []
    var eventMarkerDict: [String: GMSMarker] = [:]

    // A default location to use when location permission is not granted.
    let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
    }
    
    private func setupMapView() {
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self

        // Create a map.
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true

        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        view.sendSubviewToBack(mapView)
        mapView.isHidden = true
    }
    
    private func addMarker(eventID: String, title: String, description: String, location: CLLocationCoordinate2D, icon: UIImage?) {
        var marker = eventMarkerDict[eventID]
        if marker == nil {
            marker = GMSMarker()
            eventMarkerDict[eventID] = marker
        }
        marker!.position = location
        marker!.title = title
        marker!.snippet = description
        marker!.icon = icon
        marker!.map = mapView
    }
    
    private func removeMarker(eventID: String) {
        let marker = eventMarkerDict[eventID]
        marker?.map = nil
    }
    
    @IBAction func addEventPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "mapToEventSegue", sender: sender)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapToEventSegue" {
            if let destVC = segue.destination as? AddEventViewController {
                destVC.curLoc = currentLocation!
            }
        }
    }
}

// Delegates to handle events for the location manager.
extension MapViewController: CLLocationManagerDelegate {

    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!
        print("Location: \(String(describing: currentLocation))")
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation!.coordinate.latitude,
                                              longitude: currentLocation!.coordinate.longitude,
                                                zoom: zoomLevel)
        
        listenToNearbyEvents(location: currentLocation!.coordinate) { event, error in
            
            if error != nil {
                //TODO: Show some alert!
                print("Failed to get nearby events \(String(describing: error))")
                return
            }
            let markerLoc = CLLocationCoordinate2D.init(latitude: event.eventInfo.location.latitude, longitude: event.eventInfo.location.longitude)
            let icon = event.getPicture().resizeImage(targetSize: CGSize(width: LegoMapConstants.markerSize, height: LegoMapConstants.markerSize))
            
            
            self.addMarker(eventID: event.eventDoc.documentID, title: event.eventInfo.name, description: event.eventInfo.description, location: markerLoc, icon: icon)
            self.events.append(event)
        }
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
    }

    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        @unknown default:
            fatalError()
        }
    }

    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
