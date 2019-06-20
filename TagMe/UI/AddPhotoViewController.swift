//
//  AddPhotoViewController.swift
//  TagMe
//
//  Created by Stanimir Hristov on 5/1/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import UIKit

class AddPhotoViewController: UIViewController {
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var imageButton: UIButton!
  @IBOutlet var spinner: UIActivityIndicatorView!

  var response = TaggedPictureResponse()

  private var isSelect = true {
    didSet {
      if isSelect {
        imageButton.setTitle(Constants.SELECT_BUTTON_TITLE, for: .normal)
        imageView.image = UIImage(named: Constants.NO_PHOTO_IMAGE)
      }
      else {
        imageButton.setTitle(Constants.UPLOAD_BUTTON_TITLE, for: .normal)
      }
    }
  }

  // MARK: View Controller Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    isSelect = true

    view.addBackgroundImage(named: Constants.BACKGROUND_IMAGE)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    parent?.navigationItem.title = Constants.TITLE
  }

  // MARK: Actions

  @IBAction func chooseImage(_: UIButton) {
    if !isSelect {
      uploadImage()
      return
    }

    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self

    let camera = UIAlertAction(
      title: Constants.CAMERA_TITLE,
      style: .default,
      handler: { (_: UIAlertAction) in
        imagePickerController.sourceType = .camera
        self.present(imagePickerController, animated: true, completion: nil)
      }
    )

    let photoLibrary = UIAlertAction(
      title: Constants.PHOTO_LIBRARY_TITLE,
      style: .default,
      handler: { (_: UIAlertAction) in
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
      }
    )

    let actionSheet = createActionSheetWithCancel(
      title: Constants.CHOOSE_ACTION_TITLE,
      message: Constants.CHOOSE_ACTION_MESSAGE,
      actions: [camera, photoLibrary]
    )
    present(actionSheet, animated: true, completion: nil)
  }
}

// MARK: Constants

extension AddPhotoViewController {
  enum Constants {
    static let TITLE = "Add image"
    static let BACKGROUND_IMAGE = "addPhotoBackground"
    static let SELECT_BUTTON_TITLE = "Select image"
    static let UPLOAD_BUTTON_TITLE = "Upload image"
    static let NO_PHOTO_IMAGE = "NoPhotoSelected"
    static let CAMERA_TITLE = "Camera"
    static let PHOTO_LIBRARY_TITLE = "Photo Library"
    static let CHOOSE_ACTION_TITLE = "Photo Source"
    static let CHOOSE_ACTION_MESSAGE = "Photo Source"
    static let SEE_RESULTS_SEGUE_ID = "SeeResults"
    static let SEE_RESULTS_TITLE = "See results"
    static let SELECT_NEW_IMAGE_TITLE = "See results"
    static let UPLOAD_IMAGE_TITLE = "See results"
    static let SUCESS_UPLOAD_MSG = "See results"
    static let FAIL_UPLOAD_MSG = "See results"
    static let OK_TITLE = "OK"

    static let JPEG_COMPRESSION: CGFloat = 0.1
  }
}

// MARK: Navigation

extension AddPhotoViewController {
  override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
    if segue.identifier == Constants.SEE_RESULTS_SEGUE_ID {
      if let destination = segue.destination as? ImageDetailViewController {
        destination.imageInfo = response
        destination.image = imageView.image
        isSelect = true
      }
    }
  }
}

// MARK: Upload Image

extension AddPhotoViewController {
  private func uploadImage() {
    if let imageData = imageView.image?.jpegData(compressionQuality: Constants.JPEG_COMPRESSION) {
      spinner.startAnimating()
      uploadImage(imageData: imageData)
    }
    else {
      assert(false)
    }
  }

  private func uploadImage(imageData: Data) {
    RequestCenter.instance.uploadImage(imageData: imageData) { data, _ in
      let JSON = try? JSONSerialization.jsonObject(with: data, options: [])
      DispatchQueue.main.async {
        if let responseJSON = JSON as? [String: Any] {
          self.response = TaggedPictureResponse(json: responseJSON)
          self.uploadComplete(succeed: true)
        }
        else {
          self.uploadComplete(succeed: false)
        }
      }
    }
  }
}

// MARK: Update After Upload

extension AddPhotoViewController {
  private func showSuccessAlert() {
    let seeResults = UIAlertAction(
      title: Constants.SEE_RESULTS_TITLE,
      style: .default,
      handler: { (_: UIAlertAction) in
        self.performSegue(withIdentifier: Constants.SEE_RESULTS_SEGUE_ID, sender: nil)
      }
    )
    let selectNewImage = UIAlertAction(
      title: Constants.SELECT_NEW_IMAGE_TITLE,
      style: .default,
      handler: { (_: UIAlertAction) in
        self.isSelect = true
      }
    )

    let alert = createAlert(
      title: Constants.UPLOAD_IMAGE_TITLE,
      message: Constants.SUCESS_UPLOAD_MSG,
      actions: [seeResults, selectNewImage]
    )
    present(alert, animated: true, completion: nil)
  }

  private func showFailAlert() {
    let ok = UIAlertAction(title: Constants.OK_TITLE, style: .cancel)
    let selectNewPhoto = UIAlertAction(
      title: Constants.SELECT_NEW_IMAGE_TITLE,
      style: .default,
      handler: { (_: UIAlertAction) in
        self.isSelect = true
      }
    )

    let alert = createAlert(
      title: Constants.UPLOAD_IMAGE_TITLE,
      message: Constants.FAIL_UPLOAD_MSG,
      actions: [ok, selectNewPhoto]
    )
    present(alert, animated: true, completion: nil)
  }

  private func saveUploadedImage() {
    let urlString = URL_BASE + response.pictureUrl
    if let url = URL(string: urlString) {
      DispatchQueue.global(qos: .userInitiated).async {
        let data = try? Data(contentsOf: url)
        if let imageData = data, let image = UIImage(data: imageData) {
          DispatchQueue.main.async {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
          }
        }
      }
    }
  }

  private func uploadComplete(succeed: Bool) {
    spinner.stopAnimating()
    if succeed {
      saveUploadedImage()
      showSuccessAlert()
    }
    else {
      showFailAlert()
    }
  }
}

// MARK: Image Picker Controller Delegate

extension AddPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
    isSelect = false
    picker.dismiss(animated: true, completion: nil)
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    isSelect = true
    picker.dismiss(animated: true, completion: nil)
  }
}
