//
//  ViewController.swift
//  buzz
//
//  Created by Boris Teodorovich on 12/1/18.
//  Copyright © 2018 Boris Teodorovich. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

import Firebase

var CURRENT_LOCATION: CLLocation?
let CURRENT_USER = ["id": "F8p7evh7i3IYLnTP3pv9", "name": "Boris"]

class ViewController: UIViewController {

    var hives: [Hive] = []
    
    var myHive: Hive? {
        didSet {
            if (myHive != nil) {
                self.mainButton.setTitle("Disband Hive", for: UIControl.State.normal)
            }
            else {
                self.mainButton.setTitle("Create New Hive", for: UIControl.State.normal)
            }
        }
        
    }
    
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        mapView.delegate = self
        mapView.showsUserLocation = true

        getHives()
        

//        let initialLocation = CLLocation(latitude: 37.0007851, longitude: -122.0652756)
//        centerMapOnLocation(location: initialLocation)
    }

    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func getHives() {
        let ref = Firestore.firestore().collection("hives").limit(to: 100);
        
        ref.addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.mapView.removeAnnotations(self.hives)
                self.hives = []
                
                var myNewHive: Hive? = nil
                for document in querySnapshot!.documents {
                    let point = document.data()["coordinates"] as! GeoPoint
                    let latitude: Double = point.latitude
                    let longitude: Double = point.longitude
                    
                    let temp = Hive(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                                    name: document.data()["courseName"] as! String,
                                    courseID: document.data()["courseID"] as! String,
                                    queenID: document.data()["queenID"] as! String,
                                    queenName: document.data()["queenName"] as! String,
                                    members: document.data()["members"] as! Int,
                                    id: document.documentID)
                
                    self.hives.append(temp)
                    if temp.queenID == CURRENT_USER["id"]! {
                        myNewHive = temp
                    }
                    print("\(document.documentID) => \(document.data())")
                }
                self.myHive = myNewHive
                self.mapView.addAnnotations(self.hives)
            }
            
        }

    }

    @IBAction func mainButtonPressed(_ sender: UIButton) {
        guard let myHive = myHive else {
            let newHiveVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewHive")
            self.present(newHiveVC, animated: true, completion: nil)
            return
        }
        
        Firestore.firestore().collection("hives").document(myHive.id).delete() { err in
            if let err = err {
                print("Error writing document: \(err)")
                return
            }
            else {
         
            }
            
        }
        Firestore.firestore().collection("courses").document(myHive.courseID).getDocument() { (document, error) in
            if let document = document, document.exists {
                let hives: Int = document.data()!["hives"] as! Int
                
                Firestore.firestore().collection("courses").document(myHive.courseID).updateData(["hives": hives - 1]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                        return
                    }
                    else {
                        print("Document successfully written!")
                        self.myHive = nil
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
     
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CURRENT_LOCATION = locations.last
        if let lat = CURRENT_LOCATION?.coordinate.latitude, let long = CURRENT_LOCATION?.coordinate.longitude {
            print("\(lat),\(long)")
            centerMapOnLocation(location: CURRENT_LOCATION!)
        } else {
            print("No coordinates")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension ViewController: MKMapViewDelegate {
    // 1
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? Hive else { return nil }
        // 3
        let identifier = "hive"
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        if (annotation.queenID == CURRENT_USER["id"]) {
            view.markerTintColor = UIColor.green
            view.displayPriority = MKFeatureDisplayPriority.required
        }
        else {
            view.markerTintColor = UIColor.yellow
        }
        view.glyphTintColor = UIColor.black
        view.glyphImage = UIImage(named: "comb")
        view.titleVisibility = MKFeatureVisibility.visible
//        // 4
//        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//            as? MKMarkerAnnotationView {
//            dequeuedView.annotation = annotation
//            view = dequeuedView
//        } else {
//            // 5
//            view.canShowCallout = true
//            view.calloutOffset = CGPoint(x: -5, y: 5)
//            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        }
        return view
    }
}
