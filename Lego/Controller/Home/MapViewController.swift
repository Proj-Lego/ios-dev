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

class MapViewController: UIViewController {
    
    @IBOutlet weak var eventBtn: UIButton!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0

    var events: [EventInfo] = []

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
    

    func getEventsNearBy(location: CLLocationCoordinate2D) {
        getEventsNearBy(latitude: location.latitude, longitude: location.longitude, distance: 60)
    }

    func getEventsNearBy(latitude: Double, longitude: Double, distance: Double) {
        // ~1 mile of lat and lon in degrees
        let lat = 0.0144927536231884
        let lon = 0.0181818181818182

        let lowerLat = latitude - (lat * distance)
        let lowerLon = longitude - (lon * distance)

        let greaterLat = latitude + (lat * distance)
        let greaterLon = longitude + (lon * distance)

        let lesserGeopoint = GeoPoint(latitude: lowerLat, longitude: lowerLon)
        let greaterGeopoint = GeoPoint(latitude: greaterLat, longitude: greaterLon)

        let docRef = Firestore.firestore().collection(LegoFSConsts.eventsColl)
        let query = docRef.whereField("location", isGreaterThan: lesserGeopoint).whereField("location", isLessThan: greaterGeopoint)
        
        var nearbyEvents: [EventInfo] = []
        
        query.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error getting event documents: \(error)")
            } else {
                for document in snapshot!.documents {
                    let result = Result {
                        try document.data(as: EventInfo.self)
                    }
                    switch result {
                    case .success(let data):
                        if let data = data {
                            nearbyEvents.append(data)
                            let markerLoc = CLLocationCoordinate2D.init(latitude: data.location.latitude, longitude: data.location.longitude)
                            let iconData = try? Data(contentsOf: data.picture)
                            let icon = UIImage(data: iconData!)!.resizeImage(targetSize: CGSize(width: LegoMapConstants.markerSize, height: LegoMapConstants.markerSize))
                            self.addMarker(title: data.name, description: data.description, location: markerLoc, icon: icon)
                            
                        } else {
                            print("Document does not exist, got nil DocumentSnapshot")
                        }
                    case .failure(let error):
                        print("Error decoding UserPrivate: \(error)")
                    }
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
        events = nearbyEvents
    }
    
    
    private func addMarker(title: String, description: String, location: CLLocationCoordinate2D, icon: UIImage?) {
        let marker = GMSMarker()
        marker.position = location
        marker.title = title
        marker.snippet = description
        marker.icon = icon
        marker.map = mapView
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
        getEventsNearBy(location: currentLocation!.coordinate)
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
