# MotionJpegController
Live stream controller for MJPEG streams

Usage:

```swift
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
        
    self.streamController = MotionJpegController(withURL: URL(string: "http://192.168.1.16:8080/")!, inView: self.view, usingView: {
        return imageView
    })
        
    self.streamController?.newImageData = { imageData in
        if let latestImage = UIImage(data: imageData as Data) {                
            DispatchQueue.main.async {
                imageView.image = latestImage
            }
        }
    }
```
