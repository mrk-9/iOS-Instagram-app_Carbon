//
//  ShowNoAnimationSegue.swift
//  Carbon
//
//  Created by Mobile on 10/5/16.
//  Copyright © 2016 Robert. All rights reserved.
//

import UIKit

class ShowNoAnimationSegue: UIStoryboardSegue {
    override func perform() {
        if let navigationVC = source.navigationController {
            navigationVC.pushViewController(destination, animated: false)
        }
    }
}
