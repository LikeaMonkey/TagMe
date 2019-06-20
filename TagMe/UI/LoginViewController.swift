//
//  LoginViewController.swift
//  TagMe
//
//  Created by Stanimir Hristov on 5/15/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
  @IBOutlet weak private var emailTextField: UITextField!
  @IBOutlet weak private var passwordTextField: UITextField!
  @IBOutlet weak var spinner: UIActivityIndicatorView!

  //MARK: View Controller Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addBackgroundImage(named: Constants.BACKGROUND_IMAGE)
  }

  //MARK: Actions

  @IBAction func handleLogin(_ sender: UIButton) {
    view.endEditing(true)
    spinner.startAnimating()
    if let email = emailTextField.text, let password = passwordTextField.text {
      GetAuthorizationAccessToken(email: email, password: password)
    }
  }
}

// MARK: Constants

extension LoginViewController {
  struct Constants {
    static let BACKGROUND_IMAGE = "background"
    static let OK_TITLE = "OK"
    static let LOGIN_TITLE = "Login"
    static let LOGIN_FAILED_MSG = "Login failed"
    static let LOGIN_SEGUE_ID = "SegueLogin"
  }
}

//MARK: Text Field Delegate

extension LoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    if textField === emailTextField {
      passwordTextField.becomeFirstResponder()
    }

    return true
  }
}

//MARK: Update after request

extension LoginViewController {
  private func refreshTextFields() {
    emailTextField.text = ""
    passwordTextField.text = ""
  }

  private func showFailAlert() {
    let ok = UIAlertAction(title: Constants.OK_TITLE, style: .cancel)
    let alert = createAlert(title: Constants.LOGIN_TITLE, message: Constants.LOGIN_FAILED_MSG, actions: [ok])
    present(alert, animated: true, completion: nil)
  }

  private func loginFinishedWith(success: Bool) {
    refreshTextFields()
    spinner.stopAnimating()
    if success {
      performSegue(withIdentifier: Constants.LOGIN_SEGUE_ID, sender: self)
    }
    else {
      showFailAlert()
    }
  }
}

//MARK: Login Request

extension LoginViewController {
  private func GetAuthorizationAccessToken(email: String, password: String) {
    RequestCenter.instance.loginUser(email: email, password: password) { data, response in
      let JSON = try? JSONSerialization.jsonObject(with: data, options: [])
      DispatchQueue.main.async {
        if let responseJSON = JSON as? [String: Any] {
          JWT.instance.accessToken = responseJSON["accessToken"] as? String ?? ""
          JWT.instance.tokenType = responseJSON["tokenType"] as? String ?? ""
          self.loginFinishedWith(success: !JWT.instance.isEmpty)
        }
        else {
          self.loginFinishedWith(success: false)
        }
      }
    }
  }
}
