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
import SafariServices
import MessageUI

class MainViewController: UIViewController {

    @IBOutlet weak var mainTableView: UITableView!
    
    @IBOutlet weak var imageViewHeaderBackground: UIImageView!
    
    var collectionViewStoredOffsets = [Int: CGFloat]()
    
    var cultureList: [cultureClass] = [] // 관람시설
    var cultureTraditionalList: [cultureClass] = [] // 전통시설
    var cultureCenterList: [cultureClass] = [] // 문화센터
    var cultureLibraryList: [cultureClass] = [] // 도서관
    
    var cultureImageList: [String:cultureImageClass] = [:] // 관람시설
    var cultureTraditionalImageList: [String:cultureImageClass] = [:] // 전통시설
    var cultureCenterImageList: [String:cultureImageClass] = [:] // 문화센터
    var cultureLibraryImageList: [String:cultureImageClass] = [:] // 도서관
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableView Delegate & DataSource
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        
        // UI
        self.imageViewHeaderBackground.layer.cornerRadius = 10
        
        self.getShowCultureList()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    // MARK: 인앱웹뷰(SFSafariView) 열기 function 정의
    // `SafariServices`의 import가 필요합니다.
    func openSafariViewOf(url:String) {
        guard let realURL = URL(string: url) else { return }
        
        // iOS 9부터 지원하는 `SFSafariViewController`를 이용합니다.
        let safariViewController = SFSafariViewController(url: realURL)
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    //MARK: 앱 문의 email 보내기 function 정의
    // [주의] `MessageUI` import 필요
    func sendEmailTo(emailAddress email:String) {
        let userSystemVersion = UIDevice.current.systemVersion // 현재 사용자 iOS 버전
        let userAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String // 현재 사용자 앱 버전
        
        // 메일 쓰는 뷰컨트롤러 선언
        let mailComposeViewController = configuredMailComposeViewController(emailAddress: email, systemVersion: userSystemVersion, appVersion: userAppVersion!)
        
        //사용자의 아이폰에 메일 주소가 세팅되어 있을 경우에만 mailComposeViewController()를 태웁니다.
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } // else일 경우, iOS 에서 자체적으로 메일 주소를 세팅하라는 메시지를 띄웁니다.
    }
    
