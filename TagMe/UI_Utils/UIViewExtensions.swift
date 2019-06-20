//
//  UIViewExtensions.swift
//  TagMe
//
//  Created by Stanimir Hristov on 5/23/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import UIKit

extension UIView {
  func addBackgroundImage(named: String) {
    if let image = UIImage(named: named) {
      let backgroundImageView = UIImageView(image: image)
      backgroundImageView.frame = frame
      backgroundImageView.contentMode = .scaleAspectFill
      addSubview(backgroundImageView)
      sendSubviewToBack(backgroundImageView)
    }
  }
}
