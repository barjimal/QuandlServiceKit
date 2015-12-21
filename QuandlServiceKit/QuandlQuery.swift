//
//  QuandlQuery.swift
//  QuandlServiceKit
//
//  Created by Alberto Barrera Jiménez on 12/20/15.
//  Copyright © 2015 Alberto Barrera Jimenez. All rights reserved.
//

import Foundation

enum QuandlDataFormat: String {
  case csv
  case json
  case xml
}

public class QuandlQuery {
  private let scheme = "https"
  private let host = "www.quandl.com"
  private let basePath = "/api/v3/"
  
  private let apiVersion = "2015-04-09"
  
  var authenticated = true
  
  ///Returning Data Format
  var format = QuandlDataFormat.json
  
  var URL: NSURL {
    get {
      return NSURL()
    }
  }
  
  func run(completion: (NSData?, NSURLResponse?, NSError?) -> Void) {
    let defaultConfigObject = NSURLSessionConfiguration.defaultSessionConfiguration()
    let querySession = NSURLSession(configuration: defaultConfigObject)
    let queryRequest = NSURLRequest(URL: self.URL)
    querySession.dataTaskWithRequest(queryRequest) { (data, response, error) -> Void in
      completion(data, response, error)
    }.resume()
  }
  
}

//--QuandlDataQuery

public class QuandlDataQuery: QuandlQuery {
  
  var getMetadata = false
  
  ///Each database on Quandl has a unique database code.
  var databaseCode: String
  
  ///Each dataset on Quandl has a unique dataset code.
  var datasetCode: String
  
  ///Use limit to get only the first n rows of your dataset.
  ///Use limit = 1 to get the latest observation for any dataset.
  var limit: Int? = nil
  
  ///Use rows to get only the first n rows of your dataset.
  ///Use rows = 1 to get the latest observation for any dataset.
  var rows: Int? = nil
  
  ///Request a specific column.
  ///Column 0 is the date column and is always returned.
  ///Data begins at column 1.
  var columnIndex: Int? = nil
  
  ///Retrieve data within a specific date range.
  var startDate: NSDate? = nil
  
  ///Retrieve data within a specific date range.
  var endDate: NSDate? = nil
  
  enum DataSortOrder: String {
    case ascending = "asc"
    case descending = "desc"
  }
  
  ///Data sort order. The default sort order is descending.
  var order: DataSortOrder? = nil
  
  enum CollapseFrequency: String {
    case none
    case daily
    case weekly
    case monthly
    case quarterly
    case annual
  }
  
  ///Parameters to indicate the desired frequency.
  var collapse: CollapseFrequency? = nil
  
  enum DataTransform: String {
    case none
    case diff
    case rdiff
    case rdiff_from
    case cumul
    case normalize
  }
  
  ///Perform calculations on your data prior to downloading.
  var transform: DataTransform? = nil
  
  ///Request data without column names.
  ///This can only be applied to CSV.
  var excludeColumnNames: Bool = false
  
  override var URL: NSURL {
    get {
      let urlcomponents = NSURLComponents()
      urlcomponents.scheme = self.scheme
      urlcomponents.host = self.host
      
      var path: NSString = self.basePath
      path = path.stringByAppendingPathComponent("datasets")
      path = path.stringByAppendingPathComponent(self.databaseCode)
      path = path.stringByAppendingPathComponent(self.datasetCode)
      path = self.getMetadata ? path : path.stringByAppendingPathComponent("data")
      path = path.stringByAppendingPathExtension(self.format.rawValue)!
      urlcomponents.path = path as String
      
      var queryItems: [NSURLQueryItem] = []
      
      if self.authenticated {
        queryItems.append( NSURLQueryItem(name: "api_key", value: quandlAPIKey) )
      }
      
      if let limit = self.limit {
        queryItems.append( NSURLQueryItem(name: "limit", value: "\(limit)") )
      }
      if let rows = self.rows {
        queryItems.append( NSURLQueryItem(name: "rows", value: "\(rows)") )
      }
      if let columnIndex = self.columnIndex {
        queryItems.append( NSURLQueryItem(name: "column_index", value: "\(columnIndex)") )
      }
      
      let formatter = NSDateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      
      if let startDate = self.startDate {
        queryItems.append( NSURLQueryItem(name: "start_date", value: formatter.stringFromDate(startDate)) )
      }
      if let endDate = self.endDate {
        queryItems.append( NSURLQueryItem(name: "end_date", value: formatter.stringFromDate(endDate)) )
      }
      
      if let order = self.order {
        queryItems.append( NSURLQueryItem(name: "order", value: order.rawValue) )
      }
      if let collapse = self.collapse {
        queryItems.append( NSURLQueryItem(name: "collapse", value: collapse.rawValue) )
      }
      if let transform = self.transform {
        queryItems.append( NSURLQueryItem(name: "transform", value: transform.rawValue) )
      }
      
      if self.excludeColumnNames {
        queryItems.append( NSURLQueryItem(name: "exclude_column_names", value: "true") )
      }
      
      queryItems.append( NSURLQueryItem(name: "api_version", value: self.apiVersion) )
      
      if !queryItems.isEmpty {
        urlcomponents.queryItems = queryItems
      }
      
      return urlcomponents.URL!
    }
  }
  
