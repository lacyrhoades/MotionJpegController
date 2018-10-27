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
    var orientation = UIImageOrientation.up
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        let gpuAdapter = GPUImageMotionJpeg()
        let gpuPreviewView = GPUImageView()
        
        let buildFilterChain: () -> () = {
            let filter = self.nextFilter
            gpuAdapter.removeAllTargets()
            gpuAdapter.addTarget(filter)
            filter.addTarget(gpuPreviewView)
            
            var gpuMode: GPUImageRotationMode
            switch self.orientation {
            case .right:
                gpuMode = .rotateRight
            case .left:
                gpuMode = .rotateLeft
            case .down:
                gpuMode = .rotate180
            default:
                gpuMode = .noRotation
            }
            
            gpuPreviewView.setInputRotation(gpuMode, at: 0)
        }
        
        buildFilterChain()
        
        self.streamController = MotionJpegController(withURL: URL(string: "http://192.168.1.16:8080/")!, inView: self.view, usingView: {
            return gpuPreviewView
        })
        
        self.streamController?.newImageData = { imageData in
            if let latestImage = UIImage(data: imageData) {
                GPUImageContext.sharedContextQueue().async {
                    gpuAdapter.update(latestImage)
                    gpuAdapter.notifyTargetsAboutNewOutputTexture()
                }
            }
        }
        
        let timer = Timer(timeInterval: 0.5, repeats: true, block: { (timer) in
            GPUImageContext.sharedContextQueue().async {
                buildFilterChain()
            }
        })
        RunLoop.main.add(timer, forMode: .commonModes)
    }
    
    static var currentFilterIndex: Int = 0
    
    var filters: [GPUImageFilter] = [
        GPUImageFalseColorFilter(),
        GPUImagePolkaDotFilter(),
        GPUImageColorInvertFilter(),
        GPUImageToonFilter(),
        GPUImageGrayscaleFilter(),
        GPUImagePolkaDotFilter(),
        GPUImagePosterizeFilter(),
        GPUImageSketchFilter(),
        GPUImageHalftoneFilter(),
        GPUImageBoxBlurFilter(),
        GPUImageSepiaFilter(),
        GPUImageHazeFilter()
    ]
    
    var nextFilter: GPUImageFilter {
        let index = (GPUImageDemoViewController.currentFilterIndex % self.filters.count)
        let filter = self.filters[index]
        GPUImageDemoViewController.currentFilterIndex += 1
        return filter
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.streamController?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.streamController?.stop()
    }

}
