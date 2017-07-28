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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if fetchedResultsController?.fetchedObjects?.count ?? 0 == 0 {
            NetworksHelper.searchByLatLon(annotation!.coordinate.latitude, annotation!.coordinate.longitude, pin: pin, {
                DispatchQueue.main.async {
                    print("loaded")
                    self.collectionView.reloadData()
                }
            })
        } else {
            self.collectionView.reloadData()
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
        if isViewLoaded {
            self.collectionView.reloadData()
        }
    }
    override func insertItem(_ indexPath: IndexPath) {
        if isViewLoaded {
            self.collectionView.insertItems(at: [indexPath])
        }
    }
    override func deleteItem(_ indexPath: IndexPath) {
        if isViewLoaded {
            self.collectionView.deleteItems(at: [indexPath])
        }
    }
    override func updateItem(_ indexPath: IndexPath) {
        if isViewLoaded {
            self.collectionView.deleteItems(at: [indexPath])
            self.collectionView.insertItems(at: [indexPath])
        }
    }
    override func didChangeUpdates() {
        
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = fetchedResultsController?.fetchedObjects?.count ?? 0
        return count == 0 ? 21 : count
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dCell", for: indexPath)
        
        if let cell = cell as? PhotoCell {
            let count = fetchedResultsController?.fetchedObjects?.count ?? 0
            if count > indexPath.row {
                if let photo = fetchedResultsController?.object(at: indexPath) as? Photo {
                    if cell.progress.isAnimating {
                        cell.progress.stopAnimating()
                    }
                    cell.thumbnail.image = UIImage(data: photo.imageData! as Data)
                    cell.layer.borderColor = UIColor.clear.cgColor
                    cell.layer.borderWidth = 0
                } else {
                    cell.progress.startAnimating()
                    cell.layer.borderColor = UIColor.blue.cgColor
                    cell.layer.borderWidth = 3
                } 
            }
        } else {
            cell.backgroundView?.backgroundColor = UIColor.red
        }
        
        
        return cell
    }
    
}
