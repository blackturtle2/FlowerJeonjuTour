//
//  WifiViewController.swift
//  FlowerJeonjuTrip
//
//  Created by leejaesung on 2017. 11. 16..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import MapKit

class WifiViewController: UIViewController {

    @IBOutlet weak var mainMKMapView: MKMapView!
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainMKMapView.delegate = self
        
        let location = CLLocation(latitude: 35.824224, longitude: 127.147953)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 5000.0, 5000.0)
        self.mainMKMapView.setRegion(coordinateRegion, animated: true)
        
//        self.mainMKMapView.selectAnnotation(self.mapPin[0], animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    
}

/*******************************************/
//MARK:          extenstion                //
/*******************************************/
extension WifiViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("///// didSelect MKMapView- 6782\n")
    }
}
