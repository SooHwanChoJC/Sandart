//
//  LandScapeAVPlayerViewController.swift - 가로 고정된 AVPlayerViewController
//  Sandart
//
//  Created by 조수환 on 2018. 9. 3..
//  Copyright © 2018년 Joshua. All rights reserved.
//

import Foundation
import AVKit

class LandscapeAVPlayerViewController:AVPlayerViewController{//Inherits to fix orientation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .landscapeLeft
    }
}
