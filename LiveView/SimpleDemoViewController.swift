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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        self.streamController = MotionJpegController(inView: self.view, usingView: {
            return imageView
        })
        
        self.streamController?.imageWasUpdated = { latestImage in
            imageView.image = latestImage
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.streamController?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.streamController?.stop()
    }
}
