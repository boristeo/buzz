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

class ViewController: UIViewController {

    var hives: [Hive] = []
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        mapView.delegate = self

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
                for document in querySnapshot!.documents {
                    let point = document.data()["coordinates"] as! GeoPoint
                    let latitude: Double = point.latitude
                    let longitude: Double = point.longitude
                    
                    let temp = Hive(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                                    name: document.data()["courseName"] as! String,
                                    queen: document.data()["queenName"] as! String,
                                    members: document.data()["members"] as! Int,
                                    id: document.documentID)
                
                    self.hives.append(temp)
                    print("\(document.documentID) => \(document.data())")
                }
                self.mapView.addAnnotations(self.hives)
            }
            
        }

    }

}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lat = locations.last?.coordinate.latitude, let long = locations.last?.coordinate.longitude {
            print("\(lat),\(long)")
            centerMapOnLocation(location: locations.last!)
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
        view.markerTintColor = UIColor.yellow
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
