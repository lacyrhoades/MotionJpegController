//
//  SimpleDemoViewController.swift
//  LiveView
//
//  Created by Lacy Rhoades on 10/26/18.
//  Copyright © 2018 Lacy Rhoades. All rights reserved.
//

import UIKit

class SimpleDemoViewController: UIViewController {
    var streamController: MotionJpegController?
    var orientation = UIImageOrientation.up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        self.streamController = MotionJpegController(withURL: URL(string: "http://192.168.1.16:8080/")!, inView: self.view, usingView: {
            return imageView
        })
        
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
