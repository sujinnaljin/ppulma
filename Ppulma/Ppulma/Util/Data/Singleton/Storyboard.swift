//
//  Storyboard.swift
//  Ppulma
//
//  Created by 강수진 on 2018. 10. 17..
//  Copyright © 2018년 강수진. All rights reserved.
//

import UIKit

class Storyboard {
    
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)

    struct StaticInstance {
        static var instance: Storyboard?
    }
    
    class func shared() -> Storyboard {
        if StaticInstance.instance == nil {
            StaticInstance.instance = Storyboard()
        }
        return StaticInstance.instance!
    }
}
