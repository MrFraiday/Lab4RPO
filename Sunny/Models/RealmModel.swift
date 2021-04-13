//
//  RealmModel.swift
//  Sunny
//
//  Created by Harbros38 on 3/23/21.
//  Copyright © 2021 Ivan Akulov. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class RealmModel: Object {
    dynamic var cityName = ""
    dynamic var temperature = 0.0
    dynamic var feelsLikeTemperature = 0.0
    dynamic var conditionCode = 0
    
    dynamic var id = UUID().uuidString
    
    class override func primaryKey() -> String? {
        return "id"
    }
}
