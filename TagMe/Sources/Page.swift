//
//  Page.swift
//  TagMe
//
//  Created by Stanimir Hristov on 5/27/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import Foundation

class Page {
  var size = 0
  var totalElements = 0
  var totalPages = 0
  var number = 0

  init() {}

  init(json: [String: Any]) {
    if let size = json["size"] as? Int {
      self.size = size
    }
    else {
      assert(false)
    }

    if let totalElements = json["totalElements"] as? Int {
      self.totalElements = totalElements
    }
    else {
      assert(false)
    }

    if let totalPages = json["totalPages"] as? Int {
      self.totalPages = totalPages
    }
    else {
      assert(false)
    }

    if let number = json["number"] as? Int {
      self.number = number
    }
    else {
      assert(false)
    }
  }
}
