//
//  RecognizerService.swift
//  SpokeStack
//
//  Created by Cory D. Wiles on 10/2/18.
//  Copyright © 2018 Pylon AI, Inc. All rights reserved.
//

import Foundation

@objc public enum RecognizerService: Int {
    case googleSpeech, appleSpeech
}

extension RecognizerService {
    
    var speechRecognizerService: SpeechRecognizerService {
        
        switch self {
        case .googleSpeech:
            return GoogleSpeechRecognizer.sharedInstance
        case .appleSpeech:
            return AppleSpeechRecognizer.sharedInstance
        }
    }
}
