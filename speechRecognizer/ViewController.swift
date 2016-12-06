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
    var recordingButtonStart : UIButton!
    var recordingButtonStop : UIButton!
    
    let audioFileName: String = "audio-recordered.m4a"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        textView.isUserInteractionEnabled = false
        
        recordingButtonStart = UIButton()
        recordingButtonStart.addTarget(self, action: #selector(startRecording), for:.touchUpInside)
        recordingButtonStart.isUserInteractionEnabled = false
        recordingButtonStart.alpha = 0.3
        recordingButtonStart.setTitle("RECORD", for: .normal)
        recordingButtonStart.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        recordingButtonStart.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        view.addSubview(recordingButtonStart)
        
        recordingButtonStop = UIButton()
        recordingButtonStop.addTarget(self, action: #selector(stopRecording), for:.touchUpInside)
        recordingButtonStop.isUserInteractionEnabled = false
        recordingButtonStop.alpha = 0.3
        recordingButtonStop.setTitle("STOP", for: .normal)
        recordingButtonStop.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        recordingButtonStop.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        view.addSubview(recordingButtonStop)

        recordingAudioSetUp()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var frame = recordingButtonStart.frame
        frame.size.height = 50;
        frame.size.width = self.view.frame.size.width * 0.6
        frame.origin.x = (self.view.frame.size.width - frame.size.width)/2
        frame.origin.y = (self.view.frame.size.height - frame.size.height)/2
        recordingButtonStart.frame = frame
        
        frame = recordingButtonStop.frame
        frame.size.height = 50
        frame.size.width = self.view.frame.size.width * 0.6
        frame.origin.x = (self.view.frame.size.width - frame.size.width)/2
        frame.origin.y = recordingButtonStart.frame.maxY + 30
        recordingButtonStop.frame = frame
        
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
                    self.recordingButtonStart.isUserInteractionEnabled = true
                    self.recordingButtonStart.alpha = 1.0
                
                } else {
                    print("micro no accesible")
                    self.recordingButtonStart.isUserInteractionEnabled = false
                    self.recordingButtonStart.alpha = 0.3
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
            
           // Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.stopRecording), userInfo: nil, repeats: false)
            self.recordingButtonStart.isUserInteractionEnabled = false
            self.recordingButtonStart.alpha = 0.3
            self.recordingButtonStop.isUserInteractionEnabled = true
            self.recordingButtonStop.alpha = 1.0
            
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
        recognizeSpeech()
        recordingButtonStop.isUserInteractionEnabled = false
        recordingButtonStop.alpha = 0.3
        self.recordingButtonStart.isUserInteractionEnabled = true
        self.recordingButtonStart.alpha = 1.0
        
       // Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.recognizeSpeech), userInfo: nil, repeats: false)
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

