//
//  PublishStreamTopicView.swift
//  ZegoExpressExample-iOS-Swift
//
//  Created by Patrick Fu on 2020/2/26.
//  Copyright © 2020 Zego. All rights reserved.
//

import SwiftUI
import ZegoExpressEngine

struct PublishStreamTopicView: View {
    
    let previewView: UIViewWrapper
    
    @ObservedObject var manager: PublishStreamTopicManager
    
    @State var roomID = ""
    @State var streamID = ""
    @State private var showConfig = false
    
    init() {
        previewView = UIViewWrapper()
        manager = PublishStreamTopicManager(previewView: previewView.view)
    }
    
    var body: some View {
        ZStack {
            previewView
            
            VStack {
                HStack {
                    
                    qualityView
                    
                    Spacer()
                }
                
                Spacer().frame(height: 50)
                
                if self.manager.publishState == .noPublish {
                    configView
                } else {
                    Spacer().layoutPriority(1)
                }
                
                Spacer().frame(height: 30)
                
                Button(action: {
                    if self.manager.publishState == .noPublish {
                        self.manager.startLive(roomID: self.roomID, streamID: self.streamID)
                    } else if self.manager.publishState == .publishing {
                        self.manager.stopLive(roomID: self.roomID)
                    }
                }) {
                    Text("\(self.manager.publishState == .publishing ? "Stop Live" : "Start Live")")
                        .padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 30))
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .font(.headline)
                }
                
                Spacer(minLength: 50)
                
            }
        }
        .navigationBarTitle("Publish Stream", displayMode: .inline)
        .navigationBarItems(trailing:
            Button("Setting") {
                self.showConfig.toggle()
            }.actionSheet(isPresented: self.$showConfig) {
                ActionSheet(
                    title: Text("Setting"),
                    buttons: [
                        .cancel { print(self.showConfig) },
                        .default(Text("Camera: \(self.manager.enableCamera ? "On 🟢" : "Off 🔴")"), action: { self.manager.enableCamera.toggle() }),
                        .default(Text("Microphone: \(self.manager.muteMicrophone ? "Off 🔴" : "On 🟢")"), action: { self.manager.muteMicrophone.toggle() }),
                        .default(Text("Speaker: \(self.manager.muteSpeaker ? "Off 🔴" : "On 🟢")"), action: { self.manager.muteSpeaker.toggle() }),
                    ]
                )
            }
        )
        .onAppear {
            self.manager.createEngine()
        }
        .onDisappear{
            self.manager.destroyEngine()
        }
    }
    
    
    var qualityView: some View {
        VStack(alignment: .leading) {
            
            Spacer().frame(height: 5)
            
            Text("Resolution: \(Int(self.manager.videoSize.width)) x \(Int(self.manager.videoSize.height))").qualityStyle()
            
            Text("FPS(Capture): \(Int(self.manager.videoCaptureFPS)) fps").qualityStyle()
            
            Text("FPS(Encode): \(Int(self.manager.videoEncodeFPS)) fps").qualityStyle()
            
            Text("FPS(Send): \(Int(self.manager.videoSendFPS)) fps").qualityStyle()
            
            Text("Bitrate: \(self.manager.videoBitrate, specifier: "%.2f") kb/s").qualityStyle()
            
            Text("HardwareEncode: \(self.manager.isHardwareEncode ? "✅" : "❎")").qualityStyle()
            
            Text("NetworkQuality: \(self.manager.videoNetworkQuality)").qualityStyle()
            
            Spacer().frame(height: 5)
            
        }
        .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
    }
    
    
    var configView: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            Text("Room ID:")
            
            TextField("Please enter room ID", text: self.$roomID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Spacer().frame(height: 20)
            
            Text("Stream ID:")
            
            TextField("Please enter stream ID:", text: self.$streamID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
        }
        .padding(20)
    }
}

#if DEBUG
struct PublishStreamTopicView_Previews: PreviewProvider {
    static var previews: some View {
        PublishStreamTopicView()
    }
}
#endif
