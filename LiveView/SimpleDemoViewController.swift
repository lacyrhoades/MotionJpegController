//
//  SimpleDemoViewController.swift
//  LiveView
//
//  Created by Lacy Rhoades on 10/26/18.
//  Copyright © 2018 Lacy Rhoades. All rights reserved.
//

import UIKit
import MotionJpegController

class SimpleDemoViewController: UIViewController {
    var streamController: MotionJpegController?
    var orientation = UIImage.Orientation.up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        
        NSLayoutConstraint.activate(
            [
                NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
            ]
        )
        
        self.streamController = MotionJpegController(withURL: streamURL)
        
        self.streamController?.newImageData = { imageData in
            if let latestImage = UIImage(data: imageData)?.cgImage {
                let rotated = UIImage.init(cgImage: latestImage, scale: 1.0, orientation: self.orientation)
                DispatchQueue.main.async {
                    imageView.image = rotated
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.streamController?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.streamController?.stop()
    }
}
