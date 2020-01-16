//
//  ImageCell.swift
//  PlayerView
//
//  Created by 杨志远 on 2020/1/8.
//  Copyright © 2020 BaQiWL. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {

    @IBOutlet weak var urlImageView: URLImageView!
    
    var urlString : String! {
        didSet {
            if let url = URL(string:urlString) {
                print("调")
                urlImageView.load(url: url, animated: true)
                
//                urlImageView.load(url: url, progressly: true)
                
                //load(url: url, animated: true)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
}
