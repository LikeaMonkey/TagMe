//
//  AccountViewController.swift
//  TagMe
//
//  Created by Stanimir Hristov on 5/23/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {

  //MARK: View Controller Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addBackgroundImage(named: Constants.BACKGROUND_IMAGE)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    setTitle()
    showSignOutButton(show: true)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    showSignOutButton(show: false)
  }
}

// MARK: Constants

extension AccountViewController {
  struct Constants {
    static let TITLE = "Account"
    static let SIGN_OUT_TITLE = "Sign Out"
    static let BACKGROUND_IMAGE = "accountBackground"
    static let SIGN_OUT_SEGUE_ID = "SignOut"
  }
}

//MARK: Action Handler

extension AccountViewController {
  @objc private func signOut() {
    self.performSegue(withIdentifier: Constants.SIGN_OUT_SEGUE_ID, sender: self)
  }
}

//MARK: Helpers

extension AccountViewController {
  private func setTitle() {
    self.parent?.navigationItem.title = Constants.TITLE
  }

  private func getSignOutButton() -> UIBarButtonItem {
    return UIBarButtonItem(title: Constants.SIGN_OUT_TITLE, style: .done, target: self, action: #selector(signOut))
  }

  private func showSignOutButton(show: Bool) {
    if let navigationItem = self.parent?.navigationItem {
      navigationItem.leftBarButtonItem = show ? getSignOutButton() : nil
    }
  }
}
