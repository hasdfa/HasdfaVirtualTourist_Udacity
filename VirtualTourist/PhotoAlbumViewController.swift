//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Raksha Vadim on 28.07.17.
//  Copyright © 2017 Raksha Vadim. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: CoreDataViewController {

    var annotation: MKAnnotation? = nil
    var pin: Pin? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlow: UICollectionViewFlowLayout!
    
    var photos: [Photo] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fr.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        if fetchedResultsController?.sections?.count == 0 {
            NetworksHelper.searchByLatLon(annotation!.coordinate.latitude, annotation!.coordinate.longitude, pin: pin, {
                
                
                print("photosCount is ", self.photos.count)
                
                DispatchQueue.main.async {
                    print("loaded")
                    self.collectionView.reloadData()
                }
            })
        } else {
            
        }

        // Setup Flow layout
        let space:CGFloat = 0.5
        
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        collectionViewFlow.minimumInteritemSpacing = space
        collectionViewFlow.minimumLineSpacing = space
        collectionViewFlow.itemSize = CGSize(width: dimension, height: dimension)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let _2d = CLLocationCoordinate2D(latitude: (pin?.lat)!, longitude: (pin?.lon)!)
        mapView.addAnnotation(MKPlacemark(coordinate: _2d))
        mapView.camera.centerCoordinate = _2d
        mapView.camera.altitude = 1_000_000
    }
    
    override func reloadData(){
        self.collectionView.reloadData()
    }
    override func insertItem(_ indexPath: IndexPath) {
        self.collectionView.insertItems(at: [indexPath])
    }
    override func deleteItem(_ indexPath: IndexPath) {
        self.collectionView.deleteItems(at: [indexPath])
    }
    override func updateItem(_ indexPath: IndexPath) {
        self.collectionView.deleteItems(at: [indexPath])
        self.collectionView.insertItems(at: [indexPath])
    }
    override func didChangeUpdates() {
        
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count == 0 ? 21 : photos.count
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dCell", for: indexPath) as? PhotoCell
        
        let photo: Photo = fetchedResultsController?.object(at: indexPath) as! Photo
        if let cell = cell {
            if photos.count == 0 {
                cell.progress.startAnimating()
                cell.layer.borderColor = UIColor.blue.cgColor
                cell.layer.borderWidth = 3
            } else {
                if cell.progress.isAnimating {
                    cell.progress.stopAnimating()
                }
                cell.thumbnail.image = UIImage(data: photos[indexPath.row].imageData! as Data)
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.layer.borderWidth = 0
            }
        }
        
        return cell ?? UICollectionViewCell()
    }
    
}
