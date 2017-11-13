//
//  ViewController.swift
//  FlowerJeonjuTrip
//
//  Created by leejaesung on 2017. 11. 13..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var tableViewMain: UITableView!
    
    var collectionViewStoredOffsets = [Int: CGFloat]()
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableViewMain.delegate = self
        self.tableViewMain.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    
}


/*******************************************/
//MARK:          extenstion                //
/*******************************************/
// MARK: UITableViewDelegate, UITableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    // tableView: Section 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // tableView: Section 헤더 타이틀
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "투어 뱃지"
        case 1:
            return "문화 공간"
        default:
            return nil
        }
    }
    
    // tableView: row 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // tableView: cell 그리기
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resultCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return resultCell
    }
    
    // tableView: willDisplay
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? MainTableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        tableViewCell.collectionViewOffset = collectionViewStoredOffsets[indexPath.row] ?? 0
    }
    
    // tableView: didEndDisplaying
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? MainTableViewCell else { return }
        collectionViewStoredOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // UICollectionView: numberOfItemsInSection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    // UICollectionView: cellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as! MainCollectionViewCell
        cell.imageViewMain.layer.cornerRadius = 8
        cell.viewImageBlur.layer.cornerRadius = 8
        
        return cell
    }
    
    // UICollectionView: didSelectItemAt
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
    }
}
