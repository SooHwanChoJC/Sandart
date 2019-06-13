//
//  PortraitTabViewController.swift - 세로 고정 된 탭바
//  Sandart
//
//  Created by 조수환 on 2018. 9. 3..
//  Copyright © 2018년 Joshua. All rights reserved.
//

import Foundation
import UIKit

class PortraitTabBarController:UITabBarController{//inherits to fix orientation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return [.portrait]
    }
}
