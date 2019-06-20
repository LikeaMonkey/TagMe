//
//  AlertUtils.swift
//  TagMe
//
//  Created by Stanimir Hristov on 5/25/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import UIKit

func createAlert(title: String, message: String, actions: [UIAlertAction]) -> UIAlertController {
  let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
  for action in actions {
    alert.addAction(action)
  }

  return alert
}

func createAlertWithCancel(title: String, message: String, actions: [UIAlertAction]) -> UIAlertController {
  var allActions = actions
  allActions.append(UIAlertAction(title: "Cancel", style: .cancel))

  return createAlert(title: title, message: message, actions: allActions)
}

func createActionSheet(title: String, message: String, actions: [UIAlertAction]) -> UIAlertController {
  let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
  for action in actions {
    actionSheet.addAction(action)
  }

  return actionSheet
}

func createActionSheetWithCancel(title: String, message: String, actions: [UIAlertAction]) -> UIAlertController {
  var allActions = actions
  allActions.append(UIAlertAction(title: "Cancel", style: .cancel))

  return createActionSheet(title: title, message: message, actions: allActions)
}
