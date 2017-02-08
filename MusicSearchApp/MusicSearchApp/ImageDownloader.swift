//
//  ImageDownloader.swift
//  MusicSearchApp
//
//  Created by Udkar, Anil K on 2/8/17.
//  Copyright © 2017 Udkar, Anil K. All rights reserved.
//

import UIKit


private let kAppIconSize : CGFloat = 48

class ImageDownloader : NSObject, NSURLConnectionDataDelegate {
    
    var trackRecord: TrackRecord?
    var completionHandler: (() -> Void)?
    
    private var sessionTask: URLSessionDataTask?
    

    
    // -------------------------------------------------------------------------------
    //	startDownload
    // -------------------------------------------------------------------------------
    func startDownload() {
        let request = URLRequest(url: URL(string: self.trackRecord!.imageURLString!)!)
        
        // create an session data task to obtain and download the app icon
        sessionTask = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if let actualError = error as NSError? {
                if #available(iOS 9.0, *) {  // required https for ios 9 and above else ATS flag should be updated with respective domain in info.plist
                    if actualError.code == NSURLErrorAppTransportSecurityRequiresSecureConnection {
                       // ATS flag  failure
                        abort()
                    }
                }
            }
            
            OperationQueue.main.addOperation{
                
                // Set appIcon and clear temporary data/image
                let image = UIImage(data: data!)!
                
                if image.size.width != kAppIconSize || image.size.height != kAppIconSize {
                    let itemSize = CGSize(width: kAppIconSize, height: kAppIconSize)
                    UIGraphicsBeginImageContextWithOptions(itemSize, false, 0.0)
                    let imageRect = CGRect(x: 0.0, y: 0.0, width: itemSize.width, height: itemSize.height)
                    image.draw(in: imageRect)
                    self.trackRecord!.appIcon = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                } else {
                    self.trackRecord!.appIcon = image
                }
                
                // call our completion handler when icon is ready for display
                self.completionHandler?()
            }
        }) 
        
        self.sessionTask?.resume()
    }
    
    // -------------------------------------------------------------------------------
    //	cancelDownload
    // -------------------------------------------------------------------------------
    func cancelDownload() {
        self.sessionTask?.cancel()
        sessionTask = nil
    }
    
}
