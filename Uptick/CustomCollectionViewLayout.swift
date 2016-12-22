//
//  CustomCollectionViewLayout.swift
//  Uptick
//
//  Created by Chris Kong on 10/30/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import UIKit

class CustomCollectionViewLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    override var itemSize: CGSize {
        set {
        }
        get {
            let numberOfColumns: CGFloat = 2
            let itemWidth = (self.collectionView!.frame.width - (numberOfColumns - 1)) / numberOfColumns
            return CGSize(width: itemWidth, height: 44)
        }
    }
    
    func setupLayout() {
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
//        minimumInteritemSpacing = 1
//        minimumLineSpacing = 1
        scrollDirection = .vertical
    }
}
