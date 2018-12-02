//
//  MotionJpegStreamView.swift
//  MotionJpegController
//

public class MotionJpegStreamView: UIView {
    private var motionJpegController: MotionJpegController?
    
    public var didStartStreaming: (() -> ())? = nil
    public var didStopStreaming: (() -> ())? = nil
    public var streamDidError: (() -> ())? = nil
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let errorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.5
        return view
    }()
    
    public init() {
        super.init(frame: .zero)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        
        NSLayoutConstraint.activate(
            [
                NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            ]
        )
        
        errorView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(errorView)
        
        NSLayoutConstraint.activate(
            [
                NSLayoutConstraint(item: errorView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: errorView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: errorView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: errorView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            ]
        )
    }
    
    public func startStream(from: URL) {
        motionJpegController?.stop()
        
        motionJpegController = MotionJpegController(withURL: from)
        
        motionJpegController?.newImageData = { imageData in
            DispatchQueue.main.async {
                self.backgroundColor = self.backgroundColor == .darkGray ? .black : .darkGray
                self.errorView.isHidden = true
            }
            
            DispatchQueue.global().async {
                if let newImage = UIImage(data: imageData as Data) {
                    DispatchQueue.main.async {
                        self.imageView.image = newImage
                    }
                }
            }
        }
        
        motionJpegController?.willRetryLoading = { retryCount in
            DispatchQueue.main.async {
                self.errorView.isHidden = false
            }
            
            if retryCount > 5 {
                self.streamDidError?()
            }
        }
        
        motionJpegController?.didFinishLoading = {
            self.didStartStreaming?()
        }
        
        motionJpegController?.start()
    }
    
    public func stopStream() {
        motionJpegController?.stop()
        DispatchQueue.main.async {
            self.imageView.image = nil
            self.didStopStreaming?()
        }
    }
}
