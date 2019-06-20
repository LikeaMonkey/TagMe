//
//  Access.swift
//  TagMe
//
//  Created by Stanimir Hristov on 5/7/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import Foundation

// JSON Web Token used for Authorization

class JWT {
  static let instance = JWT()

  private init() {}

  var accessToken = ""
  var tokenType = ""

  var isEmpty: Bool {
    return accessToken.isEmpty || tokenType.isEmpty
  }
}
