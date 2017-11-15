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

class CultureDetailViewController: UIViewController {
    
    @IBOutlet weak var imageViewTitle: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelContent: UILabel!
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
    
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        print("///// sid- 6823: \n", self.sid ?? "no data")
        print("///// fileUrl- 6823: \n", self.fileUrl ?? "no data")
        
        // UI: 타이틀 텍스트
        self.labelTitle.text = self.sTitle ?? ""
        
        // UI: 타이틀 이미지
        self.imageViewTitle.kf.indicatorType = .activity
        self.imageViewTitle.kf.indicator?.startAnimatingView()
        if let realFileUrl = self.fileUrl {
            self.imageViewTitle.kf.setImage(with: URL(string: realFileUrl), placeholder: nil, options: nil, progressBlock: nil, completionHandler: {[unowned self] (image, error, cache, url) in
                self.imageViewTitle.kf.indicator?.stopAnimatingView()
            })
        }
        
        self.getShowCultureView(dataSid: self.sid!)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
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
                
                self.buttonTel.setTitle(realCultureView.tel, for: UIControlState.normal)
                self.buttonHomePage.setTitle(realCultureView.website, for: UIControlState.normal)
                let strAddress = "\(realCultureView.address) \(realCultureView.addressDetail)"
                self.buttonAddress.setTitle(strAddress, for: UIControlState.normal)
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
