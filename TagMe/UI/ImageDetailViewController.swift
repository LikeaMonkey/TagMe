//
//  ImageDetailViewController.swift
//  TagMe
//
//  Created by Stanimir Hristov on 5/9/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import UIKit

class ProviderResultTableViewCell: UITableViewCell {
  @IBOutlet weak var providerLabel: UILabel!
  @IBOutlet weak var tagsLabel: UILabel!
}

class ImageDetailViewController: UIViewController {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var resultLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var similarImagesCollectionView: UICollectionView!

  var imageInfo = TaggedPictureResponse()
  var image: UIImage?

  var similarImageResponses = [TaggedPictureResponse]()

  var imagesResponse = AllImagesResponse()

  var isGettingNextPage = false

  //MARK: View Controller Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.title = Constants.TITLE
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    imageView.image = image

    var tags = ""
    for response in imageInfo.result {
      for tag in response.tags {
        tags += tag.tag
        tags += ","
      }
    }
    _ = tags.popLast()

    var link = URL_BASE + "/api/pictures?tags=" + tags + "&size=20"
    link = link.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? link
    getImages(for: link)
  }
}

// MARK: Constants

extension ImageDetailViewController {
  struct Constants {
    static let TITLE = "Image Results"
    static let CELL_ID = "Cell_Id"
    static let COLLECTION_CELL_ID = "SimilarCell"
  }
}

//MARK: Table View Data Source, Table View Delegate

extension ImageDetailViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return imageInfo.result.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CELL_ID, for: indexPath)
      as! ProviderResultTableViewCell

    let result = imageInfo.result[indexPath.row]
    cell.providerLabel.text = "Provided by \(result.pictureTagsProviderName)"
    cell.tagsLabel.text = ""
    cell.tagsLabel.numberOfLines = 0
    for tag in result.tags {
      let text = cell.tagsLabel.text ?? ""
      cell.tagsLabel.text = text + "Tag: \(tag.tag) - confidence \(tag.confidence)%\n"
    }

    return cell
  }
}

// MARK: UICollectionViewDataSource

extension ImageDetailViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return imagesResponse.page.totalElements
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.COLLECTION_CELL_ID, for: indexPath)
      as! ImageCollectionViewCell

    cell.tag = indexPath.row
    if indexPath.row < similarImageResponses.count {
      cell.imageUrl = URL_BASE + similarImageResponses[indexPath.row].pictureUrl;
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

// MARK: Get images

extension ImageDetailViewController {
  private func getImages(for link: String) {
    RequestCenter.instance.getImages(for: link) { data, response in
      let JSON = try? JSONSerialization.jsonObject(with: data, options: [])
      if let responseJSON = JSON as? [String: Any] {
        DispatchQueue.main.async {
          self.imagesResponse = AllImagesResponse(json: responseJSON)
          for response in self.imagesResponse.embedded.resposes {
            self.similarImageResponses.append(response)
          }

          self.isGettingNextPage = false
          self.similarImagesCollectionView.reloadData()
        }
      }
    }
  }
}
