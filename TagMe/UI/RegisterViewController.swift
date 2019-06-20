//
//  RegisterViewController.swift
//  TagMe
//
//  Created by Stanimir Hristov on 5/19/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var confirmPasswordTextField: UITextField!
  @IBOutlet weak var fieldsStackView: UIStackView!

  //MARK: View Controller Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addBackgroundImage(named: Constants.BACKGROUND_IMAGE)
  }

  @IBAction func handleRegister(_ sender: UIButton) {
    removeWarnings()
    if checkEmail(), checkPassword(), checkConfirmPassword() {
      //TODO: Add spinner
      RegisterUser(email: emailTextField.text!, password: passwordTextField.text!)
    }
  }
}

//MARK: Text Field Delegate

extension RegisterViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    if textField === emailTextField {
      passwordTextField.becomeFirstResponder()
    }
    else if textField === passwordTextField {
      confirmPasswordTextField.becomeFirstResponder()
    }

    return true
  }
}

//MARK: Constants

extension RegisterViewController {
  struct Constants {
    static let MIN_EMAIL_LENGTH = 5
    static let MAX_EMAIL_LENGTH = 40
    static let MIN_PASSWORD_LENGTH = 6
    static let MAX_PASSWORD_LENGTH = 20
    static let WARNING_FONT_SIZE: CGFloat = 14
    static let NORMAL_STATUS_CODE = 201
    static let EMAIL_EXIST_STATUS_CODE = 400
    static let EMAIL_INDEX = 1
    static let PASSWORD_INDEX = 2
    static let CONFIRM_PASSWORD_INDEX = 3

    static let EMAIL_FORMAT = "SELF MATCHES %@"
    static let EMAIL_REGEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    static let BACKGROUND_IMAGE = "registerBackground"
    static let EMPTY_EMAIL_MSG = "Email cannot be empty"
    static let INVALID_EMAIL_MSG = "Invalid email!"
    static let INVALID_LENGTH_EMAIL_MSG = "Email should be between 5 and 40 characthers"
    static let EMPTY_PASSWORD_MSG = "Password cannot be empty"
    static let INVALID_LENGTH_PASSWORD_MSG = "Password should be between 6 and 20 characthers"
    static let CONFIRM_EMPTY_PASSWORD_MSG = "Confirm password cannot be empty"
    static let MATCH_PASSWORD_MSG = "Passwords does not match"
    static let REGISTRATION_TITLE = "Registration"
    static let OK_TITLE = "OK"
    static let LOGIN_TITLE = "Login"
    static let SHOW_LOGIN_SEGUE_ID = "ShowLogin"
    static let SUCCESS_MSG = "Succeeded"
    static let EMAIL_EXIST_MSG = "Email exists, please use another one"
    static let REGISTRATION_FAILED_MSG = "Registration failed !!!"
  }
}

//MARK: Text Field Validation

extension RegisterViewController {
  private func removeWarnings() {
    for subview in fieldsStackView.subviews {
      if subview.isKind(of: UILabel.self) {
        subview.removeFromSuperview()
      }
    }
  }

  private func isEmailEmpty() -> Bool {
    if let email = emailTextField.text {
      return email.isEmpty
    }

    return true
  }

  private func isEmailCorrectLength() -> Bool {
    if let email = emailTextField.text {
      let length = email.count
      return length >= Constants.MIN_EMAIL_LENGTH && length <= Constants.MAX_EMAIL_LENGTH
    }

    return false;
  }

  private func isPasswordEmpty() -> Bool {
    if let password = passwordTextField.text {
      return password.isEmpty
    }

    return true
  }

  private func isPasswordCorrectLength() -> Bool {
    if let password = passwordTextField.text {
      let length = password.count
      return length >= Constants.MIN_PASSWORD_LENGTH && length <= Constants.MAX_PASSWORD_LENGTH
    }

    return false;
  }

  private func isConfirmPasswordEmpty() -> Bool {
    return confirmPasswordTextField.text?.isEmpty ?? true
  }

  private func doPasswordsMatch() -> Bool {
    if let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text {
      return password == confirmPassword
    }

    return false
  }

  private func isEmailValid() -> Bool {
    let emailTest = NSPredicate(format: Constants.EMAIL_FORMAT, Constants.EMAIL_REGEX)

    return emailTest.evaluate(with: emailTextField.text)
  }

