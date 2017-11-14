//
//  ViewController.swift
//  FlowerJeonjuTrip
//
//  Created by leejaesung on 2017. 11. 13..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash

class MainViewController: UIViewController {

    @IBOutlet weak var mainTableView: UITableView!
    
    var collectionViewStoredOffsets = [Int: CGFloat]()
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableView Delegate & DataSource
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        
        // UI Setting
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        // API: culture 문화공간 정보 서비스 Cultural Space Information Services
        // https://goo.gl/kT7UD8
        // http://openapi.jeonju.go.kr/rest/culture/getCultureList?authApiKey=인증키&dataValue=%EC%A0%95%EC%9D%8D%EA%B3%A0%ED%83%9D
        let cultureReqUrl = "\(JSsecretKey.cultureAPI_RootDomain)/getCultureList?authApiKey=\(JSsecretKey.cultureAPI_MyKey)"
        
        Alamofire.request(cultureReqUrl).response(queue: nil) {[unowned self] (response) in
            let data = response.data
            guard let realData = data else { return }
            let xml = SWXMLHash.parse(realData)
            print("///// xml- 5123: \n", xml)
            
            let rawData = xml["rfcOpenApi"]["body"]["data"]["list"].all
            print("///// rawData- 5523: \n", rawData)
            
            
//            DataCenter.shared.cultureList = xml.description
            
            // UI
//            DispatchQueue.main.async {
//                self.tableViewMain.reloadData()
//            }
            
        }
        
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
