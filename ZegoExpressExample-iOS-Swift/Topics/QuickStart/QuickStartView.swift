//
//  QuickStartView.swift
//  ZegoExpressExample-iOS-Swift
//
//  Created by Patrick Fu on 2020/2/22.
//  Copyright © 2020 Zego. All rights reserved.
//

import SwiftUI
import ZegoExpressEngine

class QuickStartCoordinator: NSObject, ObservableObject, ZegoEventHandler {
    
    let appID: UInt32 = KeyCenter.appID
    let appSign: String = KeyCenter.appSign
    let isTestEnv: Bool = true
    let scenario: ZegoScenario = .general
    
    let roomID: String = "QuickStartRoom-1"
    let userID: String = String(UUID().uuidString.prefix(6))
    
    @Published var isEngineActive: Bool = false
    @Published var roomState: ZegoRoomState = .disconnected
    @Published var publisherState: ZegoPublisherState = .noPublish
    @Published var playerState: ZegoPlayerState = .noPlay
    
    @Published var actionLog: String = ""
    
    // MARK: - Step 1: CreateEngine
    
    func createEngine() {
        
        // Create ZegoExpressEngine and add self as a delegate (ZegoEventHandler)
        ZegoExpressEngine.createEngine(withAppID: appID, appSign: appSign, isTestEnv: isTestEnv, scenario: scenario, eventHandler: self)
        
        // Notify View that engine state changed
        isEngineActive = true
        
        showLog(" 🚀 Create ZegoExpressEngine")
    }
    
    
    // MARK: - Step 2: LoginRoom
    
    func loginRoom() {
        
        // Instantiate a ZegoUser object
        let user = ZegoUser(userID: userID)
        
        // Login room
        ZegoExpressEngine.shared().loginRoom(roomID, user: user)
        
        showLog(" 🚪 Start login room, roomID: \(roomID)")
    }
    
    
    // MARK: - Step 3: StartPublishing
    
    func startPublishing(streamID: String, previewView: UIView) {
        
        // Instantiate a ZegoCanvas for local preview
        let previewCanvas = ZegoCanvas(view: previewView)
        previewCanvas.viewMode = .aspectFill
        
        // Start preview
        ZegoExpressEngine.shared().startPreview(previewCanvas)
        
        // If streamID is empty @"", SDK will pop up an UIAlertController if "isTestEnv" is set to YES
        ZegoExpressEngine.shared().startPublishingStream(streamID)
        
        showLog(" 📤 Start publishing stream, streamID: \(streamID)")
    }
    
    
    // MARK: - Step 4: StartPlaying
    
    func startPlaying(streamID: String, playView: UIView) {
        // Instantiate a ZegoCanvas for play view
        let playCanvas = ZegoCanvas(view: playView)
        playCanvas.viewMode = .aspectFill
        
        // If streamID is empty @"", SDK will pop up an UIAlertController if "isTestEnv" is set to YES
        ZegoExpressEngine.shared().startPlayingStream(streamID, canvas: playCanvas)
        
        showLog(" 📥 Strat playing stream, streamID: \(streamID)")
    }

    
    // MARK: - Exit
    
    func destroyEngine() {
        // Logout room will automatically stop publishing/playing stream.
//        ZegoExpressEngine.shared().logoutRoom(roomID)
        
        // Can destroy the engine when you don't need audio and video calls
        //
        // Destroy engine will automatically logout room and stop publishing/playing stream.
        ZegoExpressEngine.destroy(nil)
        
        // Notify View that engine state changed
        isEngineActive = false
        roomState = .disconnected
        publisherState = .noPublish
        playerState = .noPlay
        
        showLog(" 🏳️ Destroy ZegoExpressEngine")
    }
    
    
    deinit {
        // Logout room will automatically stop publishing/playing stream.
//        ZegoExpressEngine.shared().logoutRoom(roomID)
        
        // Can destroy the engine when you don't need audio and video calls
        //
        // Destroy engine will automatically logout room and stop publishing/playing stream.
        ZegoExpressEngine.destroy(nil)
        
        // Notify View that engine state changed
        isEngineActive = false
        roomState = .disconnected
        publisherState = .noPublish
        playerState = .noPlay
    }
    
    // MARK: - ZegoEventHandler Delegate
    
    func onRoomStateUpdate(_ state: ZegoRoomState, errorCode: Int32, extendedData: [AnyHashable : Any]?, roomID: String) {
        showLog(" 🚩 🚪 Room state update, state: \(state.rawValue), errorCode: \(errorCode), roomID: \(roomID)")
        
        roomState = state
    }
    
    func onPublisherStateUpdate(_ state: ZegoPublisherState, errorCode: Int32, extendedData: [AnyHashable : Any]?, streamID: String) {
        showLog(" 🚩 📤 Publisher state update, state: \(state.rawValue), errorCode: \(errorCode), streamID: \(streamID)")
        
        publisherState = state
    }
    
    func onPlayerStateUpdate(_ state: ZegoPlayerState, errorCode: Int32, extendedData: [AnyHashable : Any]?, streamID: String) {
        showLog(" 🚩 📥 Player state update, state: \(state.rawValue), errorCode: \(errorCode), streamID: \(streamID)")
        
        playerState = state
    }
    
    // MARK: Print Log
    func showLog(_ text: String) {
        if actionLog.count > 0 {
            actionLog.append("\n\(text)")
        } else {
            actionLog.append(text)
        }
        NSLog(text)
    }
}


struct QuickStartView: View {
    var previewView = UIViewWrapper()
    var playView = UIViewWrapper()
    
    @ObservedObject var coordinator = QuickStartCoordinator()
    