  private func createWarningLabel() -> UILabel {
    let warningLabel = UILabel()
    warningLabel.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
    warningLabel.font = UIFont.systemFont(ofSize: Constants.WARNING_FONT_SIZE)
    warningLabel.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

    return warningLabel
  }

  private func showWarningWith(message: String, forIndex index: Int) {
    let warningLabel = createWarningLabel()
    warningLabel.text = message
    warningLabel.numberOfLines = 0
    fieldsStackView.insertArrangedSubview(warningLabel, at: index)
  }

  private func checkEmail() -> Bool {
    if isEmailEmpty() {
      showWarningWith(message: Constants.EMPTY_EMAIL_MSG, forIndex: Constants.EMAIL_INDEX)
      return false
    }

    if !isEmailValid() {
      showWarningWith(message: Constants.INVALID_EMAIL_MSG, forIndex: Constants.EMAIL_INDEX)
      return false
    }

    if !isEmailCorrectLength() {
      showWarningWith(message: Constants.INVALID_LENGTH_EMAIL_MSG, forIndex: Constants.EMAIL_INDEX)
      return false
    }

    return true
  }

  private func checkPassword() -> Bool {
    if isPasswordEmpty() {
      showWarningWith(message: Constants.EMPTY_PASSWORD_MSG, forIndex: Constants.PASSWORD_INDEX)
      return false
    }

    if !isPasswordCorrectLength() {
      showWarningWith(message: Constants.INVALID_LENGTH_PASSWORD_MSG, forIndex: Constants.PASSWORD_INDEX)
      return false
    }

    return true
  }

  private func checkConfirmPassword() -> Bool {
    if isConfirmPasswordEmpty() {
      showWarningWith(message: Constants.CONFIRM_EMPTY_PASSWORD_MSG, forIndex: Constants.CONFIRM_PASSWORD_INDEX)
      return false
    }

    if !doPasswordsMatch() {
      showWarningWith(message: Constants.MATCH_PASSWORD_MSG, forIndex: Constants.CONFIRM_PASSWORD_INDEX)
      return false
    }

    return true
  }
}

//MARK: Update after request

extension RegisterViewController {
  private func refreshEmailTextField() {
    emailTextField.text = ""
  }

  private func refreshAllTextFields() {
    refreshEmailTextField()
    passwordTextField.text = ""
    confirmPasswordTextField.text = ""
  }

  private func registrationSucceeded() {
    refreshAllTextFields()
    let ok = UIAlertAction(title: Constants.OK_TITLE, style: .cancel)
    let goToLogin = UIAlertAction(
      title: Constants.LOGIN_TITLE,
      style: .default,
      handler: { (action: UIAlertAction) in
        self.performSegue(withIdentifier: Constants.SHOW_LOGIN_SEGUE_ID, sender: self)
      }
    )
    let alert = createAlert(
      title: Constants.REGISTRATION_TITLE,
      message: Constants.SUCCESS_MSG,
      actions: [ok, goToLogin]
    )
    present(alert, animated: true, completion: nil)
  }

  private func showEmailExistAlert() {
    let ok = UIAlertAction(title: Constants.OK_TITLE, style: .cancel)
    let alert = createAlert(title: Constants.REGISTRATION_TITLE, message: Constants.EMAIL_EXIST_MSG, actions: [ok])
    present(alert, animated: true, completion: nil)
  }

  private func registrationFailed() {
    let ok = UIAlertAction(title: Constants.OK_TITLE, style: .cancel)
    let alert = createAlert(
      title: Constants.REGISTRATION_TITLE,
      message: Constants.REGISTRATION_FAILED_MSG,
      actions: [ok]
    )
    present(alert, animated: true, completion: nil)
  }
}

//MARK: Register Request

extension RegisterViewController {
  private func RegisterUser(email: String, password: String) {
    RequestCenter.instance.registerUser(email: email, password: password) { data, response in
      if let httpStatus = response as? HTTPURLResponse {
        if httpStatus.statusCode == Constants.EMAIL_EXIST_STATUS_CODE {
          DispatchQueue.main.async {
            self.showEmailExistAlert()
          }
          return
        }

        if httpStatus.statusCode != Constants.NORMAL_STATUS_CODE {
          print("StatusCode should be 200, but is \(httpStatus.statusCode)")
          DispatchQueue.main.async {
            self.registrationFailed()
          }
          return
        }
      }

      let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
      DispatchQueue.main.async {
        if let _ = responseJSON as? [String: Any] {
          self.registrationSucceeded()
        }
        else {
          self.registrationFailed()
        }
      }
    }
  }
}
