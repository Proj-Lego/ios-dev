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

var events: [EventInfo] = []

struct EventInfo: Codable {
    @DocumentID var id: String? = UUID().uuidString
    var name : String = ""
    var picture : URL = URL.init(fileURLWithPath: "")
    var description : String = ""
    var location: GeoPoint = GeoPoint.init(latitude: 0, longitude: 0)
    var users: Set<String> = []
    var hostID: String = ""
}

class Event {
    let db = Firestore.firestore()
    var picRef: StorageReference
    var eventDoc: DocumentReference
    var eventInfo = EventInfo()
    
    init(name: String, picture: URL? = nil, description: String, location: CLLocation, hostID: String) {
        print("creating event...")
        eventDoc = db.collection(LegoFSConsts.eventsColl).document()
        if picture == nil {
            picRef = Storage.storage().reference().child(LegoFSConsts.eventsStorage).child("default_image.png")
        } else {
            picRef = Storage.storage().reference().child(LegoFSConsts.eventsStorage).child(eventDoc.documentID)
            picRef.putFile(from: picture!, metadata: nil) { metadata, error in
                if error != nil {
                    print("Failed to upload profile picture \(String(describing: error))")
                    return
                }
            }
        }
        picRef.downloadURL { (url, error) in
            let geoLoc = GeoPoint.init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            if error != nil {
                print("Failed to get downloadURL reference for event picture")
                self.eventInfo = EventInfo(name: name, description: description, location: geoLoc, users: [hostID], hostID: hostID)
            } else {
                self.eventInfo = EventInfo(name: name, picture: url!, description: description, location: geoLoc, users: [hostID], hostID: hostID)
            }
            do {
                try self.eventDoc.setData(from: self.eventInfo)
            } catch {
                //TODO: throw some exception if JSON encoding failed
                print(error)
            }
        }
    }
    
    func setPicture(picture: URL?) {
        if picture == nil {
            picRef = Storage.storage().reference().child(LegoFSConsts.eventsStorage).child("default_image.png")
        } else {
            picRef = Storage.storage().reference().child(LegoFSConsts.eventsStorage).child(eventDoc.documentID)
            picRef.putFile(from: picture!, metadata: nil) { metadata, error in
                if error != nil {
                    print("Failed to upload profile picture \(String(describing: error))")
                    return
                }
            }
        }
        self.picRef.downloadURL { (url, error) in
            if error != nil {
                print("Failed to get downloadURL reference for event picture")
                return
            }
            self.eventDoc.setData(["picture": url!])
        }
    }
    
    func getPicture() -> StorageReference {
        return picRef
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
