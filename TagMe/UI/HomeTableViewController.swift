//
//  HomeTableViewController.swift
//  TagMe
//
//  Created by Stanimir Hristov on 5/1/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.parent?.navigationItem.title = "Home"
    }
    
    //MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "#" + "Tag"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CollectionCellId, for: indexPath) as! CategoryCell
        
        return cell
    }
}

extension HomeTableViewController {
    private struct Constants {
        static let CollectionCellId = "CellId"
    }
}

//MARK: HomeTableViewCell

class CategoryCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource
{
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    //MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCellId", for: indexPath) as! ImageCollectionViewCell
        
        cell.imageView.image = UIImage(named: "home")
        
        return cell
    }
}

//MARK: ImageCollectionViewCell
//
//class ImageCollectionViewCell: UICollectionViewCell
//{
//    @IBOutlet weak var imageView: UIImageView!
//}
