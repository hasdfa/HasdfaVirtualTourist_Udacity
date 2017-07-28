//
//  CoreDataViewController.swift
//
//
//  Created by Fernando Rodríguez Romero on 22/02/16.
//  Copyright © 2016 udacity.com. All rights reserved.
//

import UIKit
import CoreData

// MARK: - CoreDataTableViewController: UITableViewController

class CoreDataViewController: UIViewController {
    
    // MARK: Properties
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
            reloadData()
        }
    }
    
    var reloadData: () -> Void = {
        fatalError("reloadData(_:) Must be implemented")
    }
    var insertItem: (IndexPath) -> Void = {
        indexPath -> Void in
        fatalError("insertItem(_:) Must be implemented")
    }
    var deleteItem: (IndexPath) -> Void = {
        indexPath -> Void in
        fatalError("deleteItem(_:) Must be implemented")
    }
    var updateItem: (IndexPath) -> Void = {
        indexPath -> Void in
        fatalError("updateItem(_:) Must be implemented")
    }
    var didChangeUpdates: () -> Void = {
        fatalError("didChangeUpdates(_:) Must be implemented")
    }
    
    // MARK: Initializers
    
    init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>,_ nibName: String?,_ bundle: Bundle) {
        fetchedResultsController = fc
        super.init(nibName: nibName, bundle: bundle)
    }
    
    // Do not worry about this initializer. I has to be implemented
    // because of the way Swift interfaces with an Objective C
    // protocol called NSArchiving. It's not relevant.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


// MARK: - CoreDataTableViewController (Fetches)

extension CoreDataViewController {
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch {
                print("Error while trying to perform a search: \n\(error)\n\(fetchedResultsController)")
            }
        }
    }
}

// MARK: - CoreDataTableViewController: NSFetchedResultsControllerDelegate

extension CoreDataViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.reloadData()
    }
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        
//        let set = IndexSet(integer: sectionIndex)
//        
//        switch (type) {
//        case .insert:
//            for s in set.enumerated() {
//                
//            }
//        case .delete:
//            tableView.deleteSections(set, with: .fade)
//        default:
//            // irrelevant in our case
//            break
//        }
//    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if let indexPath = indexPath {
            switch(type) {
            case .insert:
                self.insertItem(indexPath)
            case .delete:
                self.deleteItem(indexPath)
            case .update:
                self.updateItem(indexPath)
            case .move:
                self.deleteItem(indexPath)
                self.insertItem(indexPath)
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.didChangeUpdates()
    }
}
