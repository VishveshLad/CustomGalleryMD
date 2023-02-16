//
//  collectionViewCell.swift
//  MDCustomGallery
//
//  Created by SOTSYS317 on 16/02/23.
//

import Foundation
import UIKit

public class AllMediaPickerCell: UICollectionViewCell {

    var imageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        return img
    }()
    
    var playImageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        return img
    }()
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }

    var lblInfo: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 12)
        lbl.textColor = .white
        lbl.textAlignment = .right
        lbl.clipsToBounds = true
        return lbl
    }()

    public override init(frame: CGRect) {
        super.init(frame: .zero)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.lblInfo.translatesAutoresizingMaskIntoConstraints = false
                
        self.playImageView.image = UIImage(named: "icon-play-video")
        
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.lblInfo)
        self.contentView.addSubview(playImageView)
        
        // Set Image View
        
        self.playImageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -10).isActive = true
        self.playImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8).isActive = true
        self.playImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        self.playImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        self.playImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.imageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
        self.imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.imageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set Info Label
        self.lblInfo.rightAnchor.constraint(equalTo: self.playImageView.leftAnchor, constant: -5).isActive = true
        self.lblInfo.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8).isActive = true
        self.lblInfo.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
        self.lblInfo.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
