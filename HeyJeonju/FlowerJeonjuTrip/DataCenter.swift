//
//  DataCenter.swift
//  FlowerJeonjuTrip
//
//  Created by leejaesung on 2017. 11. 14..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import Foundation

// 문화 공간 데이터 클래스
struct cultureClass {
    var sid: String // 데이터번호 dataSid
    var title: String // 시설명 dataTitle
    var content: String // 기타내용 dataContent
    var introContent: String // 시설소개 introContent
    var tel: String // 시설연락처 tel
    var website: String // 시설홈페이지 userHomepage
    var typeCode: String // 시설구분 - typeCode
    var address: String // 시설 기본주소 addr
    var addressDetail: String // 시설 상세주소
    var createdDate: String // 등록일 regDt
    var posX: String // 경도
    var posY: String // 위도
    
    var number: Int // 고유 키 값
}

// 문화 공간 이미지 데이터 클래스
struct cultureImageClass {
    var dataSid: String
    var fileUrl: String?
    var thumbUrl: String?
}

struct wifiClass {
    var instplaceNm: String
    var posX: String?
    var posY: String?
}

struct toiletClass {
    var instplaceNm: String
    var posX: String?
    var posY: String?
}

class DataCenter {
    
    static let shared = DataCenter()
    
    var cultureList: [cultureClass]? = nil
    var cultureTraditionlList: [cultureClass]? = nil
    var cultureCenterList: [cultureClass]? = nil
    var cultureLibraryList: [cultureClass]? = nil
    
}
