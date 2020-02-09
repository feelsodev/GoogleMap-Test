//
//  UserData.swift
//  MapTest2
//
//  Created by once on 04/12/2019.
//  Copyright © 2019 once. All rights reserved.
//

import Foundation

struct UserData : Codable{
    let id : String
    let x : Double
    let y : Double
}

struct Root: Codable {
    let data: [UserData]
}
