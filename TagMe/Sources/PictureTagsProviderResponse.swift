//
//  PictureTagsProviderResponse.swift
//  TagMe
//
//  Created by Stanimir Hristov on 5/24/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import Foundation

class PictureTagsProviderResponse {
  var pictureTagsProviderName = PictureTagsProviderName()
  var tags = [Tag]()

  let PROVIDER_KEY = "pictureTagsProviderName"
  let TAGS_KEY = "tags"

  init() {}

  init(json: [String: Any]) {
    if let providerName = json[PROVIDER_KEY] as? String {
      if let provider = PictureTagsProviderName(name: providerName) {
        pictureTagsProviderName = provider
      }
      else {
        assert(false)
      }
    }
    else {
      assert(false)
    }

    if let tags = json[TAGS_KEY] as? [[String: Any]] {
      for tag in tags {
        self.tags.append(Tag(json: tag))
      }
    }
    else {
      assert(false)
    }
  }
}
