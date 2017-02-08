//
//  ViewController.swift
//  MusicSearchApp
//
//  Created by Udkar, Anil K on 2/8/17.
//  Copyright © 2017 Udkar, Anil K. All rights reserved.
//

import UIKit

@objc(TracksViewController)
class TracksViewController : UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // the main data model for our UITableView
    var entries: [TrackRecord] = []
    
    var term: TrackRecord? = nil
    
    
    //To keep track of the filtered/searced count
    var searchResults = [TrackRecord]()
    
    //fileter to search tracks
    var isFiltered: Bool = true
    
    
    let CellIdentifier = "TermTableCell"
    
    
    // the set of IconDownloader objects for each app
    private var imageDownloadsInProgress: [IndexPath: ImageDownloader] = [:]
    
    
    // -------------------------------------------------------------------------------
    //	viewDidLoad
    // -------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageDownloadsInProgress = [:]
    }
    
    // -------------------------------------------------------------------------------
    //	terminateAllDownloads
    // -------------------------------------------------------------------------------
    private func terminateAllDownloads() {
        // terminate all pending download connections
        let allDownloads = self.imageDownloadsInProgress.values
        for download in allDownloads {download.cancelDownload()}
        
        self.imageDownloadsInProgress.removeAll(keepingCapacity: false)
    }
    
    // -------------------------------------------------------------------------------
    //	dealloc
    //  If this view controller is going away, we need to cancel all outstanding downloads.
    // -------------------------------------------------------------------------------
    deinit {
        // terminate all pending download connections
        self.terminateAllDownloads()
    }
    
    // -------------------------------------------------------------------------------
    //	didReceiveMemoryWarning
    // -------------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // terminate all pending download connections
        self.terminateAllDownloads()
    }
    
    
    // UITableViewDataSource
    
    // -------------------------------------------------------------------------------
    //	tableView:numberOfRowsInSection:
    //  Customize the number of rows in the table view.
    // -------------------------------------------------------------------------------
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.entries.count
        
        if ((self.searchBar.text?.characters.count)! > 0) {
            return searchResults.count
        }
        else {
            return count
        }
        
    }
    
    // -------------------------------------------------------------------------------
    //	tableView:cellForRowAtIndexPath:
    // -------------------------------------------------------------------------------
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let trackCount = self.entries.count
        
        let  cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)as! TermTableCell
        
        // Leave cells empty if there's no data yet
        if trackCount > 0 {
            
            var trackRecord: TrackRecord? = nil
            
            if (self.searchBar.text?.characters.count)! > 0 {
                
                trackRecord = self.searchResults[indexPath.row]
            }
            else{
                trackRecord = self.entries[indexPath.row]
            }
            
            
            
            cell.trackNameLabel.text = trackRecord?.trakName
            cell.artistNameLabel.text = trackRecord?.artistname
            cell.albumLabel.text = trackRecord?.albumName
            // Only load cached images; defer new downloads until scrolling ends
            if trackRecord?.appIcon == nil {
                if !self.tableView.isDragging && !self.tableView.isDecelerating {
                    self.startIconDownload(trackRecord!, forIndexPath: indexPath)
                }
                // if a download is deferred or in progress, return a avatar image
                cell.imageView?.image = UIImage(named: "Avatar.png")!
            } else {
                cell.imageView?.image = trackRecord?.appIcon
            }
        }
        
        
        return cell
    }
    
    
    // -------------------------------------------------------------------------------
    //	startIconDownload:forIndexPath:
    // -------------------------------------------------------------------------------
    private func startIconDownload(_ trackRecord: TrackRecord, forIndexPath indexPath: IndexPath) {
        var imageDownloader = self.imageDownloadsInProgress[indexPath]
        if imageDownloader == nil {
            imageDownloader = ImageDownloader()
            imageDownloader!.trackRecord = trackRecord
            imageDownloader!.completionHandler = {
                
                let cell = self.tableView.cellForRow(at: indexPath)
                
                // Display the newly loaded image
                cell?.imageView?.image = trackRecord.appIcon
                
                // Remove the IconDownloader from the in progress list.
                // This will result in it being deallocated.
                self.imageDownloadsInProgress.removeValue(forKey: indexPath)
                
            }
            self.imageDownloadsInProgress[indexPath] = imageDownloader
            imageDownloader!.startDownload()
        }
    }
    
    // -------------------------------------------------------------------------------
    //	loadImagesForOnscreenRows
    //  This method is used in case the user scrolled into a set of cells that don't
    //  have their app icons yet.
    // -------------------------------------------------------------------------------
    
    
    private func loadImagesForOnscreenRows() {
        if !self.entries.isEmpty {
            let visiblePaths = self.tableView.indexPathsForVisibleRows!
            for indexPath in visiblePaths {
                let trackRecord = entries[indexPath.row]
                
                // Avoid the app icon download if the app already has an icon
                if trackRecord.appIcon == nil {
                    self.startIconDownload(trackRecord, forIndexPath: indexPath)
                }
            }
        }
    }
    
    // -------------------------------------------------------------------------------
    //	UISearchBarDelegate
    //  This method is delegate method for search bar , when search bar is clicked it will get called
    //  text is to search the name in music track
    // -------------------------------------------------------------------------------
    
    func searchBar(_ searchBar: UISearchBar, textDidChange text: String) {
        searchResults.removeAll()
        if (text.characters.count == 0) {
            isFiltered = false
        }
        else {
            isFiltered = true
            for term in self.entries {
                if let nameRange = term.artistname?.range(of: text, options: .caseInsensitive){
                    
                    if (nameRange != nil) {
                        searchResults.append(term)
                    }
                    
                }
        }
        }
        self.tableView.reloadData()
        
        
    }
    
    // -------------------------------------------------------------------------------
    //	UIScrollViewDelegate
    //scrollViewDidEndDragging:willDecelerate:
    //  Load images for all onscreen rows when scrolling is finished.
    // -------------------------------------------------------------------------------
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.loadImagesForOnscreenRows()
        }
    }
    
    
    // -------------------------------------------------------------------------------
    //	scrollViewDidEndDecelerating:scrollView
    //  When scrolling stops, proceed to load the app icons that are on screen.
    // -------------------------------------------------------------------------------
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.loadImagesForOnscreenRows()
    }
    
    // -------------------------------------------------------------------------------
    //	tableView didSelectRowAt delegate
    //  one cell click it will be called
    // -------------------------------------------------------------------------------
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (self.searchBar.text?.characters.count)! > 0 {
            term = searchResults[indexPath.row]
        }
        else {
            term = entries[indexPath.row]
        }
        self.performSegue(withIdentifier: "show", sender: term)
    }
    
    // -------------------------------------------------------------------------------
    //	prepare segue
    //  to move to the next controller
    // -------------------------------------------------------------------------------
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // get a reference to the second view controller
        let secondViewController = segue.destination as! TermDetailViewController
        
        // set a variable in the second view controller with the data to pass
        secondViewController.term = term
    }
    
}
