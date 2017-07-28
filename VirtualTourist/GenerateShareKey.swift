//
//  GenerateShareKey.swift
//  VirtualTourist
//
//  Created by Raksha Vadim on 28.07.17.
//  Copyright © 2017 Raksha Vadim. All rights reserved.
//

import Foundation


class GenerateSharedKey {
    private init() {}
    
    public static func generate() -> String {
        var key = ""
        for _ in 0...arc4random_uniform(50) {
            key += data[Int(arc4random_uniform(UInt32(data.count)))]
        }
        return key
    }
    
    private static let data = [
        "1","2","3","4","5","6","7","8","9","0",
        "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
        "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"
    ]
}