    // MARK: 메일 보내는 뷰컨트롤러 속성 세팅
    func configuredMailComposeViewController(emailAddress:String, systemVersion:String, appVersion:String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // 메일 보내기 Finish 이후의 액션 정의를 위한 Delegate 초기화.
        
        mailComposerVC.setToRecipients([emailAddress]) // 받는 사람 설정
        mailComposerVC.setSubject("[꽃심전주투어] 사용자로부터 도착한 편지") // 메일 제목 설정
        mailComposerVC.setMessageBody("* iOS Version: \(systemVersion) / App Version: \(appVersion)\n** 고맙습니다. 무엇이 궁금하신가요? :D", isHTML: false) // 메일 내용 설정
        
        return mailComposerVC
    }

    
    // MARK: 내비게이션 바, info 버튼 액션 function
    @IBAction func actionNaviInfoButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "개발자: 까만거북이 - 이재성 (PM & iOS dev)", message: "꽃심전주투어 앱은 아래 전주시의 Open API, Open Data의 도움을 받아 개발되었습니다.\n\n문화공간 정보 서비스 (전라북도 전주시)\n착한가격모범업소 정보 현황 (전라북도 전주시)\n무선인터넷존 위치정보 서비스 (전라북도 전주시)\n화장실 정보 서비스 (전라북도 전주시)\n전주음식 정보 서비스 (전라북도 전주시)\n\n공공데이터포털 - https://www.data.go.kr\n전주시 공공데이터 커뮤니티 센터 - http://openapi.jeonju.go.kr\n전주시청 - http://www.jeonju.go.kr\n한바탕전주 - http://tour.jeonju.go.kr", preferredStyle: .actionSheet)
        let blogButton = UIAlertAction(title: "Blog", style: .default, handler: {[unowned self] (action) in
            self.openSafariViewOf(url: "http://blackturtle2.net")
        })
        let githubButton = UIAlertAction(title: "GitHub", style: .default, handler: {[unowned self] (action) in
            self.openSafariViewOf(url: "https://github.com/blackturtle2")
        })
        let mailButton = UIAlertAction(title: "E-mail", style: .destructive, handler: {[unowned self] (action) in
            self.sendEmailTo(emailAddress: "blackturtle2@gmail.com")
        })
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(blogButton)
        alert.addAction(githubButton)
        alert.addAction(mailButton)
        alert.addAction(cancelButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: API 일일트래픽 제한에 해단될 때의 Alert function
    func limitedNumberOfServiceReqAlert() {
        let alertController = UIAlertController(title: "알림", message: "공공 API의 일일 트래픽 제한이 발생했습니다.\n\n문제가 지속될 경우\n개발자에게 문의 부탁드립니다.\nblackturtle2@gmail.com", preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: 문화공간 데이터 가져오기
    func getShowCultureList() {
        // API: culture 문화공간 정보 서비스 Cultural Space Information Services
        // https://goo.gl/kT7UD8
        // http://openapi.jeonju.go.kr/rest/culture/getCultureList?authApiKey=인증키&dataValue=%EC%A0%95%EC%9D%8D%EA%B3%A0%ED%83%9D
        let cultureReqUrl = "\(JSsecretKey.cultureAPI_RootDomain)/getCultureList?authApiKey=\(JSsecretKey.cultureAPI_MyKey)&pageSize=50"
        
        Alamofire.request(cultureReqUrl).response(queue: nil) {[unowned self] (response) in
            guard let realData = response.data else { return }
            let xml = SWXMLHash.parse(realData)
            print("///// xml- 5123: \n", xml)
            
            if let alert = xml["rfcOpenApi"]["header"]["resultCode"].element?.text {
                if alert == "22" {
                    self.limitedNumberOfServiceReqAlert()
                    return
                }
            }
            
            let rawData = xml["rfcOpenApi"]["body"]["data"]["list"].all
            print("///// rawData- 5523: \n", rawData)
            
            // 관람시설, 전통시설, 문화센터, 도서관
            var cultureNumber = 0
            var cultureTraditionalNumber = 0
            var cultureCenterNumber = 0
            var cultureLibraryNumber = 0
            for item in rawData {
                if item["typeCode"].element?.text == "관람시설" {
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
                                                         number: cultureNumber))
                    cultureNumber += 1
                }else if item["typeCode"].element?.text == "전통시설" {
                    self.cultureTraditionalList.append(cultureClass(sid: item["dataSid"].element?.text ?? "",
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
                                                         number: cultureTraditionalNumber))
                    cultureTraditionalNumber += 1
                }else if item["typeCode"].element?.text == "문화센터" {
                    self.cultureCenterList.append(cultureClass(sid: item["dataSid"].element?.text ?? "",
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
                                                         number: cultureCenterNumber))
                    cultureCenterNumber += 1
                }else if item["typeCode"].element?.text == "도서관" {
                    self.cultureLibraryList.append(cultureClass(sid: item["dataSid"].element?.text ?? "",
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
                                                         number: cultureLibraryNumber))
                    cultureLibraryNumber += 1
                }
            }
            
            // 싱글턴 데이터로 저장하기
            DataCenter.shared.cultureList = self.cultureList
            DataCenter.shared.cultureTraditionlList = self.cultureTraditionalList
            DataCenter.shared.cultureCenterList = self.cultureCenterList
            DataCenter.shared.cultureLibraryList = self.cultureLibraryList
            
            // UI
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
            }
            
            // 이미지 가져오기
            for item in self.cultureList { // 관람시설
                self.getShowImageOfCultureListOf(typeCode: .culture, dataSid: self.cultureList[item.number].sid, number: item.number)
            }
            for item in self.cultureTraditionalList { // 전통시설
                self.getShowImageOfCultureListOf(typeCode: .traditional, dataSid: self.cultureTraditionalList[item.number].sid, number: item.number)
            }
//            이미지 API의 트래픽 문제가 지속적으로 발생하여, 문화센터와 도서관 제거
//            for item in self.cultureCenterList { // 문화센터
//                self.getShowImageOfCultureListOf(typeCode: .center, dataSid: self.cultureCenterList[item.number].sid, number: item.number)
//            }
//            for item in self.cultureLibraryList { // 도서관
//                self.getShowImageOfCultureListOf(typeCode: .library, dataSid: self.cultureLibraryList[item.number].sid, number: item.number)
//            }
            
        }
        
    }
    
    enum enumTypeCode {
        case culture
        case traditional
        case center
        case library
    }
    
    
    // MARK: 문화공간 이미지 데이터 가져오기
    // 문화공간의 이미지를 가져오고, collectionView의 item들을 reload해서 이미지를 출력한다.
    func getShowImageOfCultureListOf(typeCode: enumTypeCode, dataSid: String, number: Int) {
        // http://openapi.jeonju.go.kr/rest/culture/getCultureFile?authApiKey=인증키&dataSid=129700
        let cultureReqUrl = "\(JSsecretKey.cultureAPI_RootDomain)/getCultureFile?authApiKey=\(JSsecretKey.cultureAPI_MyKey)&dataSid=\(dataSid)"
        
        Alamofire.request(cultureReqUrl).response(queue: nil) {[unowned self] (response) in
            guard let realData = response.data else { return }
            let xml = SWXMLHash.parse(realData)
            print("///// xml- 6234: \n", xml)
            
            if let alert = xml["rfcOpenApi"]["header"]["resultCode"].element?.text {
                if alert == "22" {
                    self.limitedNumberOfServiceReqAlert()
                    return
                }
            }
            
            let rawData = xml["rfcOpenApi"]["body"]["data"]["list"].all
            print("///// rawData- 6234: \n", rawData)
            
            switch typeCode {
            case .culture:
                self.cultureImageList[dataSid] = cultureImageClass(dataSid: dataSid,
                                                                   fileUrl: rawData[0]["fileUrl"].element?.text ?? "",
                                                                   thumbUrl: rawData[0]["thumbUrl"].element?.text ?? "") // 이미지 목록이 수신되므로 첫번째 이미지를 대표 이미지로 명명한다. rawData[0]
            case .traditional:
                self.cultureTraditionalImageList[dataSid] = cultureImageClass(dataSid: dataSid,
                                                                   fileUrl: rawData[0]["fileUrl"].element?.text ?? "",
                                                                   thumbUrl: rawData[0]["thumbUrl"].element?.text ?? "")
            case .center:
                self.cultureCenterImageList[dataSid] = cultureImageClass(dataSid: dataSid,
                                                                   fileUrl: rawData[0]["fileUrl"].element?.text ?? "",
                                                                   thumbUrl: rawData[0]["thumbUrl"].element?.text ?? "")
            case .library:
                self.cultureLibraryImageList[dataSid] = cultureImageClass(dataSid: dataSid,
                                                                   fileUrl: rawData[0]["fileUrl"].element?.text ?? "",
                                                                   thumbUrl: rawData[0]["thumbUrl"].element?.text ?? "")
            }
            
            // UI
            DispatchQueue.main.async {
                switch typeCode {
                case .culture:
                    if let cell = self.mainTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? MainTableViewCell {
                        cell.collectionView.reloadItems(at: [IndexPath(row: number, section: 0)])
                    }
                case .traditional:
                    if let cell = self.mainTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? MainTableViewCell {
                        cell.collectionView.reloadItems(at: [IndexPath(row: number, section: 0)])
                    }
                case .center:
                    if let cell = self.mainTableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? MainTableViewCell {
                        cell.collectionView.reloadItems(at: [IndexPath(row: number, section: 0)])
                    }
                case .library:
                    if let cell = self.mainTableView.cellForRow(at: IndexPath(row: 0, section: 3)) as? MainTableViewCell {
                        cell.collectionView.reloadItems(at: [IndexPath(row: number, section: 0)])
                    }
                }
                
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
        return 2 // 이미지 API의 트래픽 문제가 지속적으로 발생하여, 문화센터와 도서관 제거
    }
    
    // tableView: Section 헤더 타이틀
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "관람시설"
        case 1:
            return "전통시설"
        case 2:
            return "문화센터"
        case 3:
            return "도서관"
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
        switch collectionView.tag {
        case 0:
            return self.cultureList.count
        case 1:
            return self.cultureTraditionalList.count
        case 2:
            return self.cultureCenterList.count
        case 3:
            return self.cultureLibraryList.count
        default:
            return 0
        }
    }
    
    // UICollectionView: cellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let resultCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as! MainCollectionViewCell
        resultCell.imageViewMain.layer.cornerRadius = 8
        resultCell.viewImageBlur.layer.cornerRadius = 8
        
        resultCell.imageViewMain.kf.indicatorType = .activity
        resultCell.imageViewMain.kf.indicator?.startAnimatingView()
        
        switch collectionView.tag { //section
        case 0: // 관람시설 section
            let realSid = self.cultureList[indexPath.row].sid
            resultCell.sid = realSid
            resultCell.labelTitleText.text = self.cultureList[indexPath.row].title
            resultCell.sTitle = self.cultureList[indexPath.row].title
            
            let currentCultureImageList = self.cultureImageList[realSid]
            guard let realFileUrl = currentCultureImageList?.fileUrl else { return resultCell }
            guard let realThumbUrl = currentCultureImageList?.thumbUrl else { return resultCell }
            resultCell.fileUrl = realFileUrl
            
            resultCell.imageViewMain.kf.setImage(with: URL(string: realThumbUrl), placeholder: nil, options: nil, progressBlock: nil) { (image, error, cache, url) in
                DispatchQueue.main.async {
                    resultCell.imageViewMain.kf.setImage(with: URL(string: realFileUrl), placeholder: image)
                    resultCell.imageViewMain.kf.indicator?.stopAnimatingView()
                }
            }
            
            return resultCell
        case 1: // 전통시설 section
            let realSid = self.cultureTraditionalList[indexPath.row].sid
            resultCell.sid = realSid
            resultCell.labelTitleText.text = self.cultureTraditionalList[indexPath.row].title
            resultCell.sTitle = self.cultureTraditionalList[indexPath.row].title
            
            let currentImageList = self.cultureTraditionalImageList[realSid]
            guard let realFileUrl = currentImageList?.fileUrl else { return resultCell }
            guard let realThumbUrl = currentImageList?.thumbUrl else { return resultCell }
            resultCell.fileUrl = realFileUrl
            
            resultCell.imageViewMain.kf.setImage(with: URL(string: realThumbUrl), placeholder: nil, options: nil, progressBlock: nil) { (image, error, cache, url) in
                DispatchQueue.main.async {
                    resultCell.imageViewMain.kf.setImage(with: URL(string: realFileUrl), placeholder: image)
                    resultCell.imageViewMain.kf.indicator?.stopAnimatingView()
                }
            }
            
            return resultCell
        case 2: // 문화센터 section
            let realSid = self.cultureCenterList[indexPath.row].sid
            resultCell.sid = realSid
            resultCell.labelTitleText.text = self.cultureCenterList[indexPath.row].title
            resultCell.sTitle = self.cultureCenterList[indexPath.row].title
            
            let currentImageList = self.cultureCenterImageList[realSid]
            guard let realFileUrl = currentImageList?.fileUrl else { return resultCell }
            guard let realThumbUrl = currentImageList?.thumbUrl else { return resultCell }
            resultCell.fileUrl = realFileUrl
            
            resultCell.imageViewMain.kf.setImage(with: URL(string: realThumbUrl), placeholder: nil, options: nil, progressBlock: nil) { (image, error, cache, url) in
                DispatchQueue.main.async {
                    resultCell.imageViewMain.kf.setImage(with: URL(string: realFileUrl), placeholder: image)
                    resultCell.imageViewMain.kf.indicator?.stopAnimatingView()
                }
            }
            
            return resultCell
        case 3: // 도서관 section
            let realSid = self.cultureLibraryList[indexPath.row].sid
            resultCell.sid = realSid
            resultCell.labelTitleText.text = self.cultureLibraryList[indexPath.row].title
            resultCell.sTitle = self.cultureLibraryList[indexPath.row].title
            
            let currentImageList = self.cultureLibraryImageList[realSid]
            guard let realFileUrl = currentImageList?.fileUrl else { return resultCell }
            guard let realThumbUrl = currentImageList?.thumbUrl else { return resultCell }
            resultCell.fileUrl = realFileUrl
            
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
        
        let cell = collectionView.cellForItem(at: indexPath) as! MainCollectionViewCell
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "CultureDetailViewController") as! CultureDetailViewController
        nextVC.sid = cell.sid
        nextVC.sTitle = cell.sTitle
        nextVC.fileUrl = cell.fileUrl
        
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}


// MARK: Extension - MFMailComposeViewControllerDelegate
extension MainViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
