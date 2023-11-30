//
//  ContentView.swift
//  In-Class Activity Pro IPhone Ch13 Speech
//
//  Created by Student Account on 11/29/23.
//

import SwiftUI
import Speech
import AVFoundation

struct ContentView: View {
    let audio = AVSpeechSynthesizer()
    @State var convertText = AVSpeechUtterance(string: "")
    @State var textToRead = "Welcome to the app"
    @State var sliderValue: Float = 0.5
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State var request = SFSpeechAudioBufferRecognitionRequest()
    @State var recognitionTask : SFSpeechRecognitionTask?
    @State var message = ""
    @State var isStopped: String = "false"
    var body: some View {
        VStack (spacing: 25) {
            TextField("Spoken text appears here", text: $message)
            if(isStopped == "true"){
                Text("Say 'start' to start recording")
            }else{
                Text("Say 'stop' to stop recording")
            }
        }
        .onAppear(perform: {
            recognizeSpeech()
            convertText = AVSpeechUtterance(string: textToRead)
            convertText.rate = sliderValue
            audio.speak(convertText)
        })
    }
    func checkSpokenCommand (commandString: String) {
            switch commandString {
            case "Stop":
                isStopped = "true"
            case "Start":
                isStopped = "false"
            default:
                isStopped = ""
            }
        }
    func stopSpeech() {
        audioEngine.stop()
        request.endAudio()
        recognitionTask?.cancel()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    func recognizeSpeech() {
        let node = audioEngine.inputNode
        request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return print (error)
        }
        guard let recognizeMe = SFSpeechRecognizer() else {
            return
        }
        if !recognizeMe.isAvailable {
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: {result, error in
            if let result = result {
                let transcribedString = result.bestTranscription.formattedString
                if isStopped == "false"{
                    message = transcribedString
                }
                checkSpokenCommand(commandString: transcribedString)
            } else if let error = error {
                print(error)
            }
        })
    }
}

#Preview {
    ContentView()
}
