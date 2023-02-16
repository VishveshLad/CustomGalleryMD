//
//  PHAssetsGet.swift
//  MDCustomGallery
//
//  Created by SOTSYS317 on 16/02/23.
//

import Foundation
import Photos
import UIKit

class PHFetchResults {
    
    static let shared = PHFetchResults()
    
    // MARK: - call this function get all images and videos
    
    public func getAssetURL(ofPhotoWith mPhasset: PHFetchResult<PHAsset>?, targetSize: CGFloat, completionHandler : @escaping ((_ asset : PHAsset?, _ assetImage: UIImage, _ responseURL: AVURLAsset?,_ avAsset : AVAsset?, _ assetID: Int) -> Void)) {
        
        for i in 0..<(mPhasset?.count ?? 0) {
            guard let asset = mPhasset?.object(at: i) else {return}
            
            autoreleasepool {
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.resizeMode = .exact
                options.isSynchronous = true
                
                PHCachingImageManager.default().requestImage(for: asset , targetSize: CGSize(width: targetSize, height: 0.90 * targetSize), contentMode: .aspectFit, options: options) {(image, info) in
                    guard let image = image else { return }
                    
                    if asset.mediaType == .image { // Image
                        completionHandler(asset, image, nil, nil, i)
                        
                    } else if asset.mediaType == .video { // Video
                        let requestOptions = PHVideoRequestOptions()
                        requestOptions.isNetworkAccessAllowed = true
                        requestOptions.version = .original
                        requestOptions.deliveryMode = .mediumQualityFormat
                        
                        PHImageManager.default().requestAVAsset(forVideo: asset , options: requestOptions) {(avAsset, audioMix, info) in
                            let avAsstesURL = avAsset as? AVURLAsset
                            completionHandler(asset, image, avAsstesURL, avAsset, i)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - call this function get all images
    public func getAssetThumbnail(asset: PHAsset , completionHandler : @escaping ((_ assetImage: UIImage) -> Void)){
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isSynchronous = true
        
        PHCachingImageManager.default().requestImage(for: asset , targetSize: CGSize(width: 150, height: 150), contentMode: .aspectFit, options: options) {(image, info) in
            guard let image = image else { return }
            
            completionHandler(image)
        }
    }
    
    // MARK: - call this function get all videos and thumbnail of videos
    public func getVideoAssetThumbnail(asset: PHAsset, completionHandler : @escaping ((_ avAsset : AVAsset, _ assetImage: UIImage) -> Void)) {
        
        let requestOptions = PHVideoRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.version = .original
        requestOptions.deliveryMode = .mediumQualityFormat
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isSynchronous = true
        
        PHCachingImageManager.default().requestImage(for: asset , targetSize: CGSize(width: 150, height: 150), contentMode: .aspectFit, options: options) {(image, info) in
            
            PHImageManager.default().requestAVAsset(forVideo: asset , options: requestOptions) {(avAsset, audioMix, info) in
                guard let image = image else { return }
                guard let avAsset = avAsset else { return }
                
                completionHandler(avAsset,image)
            }
        }
    }
}

public extension PHPhotoLibrary {
   
   static func execute(controller: UIViewController,
                       onAccessHasBeenGranted: @escaping () -> Void,
                       onAccessHasBeenDenied: (() -> Void)? = nil) {
      
      let onDeniedOrRestricted = onAccessHasBeenDenied ?? {
         let alert = UIAlertController(
            title: "We were unable to load your album groups. Sorry!",
            message: "You can enable access in Privacy Settings",
            preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
         alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
               UIApplication.shared.open(settingsURL)
            }
         }))
         DispatchQueue.main.async {
            controller.present(alert, animated: true)
         }
      }

      let status = PHPhotoLibrary.authorizationStatus()
      switch status {
      case .notDetermined:
         onNotDetermined(onDeniedOrRestricted, onAccessHasBeenGranted)
      case .denied, .restricted:
         onDeniedOrRestricted()
      case .authorized:
         onAccessHasBeenGranted()
      case .limited:
          break
      @unknown default:
         fatalError("PHPhotoLibrary::execute - \"Unknown case\"")
      }
   }
   
}

private func onNotDetermined(_ onDeniedOrRestricted: @escaping (()->Void), _ onAuthorized: @escaping (()->Void)) {
   PHPhotoLibrary.requestAuthorization({ status in
      switch status {
      case .notDetermined:
         onNotDetermined(onDeniedOrRestricted, onAuthorized)
      case .denied, .restricted:
         onDeniedOrRestricted()
      case .authorized:
         onAuthorized()
      case .limited:
          break
      @unknown default:
         fatalError("PHPhotoLibrary::execute - \"Unknown case\"")
      }
   })
}
