//
//  LiveViewController.swift
//  LiveView
//
//  Created by Lacy Rhoades on 10/26/18.
//  Copyright © 2018 Lacy Rhoades. All rights reserved.
//

import UIKit
import AVKit

class MotionJpegController: NSObject {
    
    typealias LiveViewMakeAction = () -> (UIView)
    typealias UpdateImageAction = (Data) -> ()
    typealias UpdateAction = (()->Void)
    
    internal enum Status {
        case stopped
        case loading
        case playing
        case retrying
    }
    
    fileprivate var streamURL: URL!
    fileprivate var liveView: UIView!
    fileprivate var errorView: UIView!
    
    fileprivate var session: Foundation.URLSession!
    
    public var newImageData: UpdateImageAction?
    public var didStartLoading: UpdateAction?
    public var willRetryLoading: UpdateAction?
    public var didFinishLoading: UpdateAction?
    
    public init(withURL: URL, inView superview: UIView, usingView: LiveViewMakeAction, usingErrorView: LiveViewMakeAction? = nil) {
        super.init()
        
        session = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        
        streamURL = withURL
        
        liveView = usingView()
        liveView.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(liveView)
        
        NSLayoutConstraint.activate(
            [
                NSLayoutConstraint(item: liveView, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: liveView, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: liveView, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .topMargin, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: liveView, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottomMargin, multiplier: 1, constant: 0),
            ]
        )
        
        errorView = usingErrorView?() ?? {
            let view = UIView()
            view.backgroundColor = .white
            view.alpha = 0.5
            return view
        }()
        
        errorView.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(errorView)
        
        NSLayoutConstraint.activate(
            [
                NSLayoutConstraint(item: errorView, attribute: .leading, relatedBy: .equal, toItem: liveView, attribute: .leading, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: errorView, attribute: .trailing, relatedBy: .equal, toItem: liveView, attribute: .trailing, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: errorView, attribute: .top, relatedBy: .equal, toItem: liveView, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: errorView, attribute: .bottom, relatedBy: .equal, toItem: liveView, attribute: .bottom, multiplier: 1, constant: 0),
                ]
        )
    }
    
    var showError: (UIView) -> () = { view in
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                view.alpha = 0.5
            }
        }
    }
    
    var hideError: (UIView) -> () = { view in
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                view.alpha = 0.0
            }
        }
    }
    
    deinit {
        self.stop()
    }

    fileprivate var receivedData: NSMutableData?
    fileprivate var dataTask: URLSessionDataTask?
    fileprivate var status: Status = .stopped
    fileprivate var retryTimer: Timer?
    
    public var authenticationHandler: ((URLAuthenticationChallenge) -> (Foundation.URLSession.AuthChallengeDisposition, URLCredential?))?
    
    func start() {
        guard status == .stopped || status == .retrying else {
            return
        }
        
        status = .loading
        
        DispatchQueue.main.async { self.didStartLoading?() }
        
        receivedData = NSMutableData()
        var request = URLRequest(url: streamURL)
        request.timeoutInterval = 0.2
        dataTask = session.dataTask(with: request)
        dataTask?.resume()
    }
    
    func stop() {
        self.retryTimer?.invalidate()
        status = .stopped
        dataTask?.cancel()
    }
    
    func retry() {
        self.showError(self.errorView)
        
        self.retryTimer?.invalidate()
        
        self.status = .retrying
        
        DispatchQueue.main.async { self.willRetryLoading?() }
        
        let timer = Timer(timeInterval: 1.0, repeats: false) { [unowned self] (timer) in
            self.start()
        }
        
        self.retryTimer = timer
        
        RunLoop.main.add(timer, forMode: .commonModes)
    }

}

extension MotionJpegController: URLSessionDataDelegate {
    
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        if let imageData = receivedData , imageData.length > 0 {
            if status == .loading {
                self.hideError(self.errorView)
                status = .playing
                DispatchQueue.main.async { self.didFinishLoading?() }
            }
            self.newImageData?(imageData as Data)
        }
        
        receivedData = NSMutableData()
        
        completionHandler(.allow)
    }
    
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData?.append(data)
    }
    
    open func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        var credential: URLCredential?
        var disposition: Foundation.URLSession.AuthChallengeDisposition = .performDefaultHandling
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let trust = challenge.protectionSpace.serverTrust {
                credential = URLCredential(trust: trust)
                disposition = .useCredential
            }
        } else if let onAuthentication = authenticationHandler {
            (disposition, credential) = onAuthentication(challenge)
        }
        
        completionHandler(disposition, credential)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard session == self.session, task == self.dataTask else {
            assert(false)
            print("Unknown session / task failed with error")
            return
        }
        
        switch error {
        case let error as URLError:
            switch error.code {
            case URLError.Code.timedOut:
                print("Timed out")
                self.retry()
            case URLError.Code.fileDoesNotExist:
                print("File does not exist")
                self.retry()
            case URLError.Code.cannotConnectToHost:
                print("Cannot connect to host")
                self.retry()
            case URLError.Code.cancelled:
                print("Data task cancelled")
                break
            default:
                assert(false)
                print("Unrecognized URLError")
            }
            break
        case .none:
            print("Server error")
            self.retry()
        default:
            assert(false)
            print("Task failed with unrecognized error type")
            self.stop()
        }
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        assert(false)
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        assert(false)
    }
    
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        assert(false)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        assert(false)
    }
    
//    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
//        assert(false)
//    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        assert(false)
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        assert(false)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        assert(false)
    }
    
    @available(iOS 11.0, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        assert(false)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        assert(false)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        assert(false)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        assert(false)
    }

}
