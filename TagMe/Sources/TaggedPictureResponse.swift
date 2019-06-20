//
//  TaggedPictureResponse.swift
//  TagMe
//
//  Created by Stanimir Hristov on 5/24/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import Foundation

class TaggedPictureResponse {
  var id: UInt32 = 0
  var result = [PictureTagsProviderResponse]()
  var pictureUrl = ""

  init() {}

  init(json: [String: Any]) {
    if let id = json["id"] as? UInt32 {
      self.id = id
    }
    else {
      assert(false)
    }

    if let results = json["result"] as? [[String: Any]] {
      for result in results {
        self.result.append(PictureTagsProviderResponse(json: result))
      }
    }
    else {
      assert(false)
    }

    if let url = json["pictureUrl"] as? String {
      self.pictureUrl = url
    }
    else {
      assert(false)
    }
  }
}
