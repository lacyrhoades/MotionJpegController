//
//  GPUImageDemoViewController.swift
//  LiveView
//
//  Created by Lacy Rhoades on 10/26/18.
//  Copyright © 2018 Lacy Rhoades. All rights reserved.
//

import UIKit
import GPUImage

class GPUImageDemoViewController: UIViewController {
    
    var streamController: MotionJpegController?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        let gpuAdapter = GPUImageMotionJpeg()
        let gpuPreviewView = GPUImageView()
        gpuAdapter.addTarget(gpuPreviewView)
        
        self.streamController = MotionJpegController(withURL: URL(string: "http://192.168.1.16:8080/")!, inView: self.view, usingView: {
            return gpuPreviewView
        })
        
        self.streamController?.newImageData = { imageData in
            if let latestImage = UIImage(data: imageData) {
                gpuAdapter.update(latestImage)
                gpuAdapter.notifyTargetsAboutNewOutputTexture()
            }
        }
        
        var index: Int = 0
        let timer = Timer(timeInterval: 2.0, repeats: true, block: { (timer) in
            DispatchQueue.main.async {
                var filter: GPUImageFilter
                switch index % 10 {
                case 0:
                    filter = GPUImageFalseColorFilter()
                case 1:
                    filter = GPUImageGrayscaleFilter()
                case 2:
                    filter = GPUImagePolkaDotFilter()
                case 3:
                    filter = GPUImagePosterizeFilter()
                case 4:
                    filter = GPUImageSketchFilter()
                case 5:
                    filter = GPUImageHalftoneFilter()
                case 6:
                    filter = GPUImageBoxBlurFilter()
                case 7:
                    filter = GPUImageSepiaFilter()
                case 8:
                    filter = GPUImageHazeFilter()
                case 9:
                    filter = GPUImageToonFilter()
                default:
                    filter = GPUImageColorInvertFilter()
                }
                gpuAdapter.removeAllTargets()
                gpuAdapter.addTarget(filter)
                filter.addTarget(gpuPreviewView)
                index += 1
            }
        })
        RunLoop.main.add(timer, forMode: .commonModes)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.streamController?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.streamController?.stop()
    }

}
