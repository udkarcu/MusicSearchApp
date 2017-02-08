//
//  DetailTrackOperation.swift
//  MusicSearchApp
//
//  Created by Udkar, Anil K on 2/7/17.
//  Copyright © 2017 Udkar, Anil K. All rights reserved.
//

import Foundation
class DetailTrackOperation: Operation, XMLParserDelegate {
    
    // A block to call when an error is encountered during parsing.
    var errorHandler: ((Error) -> Void)?
    
  
    // declaring searchTrackList so we can modify it within this class
    private(set) var searchTrackList: DetailRecord?
    
    
    // string contants found in URl
    let kArtist = "artist"
    let kLyrics = "lyrics"
    let kUrl = "url"
    let kSong = "song"
    let kResultStr = "LyricsResult"
    
    
    private var dataToParse: Data
    private var requiredEntry: DetailRecord?
    private var assignedString: String = ""
    private var elementsToParse: [String]
    private var storingCharacterData: Bool = false
    

    // -------------------------------------------------------------------------------
    //	initWithData:
    // -------------------------------------------------------------------------------
    // The initializer for this NSOperation subclass.
    init(data: Data) {
        dataToParse = data
        elementsToParse = [kArtist, kSong, kUrl, kLyrics]
    }
    
    // -------------------------------------------------------------------------------
    //	main
    //  Entry point for the operation.
    //  Given data to parse, use NSXMLParser and process all the top paid apps.
    // -------------------------------------------------------------------------------
    override func main() {

        assignedString = ""
 
        //Parse uRL
        let parser = XMLParser(data: self.dataToParse)
        parser.delegate = self
        parser.parse()
        
        if !self.isCancelled {
            // Set searchTrackList to the result of our parsing
            self.searchTrackList = self.requiredEntry
        }
        
        self.assignedString = ""
        self.dataToParse = Data()
    }
    
    
    // -------------------------------------------------------------------------------
    //	parser:didStartElement:namespaceURI:qualifiedName:attributes:
    // -------------------------------------------------------------------------------
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        // entry: { id (link), im:name (app name), im:image (variable height) }
        //
        if elementName == kResultStr {
            self.requiredEntry = DetailRecord()
        }
        self.storingCharacterData = self.elementsToParse.index(of: elementName) != nil
    }
    
    // -------------------------------------------------------------------------------
    //	parser:didEndElement:namespaceURI:qualifiedName:
    // -------------------------------------------------------------------------------
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if self.requiredEntry != nil {
            if self.storingCharacterData {
                let trimmedString =
                self.assignedString.trimmingCharacters(
                    in: CharacterSet.whitespacesAndNewlines)
                self.assignedString = ""
                switch elementName {
                case kArtist:
                    requiredEntry?.artistName = trimmedString
                case kLyrics:
                    requiredEntry?.lyrics = trimmedString
                case kUrl:
                    requiredEntry?.url = trimmedString
                case kSong:
                    requiredEntry?.song = trimmedString
                default:
                    break
                }
            }
        }
    }
    
    // -------------------------------------------------------------------------------
    //	parser:foundCharacters:
    // -------------------------------------------------------------------------------
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if storingCharacterData {
            self.assignedString += string
        }
    }
    
    // -------------------------------------------------------------------------------
    //	parser:parseErrorOccurred:
    // -------------------------------------------------------------------------------
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.errorHandler?(parseError)
    }
    
}