    @State private var publishingStreamID = ""
    @State private var playingStreamID = ""
    
    var body: some View {
        GeometryReader { reader in
            ScrollView {
                VStack {
                    
                    LogTextView(text: self.$coordinator.actionLog).frame(height: 60)
                    
                    HStack(spacing: 15) {
                        ZStack(alignment: .top) {
                            self.previewView.frame(width: reader.size.width / 2 - 20, height: reader.size.width / 2 * 1.5, alignment: .center)
                                .background(Color(UIColor.secondarySystemBackground))
                            
                            Text("Local Preview View").padding(5).font(.footnote)
                        }

                        ZStack(alignment: .top) {
                            self.playView.frame(width: reader.size.width / 2 - 20, height: reader.size.width / 2 * 1.5, alignment: .center)
                                .background(Color(UIColor.secondarySystemBackground))
                            
                            Text("Remote Play View").padding(5).font(.footnote)
                        }
                    }

                    Divider()

                    VStack(spacing: 0) {

                        self.stepOneCreateEngineView()
                        
                        self.stepTwoLoginRoomView()
                        
                        self.stepThreeStartPublishingView()
                        
                        self.stepFourStartPlayingView()
                        
                        Spacer().frame(height: 20)
                        
                        Button(action: {
                            self.coordinator.destroyEngine()
                        }) {
                            Text("DestroyEngine")
                        }
                    }

                    Spacer()

                }
            }
        }
        .navigationBarTitle("QuickStart", displayMode: .inline)
        .onDisappear {
            self.coordinator.destroyEngine()
        }
    }
    
    func stepOneCreateEngineView() -> some View {
        VStack(alignment: .leading) {
            Text("Step1:")
                .font(.footnote)
                .padding(EdgeInsets(top: 10, leading: 6, bottom: 2, trailing: 5))
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("AppID: \(String(self.coordinator.appID))")
                        .font(.footnote)
                        .padding(EdgeInsets(top: 6, leading: 6, bottom: 3, trailing: 5))
                    Text("isTestEnv: " + (self.coordinator.isTestEnv ? "true" : "false"))
                        .font(.footnote)
                        .padding(EdgeInsets(top: 3, leading: 6, bottom: 6, trailing: 5))
                }
                Spacer()
                Button(action: {
                    self.coordinator.createEngine()
                }) {
                    Text(self.coordinator.isEngineActive ? "✅ CreateEngine" : "CreateEngine")
                }
                .padding(.horizontal, 10)
            }
            .background(Color(UIColor.secondarySystemBackground))
        }
    }
    
    func stepTwoLoginRoomView() -> some View {
        VStack(alignment: .leading) {
            Text("Step2:")
                .font(.footnote)
                .padding(EdgeInsets(top: 10, leading: 6, bottom: 2, trailing: 5))
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("RoomID: \(self.coordinator.roomID)")
                        .font(.footnote)
                        .padding(EdgeInsets(top: 6, leading: 6, bottom: 3, trailing: 5))
                    Text("UserID: \(self.coordinator.userID)")
                        .font(.footnote)
                        .padding(EdgeInsets(top: 3, leading: 6, bottom: 6, trailing: 5))
                }
                Spacer()
                Button(action: {
                    self.coordinator.loginRoom()
                }) {
                    Text(self.coordinator.roomState == ZegoRoomState.connected ? "✅ LoginRoom" : "LoginRoom")
                }
                .padding(.horizontal, 10)
            }
            .background(Color(UIColor.secondarySystemBackground))
        }
    }
    
    func stepThreeStartPublishingView() -> some View {
        VStack(alignment: .leading) {
            Text("Step3:")
                .font(.footnote)
                .padding(EdgeInsets(top: 10, leading: 6, bottom: 2, trailing: 5))
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Publish StreamID:")
                        .padding(EdgeInsets(top: 2, leading: 10, bottom: 0, trailing: 10))
                        .font(.footnote)
                    
                    TextField("Fill Publish Stream ID", text: self.$publishingStreamID)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 10, trailing: 10))
                        .frame(idealWidth: 220, maxWidth: 220)
                }
                Spacer()
                Button(action: {
                    self.coordinator.startPublishing(streamID: self.publishingStreamID, previewView: self.previewView.view)
                }) {
                    Text(self.coordinator.publisherState == ZegoPublisherState.publishing ? "✅ StartPublishing" : "StartPublishing")
                }
                .padding(.horizontal, 10)
            }
            .background(Color(UIColor.secondarySystemBackground))
        }
    }
    
    func stepFourStartPlayingView() -> some View {
        VStack(alignment: .leading) {
            Text("Step4:")
                .font(.footnote)
                .padding(EdgeInsets(top: 10, leading: 6, bottom: 2, trailing: 5))
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Play StreamID:")
                        .padding(EdgeInsets(top: 2, leading: 10, bottom: 0, trailing: 10))
                        .font(.footnote)
                    
                    TextField("Fill Play Stream ID", text: self.$playingStreamID)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 10, trailing: 10))
                        .frame(idealWidth: 220, maxWidth: 220)
                }
                Spacer()
                Button(action: {
                    self.coordinator.startPlaying(streamID: self.playingStreamID, playView: self.playView.view)
                }) {
                    Text(self.coordinator.playerState == ZegoPlayerState.playing ? "✅ StartPlaying" : "StartPlaying")
                }
                .padding(.horizontal, 10)
            }
            .background(Color(UIColor.secondarySystemBackground))
        }
    }
}

#if DEBUG
struct QuickStartView_Previews: PreviewProvider {
    static var previews: some View {
        QuickStartView()
    }
}
#endif
