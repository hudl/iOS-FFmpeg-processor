//
//  ViewController.m
//  HudlFFmpegSample
//
//  Created by Brian Clymer on 3/3/15.
//  Copyright (c) 2015 Agile Sports - Hudl. All rights reserved.
//

#import "ViewController.h"
#import "KFRecorder.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *viewCamera;
@property (nonatomic, strong) KFRecorder *recorder;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic) BOOL isRecording;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.recorder = [KFRecorder recorderWithName:@"test"];

    self.previewLayer = self.recorder.previewLayer;
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;

    CGRect layerRect = self.viewCamera.bounds;
    [self.previewLayer setBounds:layerRect];
    [self.previewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
    self.viewCamera.layer.sublayers = nil;
    [self.viewCamera.layer addSublayer:self.previewLayer];
    [self.recorder.session startRunning];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newAssetGroupCreated:) name:NotifNewAssetGroupCreated object:nil];
}

- (IBAction)recordTapped:(id)sender
{
    if (self.isRecording)
    {
        [self.recorder stopRecording];
    }
    else
    {
        [self.recorder startRecording];
    }
    self.isRecording = !self.isRecording;
}

- (void)newAssetGroupCreated:(NSNotification *)notification
{
    NSLog(@"New Asset Group - %@", notification.object);
    // do something with the new .ts file.
}

@end
