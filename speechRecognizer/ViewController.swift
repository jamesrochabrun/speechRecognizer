//
//  ViewController.swift
//  speechRecognizer
//
//  Created by James Rochabrun on 12/2/16.
//  Copyright © 2016 James Rochabrun. All rights reserved.
//

import UIKit
import Speech


class ViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var textView: UITextView!
    var audioRecordingSession : AVAudioSession!
    var audioRecorder : AVAudioRecorder!
    
    let audioFileName: String = "audio-recordered.m4a"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        recordingAudioSetUp()
    }
    
    //ask for permission
    func recordingAudioSetUp() {
        
        audioRecordingSession = AVAudioSession.sharedInstance()
        
        do {
            try audioRecordingSession.setCategory(AVAudioSessionCategoryRecord)
            try audioRecordingSession.setActive(true)
            
            audioRecordingSession.requestRecordPermission({[unowned self] (allowed:Bool) in
                
                if allowed {
                    //record
                    self.startRecording()
                    
                } else {
                    print("micro no accesible")
                }
            })
        } catch {
            print ("catch erro al configurar audio")
        }
    }
    
    func startRecording() {
        
        let settings : [String : Any] = [AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
                                         AVSampleRateKey : 12000.0,
                                         AVNumberOfChannelsKey : 1 as NSNumber,
                                         AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue]
        
        do {
            
            //instantiating the audiorecorder
            audioRecorder = try AVAudioRecorder(url: directoryURL()!, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.stopRecording), userInfo: nil, repeats: false)
            
        } catch {
            print("recording has an error")
        }
    }
    
    
    func directoryURL() -> URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for:.documentDirectory, in: .userDomainMask)
        let documentsDirectory = urls[0] as URL
        return documentsDirectory.appendingPathComponent(audioFileName)
    }
    
    func stopRecording() {
        
        audioRecorder.stop()
        audioRecorder = nil
        
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.recognizeSpeech), userInfo: nil, repeats: false)
    }
    
    
    func recognizeSpeech() {
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            if authStatus == SFSpeechRecognizerAuthorizationStatus.authorized {
                //if file is added a bundle

                // if  let path = Bundle.main.url(forResource: "audio-recordered", withExtension: "m4a") {
                
                let recognizer = SFSpeechRecognizer()
                let request = SFSpeechURLRecognitionRequest(url: self.directoryURL()!)
                
                recognizer?.recognitionTask(with:request , resultHandler: { (result, error) in
                    
                    //optional binding means if that optional can become constant is not null
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                            self.textView.text = result?.bestTranscription.formattedString
                    }
                })
            } else {
                print("authorization not granted")
            }
        }
    }
    





    
    
    
    
    
    
    
    
}

