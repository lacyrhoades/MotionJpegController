//
//  MotionJpegController.swift
//  MotionJpegController
//
//  Created by Lacy Rhoades on 10/26/18.
//  Copyright © 2018 Lacy Rhoades. All rights reserved.
//

import UIKit
import AVKit

public class MotionJpegController: NSObject {
    
    public typealias UpdateImageAction = (Data) -> ()
    public typealias UpdateAction = (()->Void)
    public typealias RetryAction = ((Int)->(Void))
    
    internal enum Status {
        case stopped
        case loading
        case playing
        case retrying
    }
    
    fileprivate var streamURL: URL!
    
    fileprivate var session: Foundation.URLSession!
    
    public var newImageData: UpdateImageAction?
    public var didStartLoading: UpdateAction?
    public var willRetryLoading: RetryAction?
    public var didFinishLoading: UpdateAction?
    
    public init(withURL: URL) {
        super.init()
        
        session = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        
        streamURL = withURL
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
    
    public func start() {
        guard status == .stopped || status == .retrying else {
            return
        }
        
        status = .loading
        
        DispatchQueue.main.async { self.didStartLoading?() }
        
        receivedData = NSMutableData()
        var request = URLRequest(url: streamURL)
        request.timeoutInterval = 5.0
        dataTask = session.dataTask(with: request)
        dataTask?.resume()
    }
    
    public func stop() {
        self.retryTimer?.invalidate()
        status = .stopped
        dataTask?.cancel()
    }
    
    var retryCount: Int = 0
    func retry() {
        self.retryTimer?.invalidate()
        
        self.status = .retrying
        
        self.retryCount += 1
        
        let count = retryCount
        
        DispatchQueue.main.async { self.willRetryLoading?(count) }
        
        let timer = Timer(timeInterval: 1.0, repeats: false) { [unowned self] (timer) in
            self.start()
        }
        
        self.retryTimer = timer
        
        RunLoop.main.add(timer, forMode: .common)
    }

}

extension MotionJpegController: URLSessionDelegate {
}

extension MotionJpegController: URLSessionTaskDelegate {
}

extension MotionJpegController: URLSessionDataDelegate {
    
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        if let imageData = receivedData , imageData.length > 0 {
            if status == .loading {
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
    
    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
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

}
