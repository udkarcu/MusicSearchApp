//
//  MusicParseOperation.swift
//  MusicSearchApp
//
//  Created by Udkar, Anil K on 2/7/17.
//  Copyright © 2017 Udkar, Anil K. All rights reserved.
//

import Foundation
class MusicParseOperation:Operation
{
    
    
    // A block to call when an error is encountered during parsing.
    var errorHandler: ((Error) -> Void)?
    
    private(set) var searchTrackList: [TrackRecord]?

  
    
    private var dataToParse: Data
    
    //Array of objects
    private var workingArray: [TrackRecord] = []
   
    //init track record object
    private var workingEntry = TrackRecord()

    
    // -------------------------------------------------------------------------------
    //	initWithData:
    // -------------------------------------------------------------------------------
    // The initializer for this NSOperation subclass.
    init(data: Data) {
        dataToParse = data
    }

    
    // -------------------------------------------------------------------------------
    //	main
    //  Entry point for the operation.
    //  Given data to parse, use NSXMLParser and process all the top paid apps.
    // -------------------------------------------------------------------------------
    
    override func main()
    {
        
        workingArray = []
        
        do {
            guard let serverData  = try JSONSerialization.jsonObject(with: dataToParse, options: []) as? [String: AnyObject] else {
                print("error trying to convert data to JSON")
                return
            }
            // now we have the todo, let's just print it to prove we can access it
            print("The todo is: " + serverData.description)
            
            guard let musicList = serverData["results"] as? [Dictionary<String,AnyObject>] else {
                print("Could not get todo title from JSON")
                return
            }
            
            for musickTrack in musicList {
                
                workingEntry = TrackRecord()
            if let trackName = musickTrack["trackName"] as? String {
                workingEntry.trakName = trackName
                }
                if let collectionName = musickTrack["collectionName"] as? String {
                    workingEntry.albumName = collectionName
                }
                if let imageURL = musickTrack["artworkUrl60"] as? String {
                    workingEntry.imageURLString = imageURL
                }
                if let artistName = musickTrack["artistName"] as? String {
                    workingEntry.artistname = artistName
                }
                
                workingArray.append(workingEntry)

            }
            
            self.searchTrackList = self.workingArray
            
        } catch  {
            print("error trying to convert data to JSON")
            return
        }


        
    }

    

}
