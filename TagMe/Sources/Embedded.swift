//
//  Embedded.swift
//  TagMe
//
//  Created by Stanimir Hristov on 5/27/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import Foundation

class Embedded {
  var resposes = [TaggedPictureResponse]()

  init() {}

  init(json: [String: Any]) {
    if let responses = json["taggedPictureResponseList"] as? [[String: Any]] {
      for response in responses {
        self.resposes.append(TaggedPictureResponse(json: response))
      }
    }
    else {
      assert(false)
    }
  }
}
