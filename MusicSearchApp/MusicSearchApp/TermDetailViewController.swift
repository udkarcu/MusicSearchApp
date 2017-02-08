//
//  TermDetailViewController.swift
//  MusicSearchApp
//
//  Created by Udkar, Anil K on 2/8/17.
//
//

import Foundation
import UIKit

class TermDetailViewController : UIViewController{

    
    //COnverted the actual web URL with Xml format as original url was not in correct json format.
    
    //  https URL for fethcing the musc track by terms
    final let musicDetailURL =  "http://lyrics.wikia.com/api.php?func=getSong&artist=Tom+Waits&song=new+coat+of+paint&fmt=xml"
    
    var entriesDetials: [DetailRecord]?

    // queue to run the Parsing
    private var queue: OperationQueue?
    
    // the NSOperation to parse the url
    private var parser: DetailTrackOperation!
    
    var term: TrackRecord!
    @IBOutlet weak var trackImageView: UIImageView!
    // Track image
    @IBOutlet weak var albumName: UILabel!
    //album name
    @IBOutlet weak var artistName: UILabel!
    // artist name
    @IBOutlet weak var trackName: UILabel!
    // track name
    @IBOutlet weak var wikiArtistName: UILabel!
    // wiki link artist name
    @IBOutlet weak var wikiSong: UILabel!
    // wiki link song name
    @IBOutlet weak var wikiLyricsLabel: UILabel!
    //wiki lyrics label
    @IBOutlet weak var wikiLyricsTextView: UITextView!
    
    
  
    
    
    // load the detials from previous cell content
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.artistName.text = self.term.artistname
        self.trackImageView.image = self.term.appIcon
        self.albumName.text = self.term.albumName
        self.trackName.text = self.term.trakName
        
        let request = URLRequest(url: URL(string: musicDetailURL)!)
        
        // create an session data task to obtain and the XML data
        let sessionTask = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            // in case we want to know the response status code
            //let HTTPStatusCode = (response as! NSHTTPURLResponse).statusCode
            
            if let actualError = error as NSError? {
                OperationQueue.main.addOperation {
                    
                    var isATSError: Bool = false
                    if #available(iOS 9.0, *) {
                        isATSError = actualError.code == NSURLErrorAppTransportSecurityRequiresSecureConnection
                    }
                    if isATSError {
                        // if you get error NSURLErrorAppTransportSecurityRequiresSecureConnection (-1022),
                        // then your Info.plist has not been properly configured to match the target server.
                        //
                        abort()
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
                        
                        self.present(alert, animated: true, completion: nil)                    }
                }
            } else {
                // create the queue to run our ParseOperation
                self.queue = OperationQueue()
                
                // create an ParseOperation (NSOperation subclass) to parse the URl data so that the UI is not blocked
                self.parser = DetailTrackOperation(data: data!)
                
                self.parser.errorHandler = {[weak self] parseError in
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        let errorMessage = error?.localizedDescription
                        // no record available
                        let alert = UIAlertController(title: "Cannot display music track",
                                                      message: errorMessage,
                                                      preferredStyle: .actionSheet)
                        let okClick = UIAlertAction(title: "OK", style: .default) {action in
                            // dismiss alert
                        }
                        
                        alert.addAction(okClick)
                        
                        self?.present(alert, animated: true, completion: nil)                    }
                }
                
                // referencing parser from within its completionBlock would create a retain cycle
                
                self.parser.completionBlock = {[weak self] in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if let detailsList = self?.parser.searchTrackList {

                        DispatchQueue.main.async {

                            var detialRecord: DetailRecord? = nil
                                detialRecord = detailsList
                            
                            self?.wikiArtistName.text = detialRecord?.artistName
                            self?.wikiSong.text = detialRecord?.song
                            self?.wikiLyricsLabel.text = detialRecord?.url

                            self?.wikiLyricsTextView.text = detialRecord?.lyrics

                        }
                    }
                    
                    // we are finished with the queue and our ParseOperation
                    self?.queue = nil
                }
                
                self.queue?.addOperation(self.parser)
            }
        })
        
        sessionTask.resume()
        
        // show in the status bar that network activity is starting
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

    }
    
 
}
