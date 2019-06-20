//
//  PictureTagsProviderName.swift
//  TagMe
//
//  Created by Stanimir Hristov on 5/24/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import Foundation

enum PictureTagsProviderName {
  case CLARIFAI
  case IMAGGA
  case XIMILAR

  init() {
    self = .IMAGGA
  }

  init?(name: String) {
    switch name {
    case "IMAGGA":
      self = .IMAGGA
    case "CLARIFAI":
      self = .CLARIFAI
    case "XIMILAR":
      self = .XIMILAR
    default:
      assert(false)
      return nil
    }
  }
}

//MARK: Description

extension PictureTagsProviderName: CustomStringConvertible {
  var description: String {
    switch self {
    case .IMAGGA:
      return "IMAGGA"
    case .CLARIFAI:
      return "CLARIFAI"
    case .XIMILAR:
      return "XIMILAR"
    }
  }
}
