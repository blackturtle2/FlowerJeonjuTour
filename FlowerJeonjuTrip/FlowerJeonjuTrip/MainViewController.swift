//
//  ViewController.swift
//  FlowerJeonjuTrip
//
//  Created by leejaesung on 2017. 11. 13..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import SWXMLHash

class MainViewController: UIViewController {

    @IBOutlet weak var mainTableView: UITableView!
    
    var collectionViewStoredOffsets = [Int: CGFloat]()
    
    var cultureList: [cultureClass] = []
    var cultureImageList: [String:cultureImageClass] = [:]
    
    var testImage: String?
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableView Delegate & DataSource
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        
        self.getShowCultureList()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    
    // MARK: 문화공간 데이터 가져오기
    func getShowCultureList() {
        // API: culture 문화공간 정보 서비스 Cultural Space Information Services
        // https://goo.gl/kT7UD8
        // http://openapi.jeonju.go.kr/rest/culture/getCultureList?authApiKey=인증키&dataValue=%EC%A0%95%EC%9D%8D%EA%B3%A0%ED%83%9D
        let cultureReqUrl = "\(JSsecretKey.cultureAPI_RootDomain)/getCultureList?authApiKey=\(JSsecretKey.cultureAPI_MyKey)"
        
        Alamofire.request(cultureReqUrl).response(queue: nil) {[unowned self] (response) in
            guard let realData = response.data else { return }
            let xml = SWXMLHash.parse(realData)
            print("///// xml- 5123: \n", xml)
            
            let rawData = xml["rfcOpenApi"]["body"]["data"]["list"].all
            print("///// rawData- 5523: \n", rawData)
            
            var number = 0
            for item in rawData {
                self.cultureList.append(cultureClass(sid: item["dataSid"].element?.text ?? "",
                                               title: item["dataTitle"].element?.text ?? "",
                                               content: item["dataContent"].element?.text ?? "",
                                               introContent: item["introContent"].element?.text ?? "",
                                               tel: item["tel"].element?.text ?? "",
                                               website: item["userHomepage"].element?.text ?? "",
                                               typeCode: item["typeCode"].element?.text ?? "",
                                               address: item["addr"].element?.text ?? "",
                                               addressDetail: item["addrDtl"].element?.text ?? "",
                                               createdDate: item["regDt"].element?.text ?? "",
                                               posX: item["posx"].element?.text ?? "",
                                               posY: item["posy"].element?.text ?? "",
                                               number: number))
                number += 1
            }
            
            // 싱글턴 데이터로 저장하기
            DataCenter.shared.cultureList = self.cultureList
            print("///// cultureList- 6582: \n", DataCenter.shared.cultureList ?? "no data")
            
            // UI
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
            }
            
            // 이미지 가져오기
            for item in self.cultureList {
                self.getShowImageOfCultureListOf(dataSid: self.cultureList[item.number].sid, number: item.number)
            }
            
        }
        
    }
    
    // MARK: 문화공간 이미지 데이터 가져오기
    // 문화공간의 이미지를 가져오고, collectionView의 item들을 reload해서 이미지를 출력한다.
    func getShowImageOfCultureListOf(dataSid: String, number: Int) {
        // http://openapi.jeonju.go.kr/rest/culture/getCultureFile?authApiKey=인증키&dataSid=129700
        let cultureReqUrl = "\(JSsecretKey.cultureAPI_RootDomain)/getCultureFile?authApiKey=\(JSsecretKey.cultureAPI_MyKey)&dataSid=\(dataSid)"
        
        Alamofire.request(cultureReqUrl).response(queue: nil) {[unowned self] (response) in
            guard let realData = response.data else { return }
            let xml = SWXMLHash.parse(realData)
            print("///// xml- 6234: \n", xml)
            
            let rawData = xml["rfcOpenApi"]["body"]["data"]["list"].all
            print("///// rawData- 6234: \n", rawData)
            
            self.cultureImageList[dataSid] = cultureImageClass(dataSid: dataSid,
                                                               fileUrl: rawData[0]["fileUrl"].element?.text,
                                                               thumbUrl: rawData[0]["thumbUrl"].element?.text) // 이미지 목록이 수신되므로 첫번째 이미지를 대표 이미지로 명명한다. rawData[0]
            
            // UI
            DispatchQueue.main.async {
                let cell = self.mainTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! MainTableViewCell
                cell.collectionView.reloadItems(at: [IndexPath(row: number, section: 0)])
            }
        }
    }
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
        let resultCell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
        return resultCell
    }
    
    // tableView: willDisplay
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? MainTableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forSection: indexPath.section)
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
        return self.cultureList.count
    }
    
    // UICollectionView: cellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let resultCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as! MainCollectionViewCell
        resultCell.imageViewMain.layer.cornerRadius = 8
        resultCell.viewImageBlur.layer.cornerRadius = 8
        
        switch collectionView.tag { //section
        case 0: // 투어 뱃지 section
            return resultCell
        case 1: // 문화 공간 section
            let realSid = self.cultureList[indexPath.row].sid
            resultCell.sid = realSid
            resultCell.labelTitleText.text = self.cultureList[indexPath.row].title
            
            let currentCultureImageList = self.cultureImageList[realSid]
            guard let realFileUrl = currentCultureImageList?.fileUrl else { return resultCell }
            guard let realThumbUrl = currentCultureImageList?.thumbUrl else { return resultCell }
            resultCell.imageViewMain.kf.indicatorType = .activity
            resultCell.imageViewMain.kf.indicator?.startAnimatingView()
            
            resultCell.imageViewMain.kf.setImage(with: URL(string: realThumbUrl), placeholder: nil, options: nil, progressBlock: nil) { (image, error, cache, url) in
                DispatchQueue.main.async {
                    resultCell.imageViewMain.kf.setImage(with: URL(string: realFileUrl), placeholder: image)
                    resultCell.imageViewMain.kf.indicator?.stopAnimatingView()
                }
            }
            
            return resultCell
        default:
            return resultCell
        }

    }
    
    // UICollectionView: didSelectItemAt
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection view at section \(collectionView.tag) selected index path \(indexPath)")
    }
}
