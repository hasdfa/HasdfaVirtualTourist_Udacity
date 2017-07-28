//
//  PhotoCell.swift
//  VirtualTourist
//
//  Created by Raksha Vadim on 28.07.17.
//  Copyright © 2017 Raksha Vadim. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var progress: UIActivityIndicatorView!
    
    public var photoObj: Photo!
    public var indexPath: IndexPath!
    public var isStateSelected: Bool = false
    public func setSelectionState(selected: Bool){
        selectionView.alpha = selected ? 1 : 0
    }
}
