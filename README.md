# MotionJpegController
Live stream controller for MJPEG streams

## Using the "StreamView"

```swift
    let streamView = MotionJpegStreamView()

    streamView.didStartStreaming = {
        self.state = .streaming
    }

    streamView.didStopStreaming = {
        self.state = .stopped
    }


    streamView.streamDidError = {
        self.state = .loading
        self.streamView.stopStream()
        DispatchQueue.main.async {
            self.getStreamURL() { url in
                streamView.startStream(from: url)
            }
        }
    }

    self.getStreamURL() { url in
        streamView.startStream(from: url)
    }

    streamView.stopStream()
```

## Using just the "Controller"

```swift
    let motionJpegController = MotionJpegController(withURL: from)

    motionJpegController.newImageData = { imageData in
        DispatchQueue.global().async {
            if let newImage = UIImage(data: imageData as Data) {
                DispatchQueue.main.async {
                    self.imageView.image = newImage
                }
            }
        }
    }
        
    motionJpegController.willRetryLoading = { retryCount in
        // will retry for the n'th time
    }
    
    motionJpegController.didFinishLoading = {
        // now streaming
    }
    
    // start streaming and retry forever
    motionJpegController?.start()

    // stop streaming
    motionJpegController?.stop()
```
