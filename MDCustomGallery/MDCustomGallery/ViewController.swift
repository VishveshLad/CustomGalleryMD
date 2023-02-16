//
//  ViewController.swift
//  MDCustomGallery
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    // MARK: - Variables
    fileprivate var collectionView: UICollectionView!
    fileprivate var collectionViewLayout: UICollectionViewFlowLayout!
    fileprivate var assets: PHFetchResult<PHAsset>?
    fileprivate var sideSize: CGFloat!
    fileprivate var arrayImages = [UIImage]()
    fileprivate var arrayAVAsset: [(AVAsset,UIImage)] = []
    var arrGalleryDataModel : [GalleryData] = []
    var width = CGFloat()
    
    private let titleLable: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.text = "Gallery"
        return label
    }()

    //MARK:- View Controller life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLable.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.titleLable)
        
        self.titleLable.topAnchor.constraint(equalTo: view.topAnchor , constant: 50).isActive = true
        self.titleLable.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.titleLable.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        //SET UP VIEW
        self.setupView()
        
        // PHPhotoLibrary authorization status
        PHPhotoLibrary.execute(controller: self) {
            self.fetchAssetsData()
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    // MARK: - Fetch assets Images and videos
    public func fetchAssetsData() {
        DispatchQueue.main.async {
            self.width  = self.view.bounds.width / 2
            
            self.assets = nil
            self.arrGalleryDataModel.removeAll()
            self.collectionView.reloadData()
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
          //  fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue) // Fetch only images
          //  fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue) // fetch only videos
            self.assets = PHAsset.fetchAssets(with: fetchOptions)
           
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.getAssetsData(assets: self.assets) // get all images and videos
                   // self.getImageAssetsData(assets: self.assets) // get only images
                   // self.getVideoAssetsData(assets: self.assets) // get only video and thumnailImage
                })
        }
    }
    
    // MARK: - Get assets and store data in model
    private func getAssetsData(assets: PHFetchResult<PHAsset>?) {
        PHFetchResults().getAssetURL(ofPhotoWith: assets, targetSize: self.width, completionHandler: { asset, assetImage, responseURL,  avAsset, assetID  in
            if asset?.mediaType == .image {
                let phAssetsImageData = GalleryData(mediaID:assetID, phAssets: asset,thumbNailImage: assetImage, videoUrl: nil, galleryType: asset?.mediaType, avaAssets: nil, maxDuration: nil)
                
                self.arrGalleryDataModel.append(phAssetsImageData)
            } else {
                let phAssetsVideoData = GalleryData(mediaID:assetID, phAssets: asset,thumbNailImage: assetImage, videoUrl: responseURL?.url, galleryType: asset?.mediaType, avaAssets: avAsset, maxDuration: avAsset?.duration.seconds)
                
                self.arrGalleryDataModel.append(phAssetsVideoData)
            }
        })
        
        DispatchQueue.main.async {
            self.collectionView.reloadData() // Reload collectionView
        }
    }
    
    // MARK: - Get only Images
    private func getImageAssetsData(assets: PHFetchResult<PHAsset>?) {
        for i in 0..<(assets?.count ?? 0) {
            guard let asset = assets?.object(at: i) else {return}
            
             PHFetchResults.shared.getAssetThumbnail(asset: asset, completionHandler: { assetImage in
                self.arrayImages.append(assetImage)
            })
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData() // Reload collectionView
        }
    }
    
    // MARK: - Get only Videos
    private func getVideoAssetsData(assets: PHFetchResult<PHAsset>?) {
        for i in 0..<(assets?.count ?? 0) {
            guard let asset = assets?.object(at: i) else {return}
            
             PHFetchResults.shared.getVideoAssetThumbnail(asset: asset, completionHandler: { (avAsset,thumbnailImage) in
                self.arrayAVAsset.append((avAsset, thumbnailImage))
            })
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData() // Reload collectionView
        }
    }
    
    // MARK: - Setup CollectionView
    public func setupView() {
        PHPhotoLibrary.shared().register(self)
        
        self.collectionViewLayout = UICollectionViewFlowLayout()
        self.sideSize = ((self.view.bounds.width - 4) / 3)
        self.collectionViewLayout.itemSize = CGSize(width: self.sideSize, height: self.sideSize)
        self.collectionViewLayout.minimumLineSpacing = 2
        self.collectionViewLayout.minimumInteritemSpacing = 2

        self.collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: collectionViewLayout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.collectionView)
      
        self.collectionView.topAnchor.constraint(equalTo: self.titleLable.bottomAnchor , constant: 10 ).isActive = true
        self.collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
  
        self.collectionView.allowsMultipleSelection = true
        self.collectionView.register(AllMediaPickerCell.self, forCellWithReuseIdentifier: "AllMediaPickerCell")
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = .white
    }
    
    // MARK: - convert TimeInterval into String
    public func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
 }

// MARK: - UICollectionView Delegate and DataSource methods
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrGalleryDataModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllMediaPickerCell", for: indexPath) as! AllMediaPickerCell
        let objPHAsset = self.arrGalleryDataModel[indexPath.row]
        
        cell.lblInfo.text = stringFromTimeInterval(interval: objPHAsset.maxDuration ?? 0.0)
        cell.lblInfo.isHidden = objPHAsset.galleryType == .video ? false : true
        cell.playImageView.isHidden = objPHAsset.galleryType == .video ? false : true
        cell.image = objPHAsset.thumbNailImage

        return cell
    }
}

// MARK: - PHPhotoLibrary change obeserver (when any image or video new added in Photo Library)
extension ViewController: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        if let _fetchResult = self.assets, let resultDetailChanges = changeInstance.changeDetails(for: _fetchResult) {
            let insertedObjects = resultDetailChanges.insertedObjects
            let removedObjects = resultDetailChanges.removedObjects
            let changedObjects = resultDetailChanges.changedObjects.filter( {
                return changeInstance.changeDetails(for: $0)?.assetContentChanged == true
            })
            if resultDetailChanges.hasIncrementalChanges && (insertedObjects.count > 0 || removedObjects.count > 0 || changedObjects.count > 0){
                DispatchQueue.main.async {
                    self.fetchAssetsData() // Again fetch assets data
                }
            }
        }
    }
}




