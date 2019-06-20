//
//  Tag.swift
//  TagMe
//
//  Created by Stanimir Hristov on 5/24/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import Foundation

struct Tag {
  var tag = ""
  var confidence = 0.0

  init() {}

  init(json: [String: Any]) {
    if let tag = json["tag"] as? String {
      self.tag = tag
    }
    else {
      assert(false)
    }

    if let confidence = json["confidence"] as? Double {
      self.confidence = confidence
    }
    else {
      assert(false)
    }
  }
}
