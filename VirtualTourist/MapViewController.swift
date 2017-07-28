//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Raksha Vadim on 28.07.17.
//  Copyright © 2017 Raksha Vadim. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: CoreDataViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePinsViewHelper: UIView!
    
    var localPins: [Pin] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
        
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        setupMapView()
        mapView.delegate = self
        
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 0.33
        mapView.addGestureRecognizer(longPressRecogniser)
    }
    
    func setupMapView(){
        mapView.removeAnnotations(mapView.annotations)
        
        for pin in fetchedResultsController?.fetchedObjects as! [Pin] {
            let annotation = MKPinPlacemark(coordinate: CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.lon))
            annotation.pin = pin
            DispatchQueue.main.async {
                self.mapView.addAnnotation(annotation)
            }
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
        mapView.camera.altitude = UserDefaults.standard.double(forKey: "mc_altitude")
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

    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(mapView.camera.altitude, forKey: "mc_altitude")
        UserDefaults.standard.set(mapView.camera.centerCoordinate.latitude, forKey: "mc_latitude")
        UserDefaults.standard.set(mapView.camera.centerCoordinate.longitude, forKey: "mc_longitude")
    }
}

// CoreDataVC "delegates"
extension MapViewController {
    fileprivate func setupDelegate(){
        reloadData = {
            self.setupMapView()
        }
        insertItem = {
            indexPath -> Void in
            
        }
        deleteItem = {
            indexPath -> Void in
            
        }
        updateItem = {
            indexPath -> Void in
            
        }
        didChangeUpdates = {
            
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if isEditingMapPins {
            mapView.removeAnnotation(view.annotation!)
            
        } else {
            if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "photoVC") as? PhotoAlbumViewController {
                nextVC.annotation = view.annotation
                nextVC.pin = (view.annotation as? MKPinPlacemark)?.pin
                self.navigationController!.pushViewController(nextVC, animated: true)
            }
        }
    }
}
