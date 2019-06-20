//
//  StringUtils.swift
//  TagMe
//
//  Created by Stanimir Hristov on 5/25/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import Foundation

extension String {
  func getWords() -> [String] {
    var words = [String]()
    let range = self.startIndex..<self.endIndex
    self.enumerateSubstrings(in: range, options: .byWords) { word, _, _, _ in
      if let word = word {
        words.append(word)
      }
    }

    return words
  }
}
