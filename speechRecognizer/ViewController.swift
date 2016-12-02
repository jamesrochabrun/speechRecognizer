//
//  ViewController.swift
//  speechRecognizer
//
//  Created by James Rochabrun on 12/2/16.
//  Copyright © 2016 James Rochabrun. All rights reserved.
//

import UIKit
import Speech


class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    var audioRecordingSession : AVAudioSession!
    let audioFileName: String = "audio-recordered-m4a"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        recognizeSpeech()
    }
    
    func recognizeSpeech() {
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            if authStatus == SFSpeechRecognizerAuthorizationStatus.authorized {
                
                if  let path = Bundle.main.url(forResource: "audio", withExtension: "mp3") {
                    
                    let recognizer = SFSpeechRecognizer()
                    let request = SFSpeechURLRecognitionRequest(url: path)
                    
                    recognizer?.recognitionTask(with:request , resultHandler: { (result, error) in
                        
                        //optional binding means if that optional can become constant is not null
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            
//                            self.textView.text = String(describing: result?.bestTranscription.formattedString)
                            self.textView.text = result?.bestTranscription.formattedString
                        }
                    })
                    
                } else {
                    print("audio not found")
                }
                
            } else {
                print("authorization not granted")
            }
        }
    }
    
    
    func recordingAudio() {
        
        audioRecordingSession = AVAudioSession.sharedInstance()
        
        do {
          try audioRecordingSession.setCategory(AVAudioSessionCategoryRecord)
            try audioRecordingSession.setActive(true)
            
            audioRecordingSession.requestRecordPermission({[unowned self] (allowed:Bool) in
                
                if allowed {
                    //record
                    
                } else {
                    print("micro no accesible")
                }
            })
        } catch {
            print ("error on catch")
        }
    }

    func directoryURL() -> NSURL? {
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in:.userDomainMask)
        let documentsDirectory  = urls[0] as URL
        
        
        if  let urlReturned = documentsDirectory.appendingPathComponent(audioFileName) {
            return urlReturned
        }
    
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

