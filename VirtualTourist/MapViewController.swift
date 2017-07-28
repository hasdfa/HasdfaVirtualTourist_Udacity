//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Raksha Vadim on 28.07.17.
//  Copyright © 2017 Raksha Vadim. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePinsViewHelper: UIView!
    
    var localPins: [Pin] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 0.33
        mapView.addGestureRecognizer(longPressRecogniser)
        
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        
        do {
            localPins = (try context?.fetch(Pin.fetchRequest()))!
            for pin in localPins {
                let annotation = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.lon))
                DispatchQueue.main.async {
                    self.mapView.addAnnotation(annotation)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var isEditingMapPins = false
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        isEditingMapPins = !isEditingMapPins
        if isEditingMapPins {
            sender.title = "Done"
            sender.isEnabled = false
            UIView.animate(withDuration: 0.25, animations: {
                self.mapView.frame.origin.y -= 44
                self.deletePinsViewHelper.frame.origin.y -= 44
            }) {
                bool -> Void in
                sender.isEnabled = true
            }
        } else {
            sender.title = "Edit"
            sender.isEnabled = false
            UIView.animate(withDuration: 0.25, animations: {
                self.mapView.frame.origin.y += 44
                self.deletePinsViewHelper.frame.origin.y += 44
            }) {
                bool -> Void in
                sender.isEnabled = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.camera.altitude = 1_000_000
        mapView.centerCoordinate.longitude = UserDefaults.standard.double(forKey: "mc_latitude")
        mapView.centerCoordinate.latitude = UserDefaults.standard.double(forKey: "mc_longitude")
    }
    
    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != .began { return }
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let currrentAnnotation = MKPinPlacemark(coordinate: touchMapCoordinate)
        let pin = Pin(context: ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext)!)
        pin.lon = currrentAnnotation.coordinate.longitude
        pin.lat = currrentAnnotation.coordinate.latitude
        currrentAnnotation.pin = pin
        mapView.addAnnotation(currrentAnnotation)
    }

    override func viewDidAppear(_ animated: Bool) {
        UserDefaults.standard.set(mapView.centerCoordinate.latitude, forKey: "mc_latitude")
        UserDefaults.standard.set(mapView.centerCoordinate.longitude, forKey: "mc_longitude")
    }
}


extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if isEditingMapPins {
            mapView.removeAnnotation(view.annotation!)
            if let pin = ((view.annotation as? MKPinPlacemark)?.pin) {
                (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext.delete(pin)
            }
        } else {
            if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "photoVC") as? PhotoAlbumViewController {
                nextVC.annotation = view.annotation
                nextVC.pin = (view.annotation as? MKPinPlacemark)?.pin
                self.navigationController!.pushViewController(nextVC, animated: true)
            }
        }
    }
}