  init(databaseCode: String, datasetCode: String) {
    self.databaseCode = databaseCode
    self.datasetCode = datasetCode
    super.init()
  }
}

//--QuandlMetadataQuery

public class QuandlMetadataQuery: QuandlQuery {
  
  ///Each database on Quandl has a unique database code.
  var databaseCode: String
  
  ///Each dataset on Quandl has a unique dataset code.
  var datasetCode: String
  
  override var URL: NSURL {
    get {
      let urlcomponents = NSURLComponents()
      urlcomponents.scheme = self.scheme
      urlcomponents.host = self.host
      
      var path: NSString = self.basePath
      path = path.stringByAppendingPathComponent("datasets")
      path = path.stringByAppendingPathComponent(self.databaseCode)
      path = path.stringByAppendingPathComponent(self.datasetCode)
      path = path.stringByAppendingPathComponent("metadata")
      path = path.stringByAppendingPathExtension(self.format.rawValue)!
      urlcomponents.path = path as String
      
      var queryItems: [NSURLQueryItem] = []
      
      if self.authenticated {
        queryItems.append( NSURLQueryItem(name: "api_key", value: quandlAPIKey) )
      }
      
      queryItems.append( NSURLQueryItem(name: "api_version", value: self.apiVersion) )
      
      if !queryItems.isEmpty {
        urlcomponents.queryItems = queryItems
      }
      
      return urlcomponents.URL!
    }
  }
  
  init(databaseCode: String, datasetCode: String) {
    self.databaseCode = databaseCode
    self.datasetCode = datasetCode
    super.init()
  }
}

//--QuandlDatasetQuery

public class QuandlDatasetQuery: QuandlQuery {
  
  ///You can restrict your search to a specific database by including a Quandl database code.
  var databaseCode: String?
  
  ///You can retrieve all datasets related to a search term using the query parameter.
  var queryTerms: [String]?
  
  ///The number of results per page that will be returned.
  var perPage: Int?
  
  ///The current page of total available pages you wish to view.
  var page: Int?
  
  override var URL: NSURL {
    get {
      let urlcomponents = NSURLComponents()
      urlcomponents.scheme = self.scheme
      urlcomponents.host = self.host
      
      var path: NSString = self.basePath
      path = path.stringByAppendingPathComponent("datasets")
      path = path.stringByAppendingPathExtension(self.format.rawValue)!
      urlcomponents.path = path as String
      
      var queryItems: [NSURLQueryItem] = []
      
      if self.authenticated {
        queryItems.append( NSURLQueryItem(name: "api_key", value: quandlAPIKey) )
      }
      
      if let databaseCode = self.databaseCode {
        queryItems.append( NSURLQueryItem(name: "database_code", value: databaseCode) )
      }
      
      if let queryTerms = self.queryTerms {
        var queryTermsString = queryTerms.joinWithSeparator("+")
        queryTermsString = queryTermsString.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!

        queryItems.append( NSURLQueryItem(name: "query", value: queryTermsString) )
      }
      
      if let perPage = self.perPage {
        queryItems.append( NSURLQueryItem(name: "per_page", value: "\(perPage)") )
      }
      if let page = self.page {
        queryItems.append( NSURLQueryItem(name: "page", value: "\(page)") )
      }
      
      queryItems.append( NSURLQueryItem(name: "api_version", value: self.apiVersion) )
      
      if !queryItems.isEmpty {
        urlcomponents.queryItems = queryItems
      }
      
      return urlcomponents.URL!
    }
  }
}

//--QuandlDatabaseListQuery

public class QuandlDatabaseListQuery: QuandlQuery {
  
  ///You can retrieve all datasets related to a search term using the query parameter.
  var queryTerms: [String]?
  
  ///The number of results per page that will be returned.
  var perPage: Int?
  
  ///The current page of total available pages you wish to view.
  var page: Int?
  
