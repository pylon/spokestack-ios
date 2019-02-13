//
//  WakewordService.swift
//  SpokeStack
//
//  Created by Noel Weichbrodt on 2/5/19.
//  Copyright © 2019 Pylon AI, Inc. All rights reserved.
//

import Foundation

@objc public enum WakewordService: Int {
    case appleWakeword
}

extension WakewordService {
    
    var wakewordRecognizerService: WakewordRecognizerService {
        
        switch self {
        case .appleWakeword:
            return AppleWakewordRecognizer.sharedInstance
        }
    }
}
