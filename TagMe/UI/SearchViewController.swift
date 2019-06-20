//
//  HomeTableViewController.swift
//  TagMe
//
//  Created by Stanimir Hristov on 5/1/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var resultsCollectionView: UICollectionView!
  @IBOutlet weak var confidenceLabel: UILabel!

  @IBOutlet weak var confidenceStepper: UIStepper! {
    didSet {
      confidenceStepper.addTarget(
        self,
        action: #selector(stepperValueChanged),
        for: .valueChanged
      )
    }
  }

  var responses = [TaggedPictureResponse]()

  var imagesResponse = AllImagesResponse()

  var isGettingNextPage = false

  //MARK: View Controller Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.parent?.navigationItem.title = Constants.TITLE
  }
}

// MARK: Constants

extension SearchViewController {
  private enum Constants {
    static let TITLE = "Search"
    static let CELL_IDENTIFIER = "CellID"
    static let FRACTION_FORMAT = "%.1f"
    static let SPACING: CGFloat = 5.0
    static let ITEMS_PER_ROW: CGFloat = 3
    static let IMAGES_COUNT = 21
  }
}

//MARK: Navigation

extension SearchViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowSearchDetail" {
      if let destionation = segue.destination as? ImageDetailViewController {
        if let cell = sender as? ImageCollectionViewCell {
          destionation.imageInfo = responses[cell.tag]
          destionation.image = cell.imageView.image
        }
      }
    }
  }
}

// MARK: UICollectionViewDataSource

extension SearchViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)
    -> Int
  {
    return imagesResponse.page.totalElements
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: Constants.CELL_IDENTIFIER,
      for: indexPath
    ) as! ImageCollectionViewCell

    cell.tag = indexPath.row
    if indexPath.row < responses.count {
      cell.imageUrl = URL_BASE + responses[indexPath.row].pictureUrl
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

extension SearchViewController: UICollectionViewDelegateFlowLayout {
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

//MARK: Search Bar Delegate

extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }

  func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
    return true
  }

  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    if let tags = searchBar.text, !tags.isEmpty {
      responses.removeAll()
      var tagsForSearch = ""
      for tag in tags.getWords() {
        tagsForSearch += tag + ","
      }
      _ = tagsForSearch.popLast()

      if let confidence = confidenceLabel.text {
        let link = URL_BASE + "/api/pictures?tags=\(tagsForSearch)&confidence="
          + confidence + "&size=" + "\(Constants.IMAGES_COUNT)"
        getImages(for: link)
      }
    }
  }
}

// MARK: Get images

extension SearchViewController {
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
          self.resultsCollectionView.reloadData()
        }
      }
    }
  }
}

//MARK: Stepper Handle

extension SearchViewController {
  @objc private func stepperValueChanged() {
    confidenceLabel.text = String(format: Constants.FRACTION_FORMAT, confidenceStepper.value)
  }
}
