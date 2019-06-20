//
//  HomeCollectionViewController.swift
//  TagMe
//
//  Created by Stanimir Hristov on 5/8/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import UIKit

let imagesCache = NSCache<AnyObject, AnyObject>()

class ImageCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var spinner: UIActivityIndicatorView!

  var image: UIImage? {
    get {
      return imageView.image
    }
    set {
      imageView.image = newValue
      spinner.stopAnimating()
    }
  }

  var imageUrl: String? {
    didSet {
      fetchImage()
    }
  }

  private func fetchImage() {
    imageView?.image = nil
    if let cachedImage = imagesCache.object(forKey: imageUrl as AnyObject) as? UIImage {
      self.image = cachedImage
    }
    else if let urlString = imageUrl, let url = URL(string: urlString) {
      spinner.startAnimating()
      DispatchQueue.global(qos: .userInitiated).async { [weak self]  in
        let urlContents = try? Data(contentsOf: url)
        if let imageData = urlContents, let image = UIImage(data: imageData) {
          imagesCache.setObject(image, forKey: url.absoluteString as NSString)
          DispatchQueue.main.async {
            if urlString == self?.imageUrl {
              self?.image = image
            }
          }
        }
      }
    }
  }
}

class HomeCollectionViewController: UICollectionViewController {
  var responses = [TaggedPictureResponse]()

  var imagesResponse = AllImagesResponse()

  var isGettingNextPage = false

  // MARK: View Controller Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.parent?.navigationItem.title = Constants.TITLE

    responses.removeAll()
    let link = URL_BASE + "/api/pictures?size=" + "\(Constants.IMAGES_COUNT)"
    getImages(for: link)
  }
}

// MARK: Constants

extension HomeCollectionViewController {
  struct Constants {
    static let TITLE = "Home"
    static let CELL_IDENTIFIER = "Cell"
    static let SHOW_IMAGE_SEGUE_ID = "ShowImageDetail"
    static let SPACING: CGFloat = 5.0
    static let ITEMS_PER_ROW: CGFloat = 3
    static let IMAGES_COUNT = 21
  }
}

// MARK: UICollectionViewDataSource

extension HomeCollectionViewController {
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return imagesResponse.page.totalElements
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CELL_IDENTIFIER, for: indexPath)
      as! ImageCollectionViewCell

    cell.tag = indexPath.row
    if indexPath.row < responses.count {
      cell.imageUrl = URL_BASE + responses[indexPath.row].pictureUrl;
    }
    else {
      if !isGettingNextPage {
        isGettingNextPage = true
        if let nextLink = imagesResponse.links.next {
          if !nextLink.href.isEmpty {
            getImages(for: nextLink.href)
          }
        }
      }
    }

    return cell
  }
}

// MARK: UICollectionViewDelegateFlowLayout

extension HomeCollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let totalSpacing = (Constants.ITEMS_PER_ROW + 1) * Constants.SPACING
    let width = (collectionView.bounds.width - totalSpacing) / Constants.ITEMS_PER_ROW

    return CGSize(width: width, height: width)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAt section: Int
  ) -> UIEdgeInsets {
    return UIEdgeInsets(
      top: Constants.SPACING,
      left: Constants.SPACING,
      bottom: Constants.SPACING,
      right: Constants.SPACING
    )
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumInteritemSpacingForSectionAt section: Int
  ) -> CGFloat {
    return 0
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int
  ) -> CGFloat {
    return Constants.SPACING
  }
}

// MARK: Navigation

extension HomeCollectionViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Constants.SHOW_IMAGE_SEGUE_ID {
      if let imageDetailVC = segue.destination as? ImageDetailViewController {
        if let cell = sender as? ImageCollectionViewCell {
          imageDetailVC.imageInfo = responses[cell.tag]
          imageDetailVC.image = cell.imageView.image
        }
      }
    }
  }
}

// MARK: Get images

extension HomeCollectionViewController {
  private func getImages(for link: String) {
    RequestCenter.instance.getImages(for: link) { data, response in
      let JSON = try? JSONSerialization.jsonObject(with: data, options: [])
      if let responseJSON = JSON as? [String: Any] {
        DispatchQueue.main.async {
          self.imagesResponse = AllImagesResponse(json: responseJSON)
          for response in self.imagesResponse.embedded.resposes {
            self.responses.append(response)
          }

          self.isGettingNextPage = false
          self.collectionView.reloadData()
        }
      }
    }
  }
}
