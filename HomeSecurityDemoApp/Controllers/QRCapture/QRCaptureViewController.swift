//
//  QRCaptureViewController.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 05/08/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit
import AVFoundation

protocol QRCaptureDelegate: NSObjectProtocol {
    func didCapture(text: String)
    func didCancelCapture()
}

final class QRCaptureViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var cancelButtonContainer: UIView!

    @IBOutlet weak var scanYourCodeContainer: UIView!

    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    weak var delegate: QRCaptureDelegate?

    // Added to support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]

    override func viewDidLoad() {
        super.viewDidLoad()
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())

            captureMetadataOutput.metadataObjectTypes = supportedBarCodes

            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)

            captureSession?.startRunning()
            view.bringSubviewToFront(cancelButtonContainer)
            view.bringSubviewToFront(scanYourCodeContainer)
            qrCodeFrameView = UIView()
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.greenColor().CGColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
        } catch {}
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = view.frame
    }

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.didCancelCapture()
        }
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        if let connection = self.videoPreviewLayer?.connection {
            let currentDevice: UIDevice = UIDevice.currentDevice()
            let orientation: UIDeviceOrientation = currentDevice.orientation
            let previewLayerConnection: AVCaptureConnection = connection
            if (previewLayerConnection.supportsVideoOrientation) {
                switch (orientation) {
                case .Portrait:
                    previewLayerConnection.videoOrientation = .Portrait
                    break
                case .LandscapeRight:
                    previewLayerConnection.videoOrientation = .LandscapeLeft
                    break
                case .LandscapeLeft:
                    previewLayerConnection.videoOrientation = .LandscapeRight
                    break
                case .PortraitUpsideDown:
                    previewLayerConnection.videoOrientation = .PortraitUpsideDown
                    break
                default:
                    previewLayerConnection.videoOrientation = .Portrait
                    break
                }
            }
        }
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {

        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            return
        }

        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if supportedBarCodes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds

            if metadataObj.stringValue != nil {
                guard let delegate = self.delegate else { return }
                delegate.didCapture(metadataObj.stringValue)
            }
        }
    }
}
