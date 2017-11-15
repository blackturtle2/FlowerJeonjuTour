//
//  CultureDetailViewController.swift
//  FlowerJeonjuTrip
//
//  Created by leejaesung on 2017. 11. 14..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import SWXMLHash
import ActiveLabel

class CultureDetailViewController: UIViewController {
    
    @IBOutlet weak var imageViewTitle: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelContent: ActiveLabel!
    @IBOutlet weak var buttonAddress: UIButton!
    @IBOutlet weak var buttonTel: UIButton!
    @IBOutlet weak var buttonHomePage: UIButton!
    @IBOutlet weak var collectionViewImageList: UICollectionView!
    @IBOutlet weak var imageViewTourBadge: UIImageView!
    @IBOutlet weak var buttonGetTourBadge: UIButton!
    
    var sid: String?
    var sTitle: String?
    var fileUrl: String?
    
    var cultureView: cultureClass?
    var cultureImageData: [cultureImageClass]?
    
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        print("///// sid- 6823: \n", self.sid ?? "no data")
        print("///// fileUrl- 6823: \n", self.fileUrl ?? "no data")
        
        // CollectionView Delegate & DataSource
        self.collectionViewImageList.delegate = self
        self.collectionViewImageList.dataSource = self
        
        // UI: 타이틀 텍스트
        self.labelTitle.text = self.sTitle ?? ""
        
        // UI: ActiveLabel
        self.labelContent.numberOfLines = 0
        self.labelContent.lineSpacing = 4
        self.labelContent.textColor = UIColor(red: 38.0/255.0, green: 38.0/255.0, blue: 38.0/255.0, alpha: 1.0)
        
        // UI: buttonGetTourBadge cornerRadius
        self.buttonGetTourBadge.layer.cornerRadius = 27.5
        
        // UI: 타이틀 이미지
        self.imageViewTitle.kf.indicatorType = .activity
        self.imageViewTitle.kf.indicator?.startAnimatingView()
        if let realFileUrl = self.fileUrl {
            self.imageViewTitle.kf.setImage(with: URL(string: realFileUrl), placeholder: nil, options: nil, progressBlock: nil, completionHandler: {[unowned self] (image, error, cache, url) in
                self.imageViewTitle.kf.indicator?.stopAnimatingView()
            })
        }
        
        // 데이터 가져오기
        guard let realSid = self.sid else { return }
        self.getShowCultureView(dataSid: realSid)
        self.getShowImageOfCultureListOf(dataSid: realSid)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    // MARK: API 일일트래픽 제한에 해단될 때의 Alert function
    func limitedNumberOfServiceReqAlert() {
        let alertController = UIAlertController(title: "알림", message: "공공 API의 일일 트래픽 제한이 발생했습니다.\n\n문제가 지속될 경우\n개발자에게 문의 부탁드립니다.\nblackturtle2@gmail.com", preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: 데이터 가져오기
    func getShowCultureView(dataSid: String) {
        // API: culture 문화공간 정보 서비스 Cultural Space Information Services
        // https://goo.gl/kT7UD8
        // http://openapi.jeonju.go.kr/rest/culture/getCultureView?authApiKey=인증키&dataSid=129700
        let cultureReqUrl = "\(JSsecretKey.cultureAPI_RootDomain)/getCultureView?authApiKey=\(JSsecretKey.cultureAPI_MyKey)&dataSid=\(dataSid)"
        
        Alamofire.request(cultureReqUrl).response(queue: nil) {[unowned self] (response) in
            guard let realData = response.data else { return }
            let xml = SWXMLHash.parse(realData)
            print("///// xml- 5123: \n", xml)
            
            let rawData = xml["rfcOpenApi"]["body"]["data"]["list"].all
            print("///// rawData- 5523: \n", rawData)
            
            for item in rawData {
                self.cultureView = cultureClass(sid: item["dataSid"].element?.text ?? "",
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
                                                     number: 0)
            }
            
            // UI
            DispatchQueue.main.async {
                guard let realCultureView = self.cultureView else { return }
                
                // 소개글
                if realCultureView.introContent == "" {
                    self.labelContent.text = realCultureView.content
                }else {
                    self.labelContent.text = realCultureView.introContent
                }
                
                // 주소 버튼
                let strAddress = "\(realCultureView.address) \(realCultureView.addressDetail)"
                self.buttonAddress.setTitle(strAddress, for: UIControlState.normal)
                
                // 전화번호 버튼
                self.buttonTel.setTitle(realCultureView.tel, for: UIControlState.normal)
                
                // 홈페이지 버튼
                self.buttonHomePage.setTitle(realCultureView.website, for: UIControlState.normal)
            }
        }
        
        
    }

    // MARK: 이미지 데이터 가져오기
    func getShowImageOfCultureListOf(dataSid: String) {
        // http://openapi.jeonju.go.kr/rest/culture/getCultureFile?authApiKey=인증키&dataSid=129700
        let cultureReqUrl = "\(JSsecretKey.cultureAPI_RootDomain)/getCultureFile?authApiKey=\(JSsecretKey.cultureAPI_MyKey)&dataSid=\(dataSid)"
        
        Alamofire.request(cultureReqUrl).response(queue: nil) {[unowned self] (response) in
            guard let realData = response.data else { return }
            let xml = SWXMLHash.parse(realData)
            print("///// xml- 7365: \n", xml)
            
            if let alert = xml["rfcOpenApi"]["header"]["resultCode"].element?.text {
                if alert == "22" {
                    self.limitedNumberOfServiceReqAlert()
                    return
                }
            }
            
            let rawData = xml["rfcOpenApi"]["body"]["data"]["list"].all
            print("///// rawData- 7365: \n", rawData)
            
            var myData: [cultureImageClass] = []
            for item in rawData {
                myData.append(cultureImageClass(dataSid: dataSid,
                                                fileUrl: item["fileUrl"].element?.text,
                                                thumbUrl: item["thumbUrl"].element?.text))
            }
            self.cultureImageData = myData
            
            // UI
            DispatchQueue.main.async {
                self.collectionViewImageList.reloadData()
            }
        }
    }

    
    @IBAction func actionButtonAddress(_ sender: UIButton) {
    }
    
    @IBAction func actionButtonTel(_ sender: UIButton) {
    }
    
    @IBAction func actionButtonHomePage(_ sender: UIButton) {
    }
    
    @IBAction func actionButtonGetTourBadge(_ sender: UIButton) {
    }

}


/*******************************************/
//MARK:          extenstion                //
/*******************************************/
// MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension CultureDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cultureImageData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let resultCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CultureDetailCollectionViewCell", for: indexPath) as! CultureDetailCollectionViewCell
        resultCell.imageViewCell.kf.indicatorType = .activity
        resultCell.imageViewCell.kf.indicator?.startAnimatingView()
        
        guard let realCultureImageData = self.cultureImageData else { return resultCell }
        guard let realThumbUrl = realCultureImageData[indexPath.row].thumbUrl else { return resultCell }
        guard let realFileUrl = realCultureImageData[indexPath.row].fileUrl else { return resultCell }
        resultCell.imageViewCell.kf.setImage(with: URL(string: realThumbUrl), placeholder: nil, options: nil, progressBlock: nil) { (image, error, cache, url) in
            DispatchQueue.main.async {
                resultCell.imageViewCell.kf.setImage(with: URL(string: realFileUrl), placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cache, url) in
                    resultCell.imageViewCell.kf.indicator?.stopAnimatingView()
                })
            }
        }
        
        return resultCell
    }
    
    
}
