//
//  RecognizerService.swift
//  SpokeStack
//
//  Created by Cory D. Wiles on 10/2/18.
//  Copyright © 2018 Pylon AI, Inc. All rights reserved.
//

import Foundation

public enum RecognizerService {
    case google, wakeword, apple
}

extension RecognizerService {
    
    var speechRecognizerService: SpeechRecognizerService {
        
        switch self {
        case .google:
            return GoogleSpeechRecognizer.sharedInstance
        case .wakeword:
            return WakeWordSpeechRecognizer.sharedInstance
        case .apple:
            return AppleSpeechRecognizer.sharedInstance
        }
    }
}
