//
//  Link.swift
//  TagMe
//
//  Created by Stanimir Hristov on 5/27/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import Foundation

class Link {
  var href = ""

  init() {}

  init(json: [String: Any]) {
    if let href = json["href"] as? String {
      self.href = href
    }
    else {
      assert(false)
    }
  }
}

class Links {
  var current = Link()

  var first: Link?
  var next: Link?
  var prev: Link?
  var last: Link?

  init() {}

  init(json: [String: Any]) {
    if let current = json["self"] as? [String: Any] {
      self.current = Link(json: current)
    }
    else {
      assert(false)
    }

    if let first = json["first"] as? [String: Any] {
      self.first = Link(json: first)
    }

    if let next = json["next"] as? [String: Any] {
      self.next = Link(json: next)
    }

    if let prev = json["prev"] as? [String: Any] {
      self.prev = Link(json: prev)
    }

    if let last = json["last"] as? [String: Any] {
      self.last = Link(json: last)
    }
  }
}
