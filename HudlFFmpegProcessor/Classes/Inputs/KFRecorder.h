//
//  KFRecorder.h
//  Kickflip
//
//  Created by Christopher Ballinger on 1/16/14.
//  Copyright (c) 2014 Christopher Ballinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "KFAACEncoder.h"
#import "KFH264Encoder.h"
#import "HudlDirectoryWatcher.h"

extern NSString *const NotifNewAssetGroupCreated;
extern NSString *const SegmentManifestName;

@class KFRecorder, KFHLSWriter;

@protocol KFRecorderDelegate <NSObject>
- (void) recorderDidStartRecording:(KFRecorder*)recorder error:(NSError*)error;
- (void) recorderDidFinishRecording:(KFRecorder*)recorder error:(NSError*)error;
@end

/**
 *  KFRecorder manages the majority of the AV pipeline
 */
@interface KFRecorder : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, KFEncoderDelegate, HudlDirectoryWatcherDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong, readonly) AVCaptureDevice *videoDevice;
@property (nonatomic, strong, readonly) AVCaptureConnection *videoConnection;

@property (nonatomic, strong) KFAACEncoder *aacEncoder;
@property (nonatomic, strong) KFH264Encoder *h264Encoder;
@property (nonatomic, strong) KFHLSWriter *hlsWriter;

@property (nonatomic) int videoWidth;
@property (nonatomic) int videoHeight;
@property (nonatomic) int audioSampleRate;

@property (nonatomic) BOOL isRecording;

@property (nonatomic, weak) id<KFRecorderDelegate> delegate;

+ (instancetype)recorderWithName:(NSString *)name;
- (void)startRecording;
- (void)stopRecording;
- (void)setupSession;
- (double)durationRecorded;

@end
