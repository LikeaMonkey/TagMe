//
//  AllImagesResponse.swift
//  TagMe
//
//  Created by Stanimir Hristov on 5/27/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import Foundation

class AllImagesResponse {
  var embedded = Embedded()
  var links = Links()
  var page = Page()

  init() {}

  init(json: [String: Any]) {
    if let embedded = json["_embedded"] as? [String: Any] {
      self.embedded = Embedded(json: embedded)
    }
    else {
      assert(false)
    }

    if let links = json["_links"] as? [String: Any] {
      self.links = Links(json: links)
    }
    else {
      assert(false)
    }

    if let page = json["page"] as? [String: Any] {
      self.page = Page(json: page)
    }
    else {
      assert(false)
    }
  }
}
