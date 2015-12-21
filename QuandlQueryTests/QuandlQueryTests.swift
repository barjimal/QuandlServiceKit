//
//  QuandlQueryTests.swift
//  QuandlQueryTests
//
//  Created by Alberto Barrera Jiménez on 12/20/15.
//  Copyright © 2015 Alberto Barrera Jimenez. All rights reserved.
//

import XCTest
@testable import QuandlServiceKit

class QuandlQueryTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testQuandlDataQuery_Basic() {
    let query = QuandlDataQuery(databaseCode: "WIKI", datasetCode: "FB")
    query.authenticated = false
    XCTAssert(query.URL.absoluteString == "https://www.quandl.com/api/v3/datasets/WIKI/FB/data.json?api_version=2015-04-09",
      "Quandl Data Query is generating a Wrong URL")
  }
  
  func testQuandlDataQuery_Queries() {
    let query = QuandlDataQuery(databaseCode: "WIKI", datasetCode: "FB")
    query.authenticated = false
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    query.startDate = formatter.dateFromString("2015-12-10")
    query.rows = 2
    query.getMetadata = true
    XCTAssert(query.URL.absoluteString == "https://www.quandl.com/api/v3/datasets/WIKI/FB.json?rows=2&start_date=2015-12-10&api_version=2015-04-09",
      "Quandl Data Query is generating a Wrong URL")
  }
  
  func testQuandlMetadataQuery_Metadata() {
    let query = QuandlMetadataQuery(databaseCode: "WIKI", datasetCode: "FB")
    query.authenticated = false
    XCTAssert(query.URL.absoluteString == "https://www.quandl.com/api/v3/datasets/WIKI/FB/metadata.json?api_version=2015-04-09",
      "Quandl Metadata Query is generating a Wrong URL")
  }
  
  func testQuandlDatasetQuery_Basic() {
    let query = QuandlDatasetQuery()
    query.authenticated = false
    XCTAssert(query.URL.absoluteString == "https://www.quandl.com/api/v3/datasets.json?api_version=2015-04-09",
      "Quandl Dataset Query is generating a Wrong URL")
  }
  
  func testQuandlDatasetQuery_Queries() {
    let query = QuandlDatasetQuery()
    query.authenticated = false
    query.queryTerms = ["apple", "iphone"]
    XCTAssert(query.URL.absoluteString == "https://www.quandl.com/api/v3/datasets.json?query=apple+iphone&api_version=2015-04-09",
      "Quandl Dataset Query is generating a Wrong  URL")
  }
  
  func testQuandDatabaseListQuery_Basic() {
    let query = QuandlDatabaseListQuery()
    query.authenticated = false
    XCTAssert(query.URL.absoluteString == "https://www.quandl.com/api/v3/databases.json?api_version=2015-04-09",
      "Quandl Database List Query is generating a Wrong URL")
  }
  
  func testQuandDatabaseListQuery_Queries() {
    let query = QuandlDatabaseListQuery()
    query.authenticated = false
    query.queryTerms = ["apple", "iphone"]
    query.page = 1
    XCTAssert(query.URL.absoluteString == "https://www.quandl.com/api/v3/databases.json?query=apple+iphone&page=1&api_version=2015-04-09",
      "Quandl Database List Query is generating a Wrong URL")
  }
  
  func testQuandlDatasetListQuery() {
    let query = QuandlDatasetListQuery(databaseCode: "WIKI")
    query.authenticated = false
    XCTAssert(query.URL.absoluteString == "https://www.quandl.com/api/v3/databases/WIKI/codes.json?api_version=2015-04-09",
      "Quandl Dataset List Query is generating a Wrong URL")
  }
  
  func testQuandlDatabaseMetadataQuery() {
    let query = QuandlDatabaseMetadataQuery(databaseCode: "WIKI")
    query.authenticated = false
    XCTAssert(query.URL.absoluteString == "https://www.quandl.com/api/v3/databases/WIKI.json?api_version=2015-04-09",
      "Quandl Database Metadata Query is generating a Wrong URL")
  }
  
  func testQuandlEntireDatabaseQuery_Basic() {
    let query = QuandlEntireDatabaseQuery(databaseCode: "WIKI")
    query.authenticated = false
    XCTAssert(query.URL.absoluteString == "https://www.quandl.com/api/v3/databases/WIKI/data?api_version=2015-04-09",
      "Quandl Database Metadata Query is generating a Wrong URL")
  }
  
  func testQuandQueryResume_Basic() {
    
    let query = QuandlDataQuery(databaseCode: "WIKI", datasetCode: "FB")
    query.authenticated = false
    let expectation = expectationWithDescription("GET \(query.URL)")
    
    query.run { (data, response, error) -> Void in
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(60) { (error) -> Void in
      print("Can't run query")
    }
  }
}
