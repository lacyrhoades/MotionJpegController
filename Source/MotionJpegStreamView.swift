//
//  MotionJpegStreamView.swift
//  MotionJpegController
//

public class MotionJpegStreamView: UIView {
    private var motionJpegController: MotionJpegController?
    
    public var didStartStreaming: (() -> ())? = nil
    public var didStopStreaming: (() -> ())? = nil
    public var streamDidError: (() -> ())? = nil
    
    let errorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.5
        return view
    }()
    
    let debugLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 28.0)
        label.alpha = 0.5
        return label
    }()
    
    var imageView: UIView
    public var imageDidUpdate: ((UIImage) -> ())?
    
    public init(withView subview: UIView) {
        self.imageView = subview
        super.init(frame: .zero)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public func showError(_ text: String) {
        DispatchQueue.main.async {
            self.debugLabel.text = text
        }
    }
    
    func setup() {
        self.backgroundColor = .clear
        
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
        
        debugLabel.text = "Uninitialized Motion JPEG Streaming View"
        debugLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(debugLabel)
        
        NSLayoutConstraint.activate(
            [
                NSLayoutConstraint(item: debugLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: debugLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            ]
        )
    }
    
    public func stream(from: URL) {
        if motionJpegController?.streamURL == from {
            motionJpegController?.start()
            return
        }
        
        motionJpegController?.stop()
        
        motionJpegController = MotionJpegController(withURL: from)
        
        motionJpegController?.newImageData = { imageData in
            DispatchQueue.main.async {
                self.debugLabel.text = "Streaming"
                UIView.animate(withDuration: 0.3, animations: {
                    self.errorView.alpha = 0.0
                })
            }
            
            DispatchQueue.global().async {
                if let newImage = UIImage(data: imageData as Data) {
                    DispatchQueue.main.async {
                        self.imageDidUpdate?(newImage)
                    }
                }
            }
        }
        
        motionJpegController?.willRetryLoading = { retryCount in
            DispatchQueue.main.async {
                self.debugLabel.text = "Paused"
                UIView.animate(withDuration: 0.3, animations: {
                    self.errorView.alpha = 0.5
                })
            }
            
            if retryCount > 5 {
                self.streamDidError?()
            }
        }
        
        motionJpegController?.didFinishLoading = {
            self.debugLabel.text = "Streaming"
            self.didStartStreaming?()
        }
        
        motionJpegController?.start()
    }
    
    public func stopStream() {
        motionJpegController?.stop()
        DispatchQueue.main.async {
            self.debugLabel.text = "Stopped"
            self.didStopStreaming?()
        }
    }
}
