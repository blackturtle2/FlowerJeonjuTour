//
//  WifiViewController.swift
//  FlowerJeonjuTrip
//
//  Created by leejaesung on 2017. 11. 16..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash
import MapKit

class WifiViewController: UIViewController {

    @IBOutlet weak var mainMKMapView: MKMapView!
    
    var wifiList: [wifiClass] = []
    
    var mapPin: [MKPointAnnotation] = []
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainMKMapView.delegate = self
        
        let location = CLLocation(latitude: 35.824224, longitude: 127.147953)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 5000.0, 5000.0)
        self.mainMKMapView.setRegion(coordinateRegion, animated: true)
        
        self.getShowWifiList()
//        self.mainMKMapView.selectAnnotation(self.mapPin[0], animated: true)
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
    
    // MARK: 와이파이 데이터 가져오기
    func getShowWifiList() {
        let requestUrl = "\(JSsecretKey.wifiAPI_RootDomain)/getWifiList?authApiKey=\(JSsecretKey.cultureAPI_MyKey)&numOfRows=78"
        
        Alamofire.request(requestUrl).response(queue: nil) {[unowned self] (response) in
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
            
            for item in rawData {
                let pin = wifiClass(instplaceNm: item["instplaceNm"].element?.text ?? "",
                                    posX: item["posX"].element?.text,
                                    posY: item["posY"].element?.text)
                self.wifiList.append(pin)
                
                // UI
                DispatchQueue.main.async {
                    self.showMapPinOf(wifiLocation: pin)
                }
            }
        }
        
    }
    
    func showMapPinOf(wifiLocation: wifiClass) {
        guard let posX = wifiLocation.posX else { return }
        guard let posY = wifiLocation.posY else { return }
        let realPosX = Double(posX) ?? 0
        let realPosY = Double(posY) ?? 0
        
        let location = CLLocation(latitude: realPosY, longitude: realPosX)
        let pin = MKPointAnnotation()
        
        pin.title = wifiLocation.instplaceNm
        pin.subtitle = wifiLocation.instplaceNm
        pin.coordinate = location.coordinate
        
        self.mapPin.append(pin)
        self.mainMKMapView.delegate = self
        self.mainMKMapView.addAnnotation(pin)
    }

}

/*******************************************/
//MARK:          extenstion                //
/*******************************************/
extension WifiViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("///// didSelect MKMapView- 6782\n")
    }
}
