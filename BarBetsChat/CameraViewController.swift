//
//  ViewController.swift
//  Camera
//
//  Created by Kayla Kerney on 7/25/16.
//  Copyright © 2016 Kayla Kerney. All rights reserved.
//
//

import UIKit
import AVFoundation
import Firebase

class CameraViewController: UIViewController {
    
    var messagesController: MessagesViewController?
    var currentBettie: User?
    var currentBet: Bet?
    var currentGroupId: String?
    
    
    let previewCamera: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .ScaleAspectFill
        view.backgroundColor = UIColor.redColor()
        return view
    }()
    
    let capturedImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .ScaleAspectFill
        return image
    }()
    
    lazy var takePhotoButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTakePhoto), forControlEvents: .TouchUpInside)
        button.setImage(UIImage(named: "camera"), forState: .Normal)
        button.imageView?.contentMode = .ScaleAspectFit
        button.layer.cornerRadius = 25
        button.backgroundColor = UIColor.whiteColor()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backImage = UIImage(named: "back")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .Plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        view.addSubview(previewCamera)
        view.addSubview(capturedImageView)
        view.addSubview(takePhotoButton)
        
        setupViews()
        
        displayBetAlert()
    }
    
    func handleCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func displayBetAlert() {
        var alertController:UIAlertController?
        //let bettie = currentBettie?.name as String!
        
        guard let bettie = currentBettie?.name else {
            return
        }
        alertController = UIAlertController(title: "Barstool Bets",
                                            message: "If I Roll A 7 \(bettie) must...",
                                            preferredStyle: .Alert)
        
        alertController!.addTextFieldWithConfigurationHandler(
            {(textField: UITextField!) in
                textField.placeholder = "Enter Bet"
        })
        
        let action = UIAlertAction(title: "Lock in Bet",
                                   style: UIAlertActionStyle.Default,
                                   handler: {[weak self]
                                    (paramAction:UIAlertAction!) in
                                    if let textFields = alertController?.textFields{
                                        let theTextFields = textFields as [UITextField]
                                        let enteredText = theTextFields[0].text
                                        if enteredText == "" {
                                            print("error need to enter fields")
                                            self!.dismissViewControllerAnimated(true, completion: nil)
                                        } else {
                                            self!.handleBet(enteredText!)
                                        }
                                    }
        })
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) { (paramAction:UIAlertAction!) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alertController?.addAction(action)
        alertController?.addAction(cancel)
        self.presentViewController(alertController!,
                                   animated: true,
                                   completion: nil)
        
        
        
    }
    
    func handleBet(bet: String) {
        
        currentBet = Bet()
        currentBet?.bet = bet
        currentBet?.betFromId = FIRAuth.auth()?.currentUser?.uid
        currentBet?.betToId = currentBettie?.id
        currentBet?.groupId = currentGroupId
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error: NSError?
        var input: AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error == nil && (captureSession?.canAddInput(input))! {
            captureSession?.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if ((captureSession?.canAddOutput(stillImageOutput)) != nil) {
                captureSession?.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                //previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
                //previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                
                let bounds = view.layer.bounds as CGRect
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer?.bounds = bounds
                previewLayer?.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
                
                previewCamera.layer.addSublayer(previewLayer!)
                
                captureSession?.startRunning()
            }
        }
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        previewLayer?.frame = previewCamera.bounds
        
    }
    
    func setupViews() {
        
        
        capturedImageView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        capturedImageView.topAnchor.constraintEqualToAnchor(previewCamera.bottomAnchor).active = true
        capturedImageView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        
        takePhotoButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        takePhotoButton.bottomAnchor.constraintEqualToAnchor(capturedImageView.bottomAnchor, constant: -10).active = true
        takePhotoButton.heightAnchor.constraintEqualToConstant(50).active = true
        takePhotoButton.widthAnchor.constraintEqualToConstant(50).active = true
        
        previewCamera.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        previewCamera.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        previewCamera.bottomAnchor.constraintEqualToAnchor(capturedImageView.topAnchor).active = true
        previewCamera.heightAnchor.constraintEqualToConstant(333.5).active = true
        
        
    }
    
    func didTakePhoto() {
        if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    
                    self.capturedImageView.image = image
                    let test = self.capturedImageView.frame.height
                    let test2 = self.previewCamera.frame.height
                    print(test2)
                    print(test)
                }
            })
        }
        
    }
    
    
}

