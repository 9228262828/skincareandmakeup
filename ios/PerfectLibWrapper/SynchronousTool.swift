//
//  SynchronousTool.swift
//  PerfectLibDemo
//
//  Created by Alex Lin on 2019/5/10.
//  Copyright © 2019 Perfect Corp. All rights reserved.
//

import UIKit

class SynchronousTool {
    static func synced(_ lock: Any, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    static func asyncMainSafe(closure: @escaping () -> ()) {
        if Thread.isMainThread {
            closure()
        }
        else {
            DispatchQueue.main.async {
                closure()
            }
        }
    }
}
