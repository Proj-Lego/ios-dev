//
//  Host.swift
//  Lego
//
//  Created by Abhinav Pottabathula on 6/12/20.
//  Copyright © 2020 Lego. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseStorage

struct EventInfo: Codable {
    @DocumentID var id: String? = UUID().uuidString
    var name: String = ""
    var pictureRef: String = ""
    var description: String = ""
    var location: GeoPoint = GeoPoint.init(latitude: 0, longitude: 0)
    var users: Set<String> = []
    var hostID: String = ""
}

class Event: Equatable {
    let db = Firestore.firestore()
    let eventStorageRef = Storage.storage().reference().child(LegoFSConsts.eventsStorage)
    var eventDoc: DocumentReference
    var eventInfo = EventInfo()
    var loadedImage = UIImage()
    
    init(eventInfo: EventInfo, completion: @escaping (Event, Error?) -> Void) { //Load EventInfo as an Event Object which has already been made before.
        self.eventDoc = db.collection(LegoFSConsts.eventsColl).document(eventInfo.id!)
        self.eventInfo = eventInfo
        Event.loadImageFromRef(ref: Storage.storage().reference().child(LegoFSConsts.eventsStorage).child(eventInfo.pictureRef)) { image, error in
            if error != nil {
                print("Could not load image reference \(String(describing: error))")
                completion(self, error)
            }
            self.loadedImage = image
            completion(self, nil)
        }
    }
    
    init(name: String, picture: NSData?, description: String, location: CLLocation, hostID: String) { //Create event
        print("creating event...")
        eventDoc = db.collection(LegoFSConsts.eventsColl).document()
        let geoLoc = GeoPoint.init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        eventInfo = EventInfo(id: self.eventDoc.documentID, name: name, description: description, location: geoLoc, users: [hostID], hostID: hostID)
        do {
            try self.eventDoc.setData(from: self.eventInfo)
        } catch {
            print("Failed to create event \(error)")
        }
        setPicture(picture: picture) { error in
            if error != nil {
                print("Failed to set picture \(String(describing: error))")
            }
            do {
                try self.eventDoc.setData(from: self.eventInfo)
            } catch {
                print("Failed to create event \(error)")
            }
        }
    }
        
    func setPicture(picture: NSData?, completion: @escaping (Error?) -> Void) {
        if picture == nil {
            self.eventDoc.updateData(["pictureRef": "default_image.png"])
            let picRef = eventStorageRef.child("default_image.png")
            Event.loadImageFromRef(ref: picRef) { image, error in
                if error != nil {
                    print("Could not load image reference \(String(describing: error))")
                }
                self.loadedImage = image
            }
        } else {
            self.eventDoc.updateData(["pictureRef": eventDoc.documentID])
            let picRef = eventStorageRef.child(eventDoc.documentID)
            picRef.putData(picture! as Data, metadata: nil) { (metadata, error) in
                if error != nil {
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    private static func loadImageFromRef(ref: StorageReference, completion: @escaping (UIImage, Error?) -> Void) {
        ref.getData(maxSize: Int64.max) { data, error in
            if let error = error {
                completion(UIImage(), error)
            } else {
                completion(UIImage(data: data!)!, nil)
            }
        }
    }
    
    func getPicture() -> UIImage {
        return loadedImage
    }
    
    func setName(name: String) {
        eventDoc.updateData(["name": name])
    }
    
    func getName() -> String {
        return eventInfo.name
    }
    
    func setDescription(name: String) {
        eventDoc.updateData(["description": name])
    }
    
    func getDescription() -> String {
        return eventInfo.description
    }
    
    func setLocation(loc: CLLocation) {
        self.setLocation(lat: loc.coordinate.latitude, long: loc.coordinate.longitude)
    }
    
    func setLocation(lat: Double, long: Double) {
        eventDoc.updateData(["location": GeoPoint.init(latitude: lat, longitude: long)])
    }
    
    func getLocation() -> (lat: Double, long: Double) {
        return (eventInfo.location.latitude, eventInfo.location.longitude)
    }
    
    func setUsers(uids: Set<String>) {
        eventDoc.updateData(["users": uids])
    }
    
    func getUsers() -> Set<String> {
        return eventInfo.users
    }
    
    func setHostID(id: String) {
        eventDoc.updateData(["hostID": id])
    }
    
    func getHostID() -> String {
        return eventInfo.hostID
    }
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.eventDoc.documentID == rhs.eventDoc.documentID
    }
}

func listenToNearbyEvents(location: CLLocationCoordinate2D, completion: @escaping (Event, Error?) -> Void) {
    listenToNearbyEvents(latitude: location.latitude, longitude: location.longitude, distance: 60, completion: completion)
}

func listenToNearbyEvents(latitude: Double, longitude: Double, distance: Double, completion: @escaping (Event, Error?) -> Void) {
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
                        Event(eventInfo: data) { event, error in
                            if error != nil {
                                print("Error initializing event \(event)")
                            }
                            completion(event, error)
                        }
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
}
