//
//  ConnectionChecker.swift - 인터넷 연결 상태를 점검하기 위한 클래스
//  Sandart
//
//  Created by 조수환 on 2018. 9. 10..
//  Copyright © 2018년 Joshua. All rights reserved.
//

import Foundation
import Alamofire

class ConnectionChecker{
    static func isConnectedInternet()->Bool{
        let reachabilityManager = Alamofire.NetworkReachabilityManager()!
        return reachabilityManager.isReachable
    }
}
