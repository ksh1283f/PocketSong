//
//  ShazamController.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 12/13/21.
//

import Foundation
import ShazamKit
import AVFAudio
import UIKit

// helper class that controls the microphone and uses ShazamKit to identify audio
class ShazamController:NSObject { // that's required by any class that conforms to SHSessionDelegate
    private var session:SHSession?  // the shazam kit session you'll use to communicate with the shazam service
    private let audioEngine = AVAudioEngine()   // an AVAudioEngine instance you'll use to capture audio from the microphone
    
    private var matchHandler: ((SHMatchedMediaItem?, Error?)-> Void)? // a handler block the app views will implement.it's called when the identification process finished.
    
    init(matchHandler handler: ((SHMatchedMediaItem?, Error?)->Void)?) {
        matchHandler = handler
    }
    
    //the rest of the app's code will use to identify audio with ShazamKit.
    func match(catalog: SHCustomCatalog? = nil) throws {
        // 1. Instantiate SHSession
        if let catalog = catalog{
            session = SHSession(catalog: catalog)   // custom catalog
        } else {
            session = SHSession()
        }
        
        // 2. Set SHSession delegate
        if session?.delegate == nil {
            session?.delegate = self
        }
        
        // 3. Prepare to capture audio
        // todo edit when user input twice
        let audioFormat = AVAudioFormat(
            standardFormatWithSampleRate: audioEngine.inputNode.outputFormat(forBus: 0).sampleRate, channels: 1
        )
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 2048, format: audioFormat) {
            // callback with the captured audio buffer
            [weak session] buffer, audioTime in
            session?.matchStreamingBuffer(buffer, at: audioTime)    // converts the audio in the buffer to a shazam signature and matches against the reference signatures in the selected catalog
            
            // Alternatively, you can use SHSignatureGenerator to generate a signature object and pass it to the match of SHSession. However, matchStreamingBuffer(_:at:) is suitable for contiguous audio and therfore fits your use case.
        }
        
        // 4. start capture audio using AVAudioEngine
        try AVAudioSession.sharedInstance().setCategory(.record)
        AVAudioSession.sharedInstance()
            .requestRecordPermission {  // request record permission
                [weak self] success in
                guard
                    success,
                    let self = self
                else {
                    print("microphone request is denied!")
                    
                    // todo show alert why you approve this permission and how to approve it
//                    let alert = UIAlertController
                    return
                }
                try? self.audioEngine.start()   // start recording
            }
    }
    
    // you need to stop capturing audio when any of the two delegate methods are called
    func stopListening(){
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        print("[ShazamController] stoplistening")
    }
}

extension ShazamController: SHSessionDelegate{
    
    // when the recorded signature matches a song in the catalog
    // match:SHMatch contains the results
    func session(_ session: SHSession, didFind match: SHMatch) {
        DispatchQueue.main.sync {
            [weak self] in
            guard let self = self else{
                //todo show alert for this error(matchhandler is nil)
                print("match handler is nil. check ShazamController's initializer method")
                return
            }
            
            if let handler = self.matchHandler {
                // ShazamKit might return multiple matches if the query signature matches multiple songs in the catalog
                // the matches are ordered by the quality of the match, the first having the highest quality
                handler(match.mediaItems.first, nil)
                self.stopListening()
            }
        }
    }
    
    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else {
                return
            }
            
            if let handler = self.matchHandler {
                handler(nil, error)
                
                self.stopListening()
            }
        }
    }
}
