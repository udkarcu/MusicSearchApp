//
//  MusicSearchAppTests.swift
//  MusicSearchAppTests
//
//  Created by Udkar, Anil K on 2/8/17.
//  Copyright © 2017 Udkar, Anil K. All rights reserved.
//

import XCTest
@testable import MusicSearchApp

class MusicSearchAppTests: XCTestCase {
    
    //trackviewcontroller
    var trackController: TracksViewController!
    //tableview
    var tableView = UITableView()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
     // trackController loaded from storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        trackController = storyboard.instantiateViewController(withIdentifier: "tableViewTest") as! TracksViewController
        trackController.performSelector(onMainThread: #selector(UIViewController.loadView), with: nil, waitUntilDone: true)

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        self.trackController=nil;

    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // check view is loading
    func testViewIsLoading() {
    XCTAssertNotNil(self.trackController.view, "View is not loading ")
    }
    
    //check tableview is loading
    func testTableViewIsLoading() {
        XCTAssertNotNil(self.trackController.tableView, "TableView is not loading")
    }
    
    //check view  conforms to delegate
    func testViewConformsToUITableViewDataSource() {
        XCTAssertTrue(self.trackController is UITableViewDataSource, "View does not conform to UITableView datasource")
        

    }
    
    //check tableview datasoruce is not nil
    func testTableViewHasDataSource() {
        XCTAssertNotNil(self.trackController.tableView.dataSource, "TableView datasource cannot be nil")
    }
    
    //check tableview conforms to delegate
    func testViewConformsToUITableViewDelegate() {
        XCTAssertTrue(self.trackController is UITableViewDelegate, "View does not conform to UITableView delegate")
    }
    
    // check whether tableview has delegate conneciton
    func testTableViewIsConnectedToDelegate() {
        XCTAssertNotNil(self.trackController.tableView.delegate, "TableView delegate cannot be nil")
    
}
    
//Example for Asyncrinous call , need to complete with mockking the objects.
    func testAsynchronousURLConnection() {
        let URL = NSURL(string: "https://itunes.apple.com/search?term=tom+waits")!
        
        let session = URLSession.shared
         session.dataTask(with: URL as URL) { data, response, error in
            XCTAssertNotNil(data, "data should not be nil")
            XCTAssertNil(error, "error should be nil")
        }
    }
    
    //Check the heigt of the Row matches with expected height

    func testTableViewHeightForRowAtIndexPath() {
        let expectedHeight: CGFloat = 70.0
        let actualHeight: CGFloat = self.trackController.tableView.rowHeight
        XCTAssertEqual(expectedHeight, actualHeight, "Cell should have %f height, but it has  %f")
}
}
