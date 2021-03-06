//
//  SwiftUICameraView.swift
//  DiceKeys
//
//  Created by Stuart Schechter on 2020/11/19.
//

import SwiftUI
import AVFoundation
import ReadDiceKey

#if os(iOS)
import UIKit
#else
import AppKit
#endif

final class DiceKeysCameraViewDelegate {
    let size: CGSize
    let onFrameProcessed: ((_ processedImageFrameSize: CGSize, _ facesRead: [FaceRead]?) -> Void)?
    let onRead: ((DiceKey) -> Void)?
    let selectedCamera: AVCaptureDevice?

    private var onReadSentYet = false
    private let processor = DKImageProcessor.create()!

    init(selectedCamera: AVCaptureDevice? = nil, onFrameProcessed: ((_ processedImageFrameSize: CGSize, _ facesRead: [FaceRead]?) -> Void)? = nil, onRead: ((DiceKey) -> Void)? = nil, size: CGSize) {
        self.onFrameProcessed = onFrameProcessed
        self.onRead = onRead
        self.size = size
        self.selectedCamera = selectedCamera
    }

    func onFrameCaptured(_ imageBitmap: Data, _ width: Int32, _ height: Int32) {
        processor.process(imageBitmap, width: width, height: height)
        let json = processor.json()
        let facesReadOrNil = FaceRead.fromJson(json)
        if let facesRead = facesReadOrNil {
            // Render overlay image
            if let diceKey = try? DiceKey(facesRead) {
                if !self.onReadSentYet {
                    self.onReadSentYet = true
                    self.onRead?(diceKey)
                }
            }
        }
        self.onFrameProcessed?(CGSize(width: CGFloat(width), height: CGFloat(height)), facesReadOrNil)
    }

    public func makeXXViewController(context: XXViewControllerRepresentableContext<DiceKeysCameraView>) -> DiceKeysCameraUIViewController {
        let controller = DiceKeysCameraUIViewController()
        controller.selectedCamera = self.selectedCamera
        controller.onFrameCaptured = onFrameCaptured
        controller.size = size
        controller.selectedCamera = selectedCamera
        return controller
    }
}

#if os(iOS)
final class DiceKeysCameraView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = DiceKeysCameraUIViewController
    
    let delegate: DiceKeysCameraViewDelegate

    init(selectedCamera: AVCaptureDevice? = nil, onFrameProcessed: ((_ processedImageFrameSize: CGSize, _ facesRead: [FaceRead]?) -> Void)? = nil, onRead: ((DiceKey) -> Void)? = nil, size: CGSize = UIScreen.main.bounds.size) {
        self.delegate = DiceKeysCameraViewDelegate(selectedCamera: selectedCamera, onFrameProcessed: onFrameProcessed, onRead: onRead, size: size)
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<DiceKeysCameraView>) -> DiceKeysCameraUIViewController {
        return delegate.makeXXViewController(context: context)
    }

    public func updateUIViewController(_ viewController: DiceKeysCameraUIViewController, context: XXViewControllerRepresentableContext<DiceKeysCameraView>) {
    }
}
#else
final class DiceKeysCameraView: NSViewControllerRepresentable {
    typealias NSViewControllerType = DiceKeysCameraUIViewController
    
    let delegate: DiceKeysCameraViewDelegate

    init(selectedCamera: AVCaptureDevice? = nil, onFrameProcessed: ((_ processedImageFrameSize: CGSize, _ facesRead: [FaceRead]?) -> Void)? = nil, onRead: ((DiceKey) -> Void)? = nil, size: CGSize) {
        self.delegate = DiceKeysCameraViewDelegate(selectedCamera: selectedCamera, onFrameProcessed: onFrameProcessed, onRead: onRead, size: size)
    }

    public func makeNSViewController(context: NSViewControllerRepresentableContext<DiceKeysCameraView>) -> DiceKeysCameraUIViewController {
        return delegate.makeXXViewController(context: context)
    }

    public func updateNSViewController(_ viewController: DiceKeysCameraUIViewController, context:                XXViewControllerRepresentableContext<DiceKeysCameraView>) {
        if viewController.selectedCamera == nil || viewController.selectedCamera!.uniqueID != delegate.selectedCamera?.uniqueID {
            viewController.selectedCamera = delegate.selectedCamera
            viewController.cameraControllerPrepare()
        }
    }
}
#endif

final class DiceKeysCameraUIViewController: XXViewController {
    let cameraController = DiceKeysCameraController()
    
    var previewView: XXView!
    var selectedCamera: AVCaptureDevice? = nil

    var onFrameCaptured: CaptureFrameHandler? {
        get { return self.cameraController.onFrameCaptured }
        set { DiceKeysCameraController.processedFrameDispatchQueue.async {
                self.cameraController.onFrameCaptured = newValue
            }
        }
    }

    var size: CGSize {
        get { cameraController.size }
        set { cameraController.size = newValue }
    }

    func withOnFrameCaptured(onFrameCaptured newValue: CaptureFrameHandler?) -> DiceKeysCameraUIViewController {
        cameraController.onFrameCaptured = newValue
        return self
    }

    override func viewDidLoad() {
        previewView = XXView(frame:  CGRect(x: 0, y: 0, width: size.width, height: size.height))
        #if os(iOS)
        previewView.contentMode = UIView.ContentMode.scaleAspectFill
        #endif
        
        view.addSubview(previewView)
        previewView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        previewView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        cameraControllerPrepare()
    }
    
    func cameraControllerPrepare() {
        cameraController.prepare(selectedCamera) {[weak self] error in
            guard let weakSelf = self else {
                return
            }
            if let error = error {
                print(error)
            }
    
            try? weakSelf.cameraController.displayPreview(on: weakSelf.previewView)
        }
    }
    
    
    #if os(iOS)
    override func viewWillDisappear(_ animated: Bool) {
        cameraController.stop()
        print("Camera stopped")
    }
    #else
    override func loadView() {
        view = NSView(frame: NSMakeRect(0.0, 0.0, 400.0, 270.0))
    }
    override func viewWillDisappear() {
        cameraController.stop()
        print("Camera stopped")
    }
    #endif
}
