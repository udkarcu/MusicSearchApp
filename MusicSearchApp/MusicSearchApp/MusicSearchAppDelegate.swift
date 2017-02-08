//
//  MusicSearchAppDelegate.swift
//  MusicSearchApp
//
//  Created by Udkar, Anil K on 2/8/17.
//  Copyright © 2017 Udkar, Anil K. All rights reserved.
//

import UIKit

@UIApplicationMain
class MusicSearchAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    //  https URL for fethcing the musc track by terms
    final let musicAppURL =  "https://itunes.apple.com/search?term=tom+waits"
    
    
    // queue to run the Parsing
    private var queue: OperationQueue?
    
    // the NSOperation to parse the url
    private var parser: MusicParseOperation!
    

    
    
    // -------------------------------------------------------------------------------
    //	application:didFinishLaunchingWithOptions:
    // -------------------------------------------------------------------------------
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let requestString = URLRequest(url: URL(string: musicAppURL)!)
        
        // create an session data task to process request with musicAppURL
        let sessionTask = URLSession.shared.dataTask(with: requestString, completionHandler: {
            requestdata, response, error in
            
            if let requestError = error as NSError? {
                OperationQueue.main.addOperation {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    var isTransportError: Bool = false
                    if #available(iOS 9.0, *) {   // ios 9 and above  all links shoudl be secure else ATS flag needs to be taken care in plist
                        isTransportError = requestError.code == NSURLErrorAppTransportSecurityRequiresSecureConnection

                    }
                    if isTransportError {
                        abort()   // ATS flag needs to be handled properly in the plist
                    } else {
                        let errorMessage = error?.localizedDescription
                        // no record available
                        let alert = UIAlertController(title: "Cannot display music track",
                                                      message: errorMessage,
                                                      preferredStyle: .actionSheet)
                        let okClick = UIAlertAction(title: "OK", style: .default) {action in
                            // dismiss alert
                        }
                        alert.addAction(okClick)
                        
                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        
                    }
                }
            } else {
                // create the queue to run our ParseOperation
                self.queue = OperationQueue()
                
                // create an ParseOperation to pass the url in the background so that UI is not getting blocked
                
                self.parser = MusicParseOperation(data: requestdata!)
                
                self.parser.errorHandler = {[weak self] parseError in
                    DispatchQueue.main.async {
                        
                        let errorMessage = error?.localizedDescription
                                                // no record available
                        let alert = UIAlertController(title: "Cannot display music track",
                                                      message: errorMessage,
                                                      preferredStyle: .actionSheet)
                        let okClick = UIAlertAction(title: "OK", style: .default) {action in
                            // dismiss alert
                        }
                        
                        alert.addAction(okClick)
                        
                        self?.window?.rootViewController?.present(alert, animated: true, completion: nil)

                    }
                }
                
                // referencing parser from within its completionBlock would create a retain cycle
                
                self.parser.completionBlock = {[weak self] in
                    if let trackList = self?.parser.searchTrackList {
            //get teh searchTrackList post parsing and pass on to UI component on the main thread
                        DispatchQueue.main.async {
                        
                            //fetch the root view musicview controller and pass the parsed entries to the controller number of rows
                            let rootViewController =
                                (self?.window!.rootViewController as! UINavigationController?)?.topViewController as! TracksViewController?
                            
                            rootViewController?.entries = trackList
                            
                            // reload table after parsing
                            rootViewController?.tableView.reloadData()
                        }
                    }
            
                    // assign queue to nil after operation complete
                    self?.queue = nil
                }
                
                self.queue?.addOperation(self.parser)
            }
        })
        
        sessionTask.resume()   // start parsing
        
        return true
    }

    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

