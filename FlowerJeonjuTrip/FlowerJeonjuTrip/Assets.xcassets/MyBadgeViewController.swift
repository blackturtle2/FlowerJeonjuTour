//
//  MyBadgeViewController.swift
//  FlowerJeonjuTrip
//
//  Created by leejaesung on 2017. 11. 16..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Kingfisher
import Toaster

class MyBadgeViewController: UIViewController {

    @IBOutlet weak var labelNoBadge: UILabel!
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    var myBadgeData: [[String:String]]?
    
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // collectionView Delegate & DataSource
        self.mainCollectionView.delegate = self
        self.mainCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.array(forKey: "myBadge") == nil {
            print("///// myBadge is nil")
            return
        }else {
            self.labelNoBadge.isHidden = true
            
            self.myBadgeData = UserDefaults.standard.array(forKey: "myBadge") as? [[String : String]]
            self.mainCollectionView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    // MARK: 마이 뱃지 초기화 버튼 액션 function
    @IBAction func actionNaviTrashButton(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "투어 뱃지 초기화", message: "투어 뱃지를 초기화하시겠습니까?", preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "초기화", style: .destructive) { (action) in
            UserDefaults.standard.removeObject(forKey: "myBadge")
            
            self.viewWillAppear(true)
            Toast.init(text: "투어 뱃지가 초기화되었습니다.").show()
        }
        let alertCancelAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel, handler: nil)
        
        alertController.addAction(alertAction)
        alertController.addAction(alertCancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

/*******************************************/
//MARK:          extenstion                //
/*******************************************/
extension MyBadgeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.myBadgeData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let resultCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyBadgeCollectionViewCell", for: indexPath) as! MyBadgeCollectionViewCell
        guard let realMyBadgeData = self.myBadgeData else { return resultCell }
        
        resultCell.sid = realMyBadgeData[indexPath.row]["sid"]
        resultCell.labelTitle.text = realMyBadgeData[indexPath.row]["title"]
        resultCell.imageViewMain.kf.setImage(with: URL(string: realMyBadgeData[indexPath.row]["imageUrl"] ?? ""))
        
        return resultCell
    }
    
    
}