  override var URL: NSURL {
    get {
      let urlcomponents = NSURLComponents()
      urlcomponents.scheme = self.scheme
      urlcomponents.host = self.host
      
      var path: NSString = self.basePath
      path = path.stringByAppendingPathComponent("databases")
      path = path.stringByAppendingPathExtension(self.format.rawValue)!
      urlcomponents.path = path as String
      
      var queryItems: [NSURLQueryItem] = []
      
      if self.authenticated {
        queryItems.append( NSURLQueryItem(name: "api_key", value: quandlAPIKey) )
      }
      
      if let queryTerms = self.queryTerms {
        var queryTermsString = queryTerms.joinWithSeparator("+")
        queryTermsString = queryTermsString.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        queryItems.append( NSURLQueryItem(name: "query", value: queryTermsString) )
      }
      
      if let perPage = self.perPage {
        queryItems.append( NSURLQueryItem(name: "per_page", value: "\(perPage)") )
      }
      if let page = self.page {
        queryItems.append( NSURLQueryItem(name: "page", value: "\(page)") )
      }
      
      queryItems.append( NSURLQueryItem(name: "api_version", value: self.apiVersion) )
      
      if !queryItems.isEmpty {
        urlcomponents.queryItems = queryItems
      }
      
      return urlcomponents.URL!
    }
  }
}

//--QuandlDatasetListQuery

public class QuandlDatasetListQuery: QuandlQuery {
  
  ///You can restrict your search to a specific database by including a Quandl database code.
  var databaseCode: String
  
  override var URL: NSURL {
    get {
      let urlcomponents = NSURLComponents()
      urlcomponents.scheme = self.scheme
      urlcomponents.host = self.host
      
      var path: NSString = self.basePath
      path = path.stringByAppendingPathComponent("databases")
      path = path.stringByAppendingPathComponent(self.databaseCode)
      path = path.stringByAppendingPathComponent("codes")
      path = path.stringByAppendingPathExtension(self.format.rawValue)!
      urlcomponents.path = path as String
      
      var queryItems: [NSURLQueryItem] = []
      
      if self.authenticated {
        queryItems.append( NSURLQueryItem(name: "api_key", value: quandlAPIKey) )
      }
      
      queryItems.append( NSURLQueryItem(name: "api_version", value: self.apiVersion) )
      
      if !queryItems.isEmpty {
        urlcomponents.queryItems = queryItems
      }
      
      return urlcomponents.URL!
    }
  }
  
  init(databaseCode: String) {
    self.databaseCode = databaseCode
    super.init()
  }
}

//--QuandlDatabaseMetadataQuery

public class QuandlDatabaseMetadataQuery: QuandlQuery {
  
  ///You can restrict your search to a specific database by including a Quandl database code.
  var databaseCode: String
  
  override var URL: NSURL {
    get {
      let urlcomponents = NSURLComponents()
      urlcomponents.scheme = self.scheme
      urlcomponents.host = self.host
      
      var path: NSString = self.basePath
      path = path.stringByAppendingPathComponent("databases")
      path = path.stringByAppendingPathComponent(self.databaseCode)
      path = path.stringByAppendingPathExtension(self.format.rawValue)!
      urlcomponents.path = path as String
      
      var queryItems: [NSURLQueryItem] = []
      
      if self.authenticated {
        queryItems.append( NSURLQueryItem(name: "api_key", value: quandlAPIKey) )
      }
      
      queryItems.append( NSURLQueryItem(name: "api_version", value: self.apiVersion) )
      
      if !queryItems.isEmpty {
        urlcomponents.queryItems = queryItems
      }
      
      return urlcomponents.URL!
    }
  }
  
  init(databaseCode: String) {
    self.databaseCode = databaseCode
    super.init()
  }
}

//--QuandlEntireDatabaseQuery

public class QuandlEntireDatabaseQuery: QuandlQuery {
  
  ///You can restrict your search to a specific database by including a Quandl database code.
  var databaseCode: String
  
  enum DownloadType: String {
    case partial
    case complete
  }
  
  ///Data returned can be either partial or complete.
  var downloadType: DownloadType?
  
  override var URL: NSURL {
    get {
      let urlcomponents = NSURLComponents()
      urlcomponents.scheme = self.scheme
      urlcomponents.host = self.host
      
      var path: NSString = self.basePath
      path = path.stringByAppendingPathComponent("databases")
      path = path.stringByAppendingPathComponent(self.databaseCode)
      path = path.stringByAppendingPathComponent("data")
      urlcomponents.path = path as String
      
      var queryItems: [NSURLQueryItem] = []
      
      if self.authenticated {
        queryItems.append( NSURLQueryItem(name: "api_key", value: quandlAPIKey) )
      }
      
      if let downloadType = self.downloadType {
        queryItems.append( NSURLQueryItem(name: "download_type", value: downloadType.rawValue) )
      }
      
      queryItems.append( NSURLQueryItem(name: "api_version", value: self.apiVersion) )
      
      if !queryItems.isEmpty {
        urlcomponents.queryItems = queryItems
      }
      
      return urlcomponents.URL!
    }
  }
  
  init(databaseCode: String) {
    self.databaseCode = databaseCode
    super.init()
  }
}