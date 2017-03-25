//
//  ViewController.swift
//  Fukadakyoko
//
//  Created by 内村祐之 on 2017/03/25.
//  Copyright © 2017年 ucuc. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    private var counter = 0
    @IBOutlet private weak var resultLabel: UILabel!
    @IBAction func saveFukadakyoko(_ sender: UIButton) {
        resultLabel.text = "saving"
        for _ in 0 ..< 1000 {
            saveImageToFukadakyokoAssetCollection()
        }
        resultLabel.text = "done"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.requestAuthorization { _ in }
    }
    
    private func saveImageToFukadakyokoAssetCollection() {
        let albumTitle = "Fukadakyoko"

        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumTitle)
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: .album,
                                                                      subtype: .any,
                                                                      options: fetchOptions)

        if let assetCollection = assetCollections.firstObject {
            saveImage(withAssetCollection: assetCollection)
        } else {
            var assetCollectionPlaceholder: PHObjectPlaceholder?

            PHPhotoLibrary.shared().performChanges({
                assetCollectionPlaceholder = PHAssetCollectionChangeRequest
                    .creationRequestForAssetCollection(withTitle: albumTitle)
                    .placeholderForCreatedAssetCollection
            }, completionHandler: {(bool, error) in
                guard let assetCollectionPlaceholder = assetCollectionPlaceholder else { return }
                if let assetCollection = PHAssetCollection
                    .fetchAssetCollections(withLocalIdentifiers: [assetCollectionPlaceholder.localIdentifier], options: nil)
                    .firstObject {
                    self.saveImage(withAssetCollection: assetCollection)
                }
            })
            
        }
    }
    
    private func saveImage(withAssetCollection assetCollection: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges({
            let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: #imageLiteral(resourceName: "fukadakyouko"))
            guard let assetPlaceholder = assetRequest.placeholderForCreatedAsset else { return }
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection)
            let assetPlaceholders = [assetPlaceholder]
            albumChangeRequest?.addAssets(assetPlaceholders as NSFastEnumeration)
        }, completionHandler: { _, _ in })
    }
    
    // !!!: Danger!
    /*
    private func deleteAllImage() {
        let assetsFetchResult = PHAsset.fetchAssets(with: .image, options: nil)
        var assets = [PHAsset]()
        assetsFetchResult.enumerateObjects({ asset, index, stop in
            assets.append(asset)
        })

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
        }, completionHandler: nil )
    }*/
}

