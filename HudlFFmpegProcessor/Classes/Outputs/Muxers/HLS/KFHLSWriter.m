//
//  KFHLSWriter.m
//  FFmpegEncoder
//
//  Created by Christopher Ballinger on 12/16/13.
//  Copyright (c) 2013 Christopher Ballinger. All rights reserved.
//

#import "KFHLSWriter.h"
#import "FFOutputFile.h"
#import "FFmpegWrapper.h"
#import "avcodec.h"
#import "libavformat/avformat.h"
#import "libavcodec/avcodec.h"
#import "libavutil/opt.h"
#import "librtmp/log.h"
#import "KFRecorder.h"

@interface KFHLSWriter()

@property (nonatomic, strong) FFOutputFile *outputFile;
@property (nonatomic, strong) FFOutputStream *videoStream;
@property (nonatomic, strong) FFOutputStream *audioStream;
@property (nonatomic) AVPacket *packet;
@property (nonatomic) AVRational videoTimeBase;
@property (nonatomic) AVRational audioTimeBase;
@property (nonatomic) NSUInteger segmentDurationSeconds;
@property (nonatomic) NSUInteger keyFrameSkipper;
@property (nonatomic) BOOL isFinished;
@property (nonatomic, strong) NSString *directoryPath;

@end

@implementation KFHLSWriter

- (id)initWithDirectoryPath:(NSString *)directoryPath segmentCount:(NSUInteger)segmentCount
{
    if (self = [super init]) {
        av_register_all();
        avformat_network_init();
        avcodec_register_all();

#if DEBUG
        av_log_set_level(AV_LOG_VERBOSE);
        RTMP_LogSetLevel(RTMP_LOGALL);
#else
        av_log_set_level(AV_LOG_QUIET);
        RTMP_LogSetLevel(RTMP_LOGCRIT);
#endif

        _directoryPath = directoryPath;
        _packet = av_malloc(sizeof(AVPacket));
        _videoTimeBase.num = 1;
        _videoTimeBase.den = 1000000000;
        _audioTimeBase.num = 1;
        _audioTimeBase.den = 1000000000;
        _segmentDurationSeconds = 8;
        [self setupOutputFileSegmentCount:segmentCount];
        _conversionQueue = dispatch_queue_create("HLS Write queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)setupOutputFileSegmentCount:(NSUInteger)segmentCount
{
    _manifestPath = [_directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-s-%li-f-.m3u8", SegmentManifestName, segmentCount]];
    _outputFile = [[FFOutputFile alloc] initWithPath:self.manifestPath options:@{kFFmpegOutputFormatKey: @"hls"}];
}

- (void)addVideoStreamWithWidth:(int)width height:(int)height
{
    _videoStream = [[FFOutputStream alloc] initWithOutputFile:_outputFile outputCodec:@"h264"];

    _videoStream.stream->time_base.den = 90000;
    _videoStream.stream->time_base.num = 1;

    [_videoStream setupVideoContextWithWidth:width height:height];
    _videoStream.stream->codec->bit_rate = 3 * 1024 * 1024; // 3 mbps

    FFBitstreamFilter *bitstreamFilter = [[FFBitstreamFilter alloc] initWithFilterName:@"h264_mp4toannexb"];
    [_videoStream addBitstreamFilter:bitstreamFilter];

    int ret = av_opt_set_int(_outputFile.formatContext->priv_data, "hls_time", _segmentDurationSeconds, AV_OPT_SEARCH_CHILDREN);
    //DDLogVerbose(@"hls_time %i", ret);
    ret = av_opt_set_int(_outputFile.formatContext->priv_data, "hls_list_size", 10000000, AV_OPT_SEARCH_CHILDREN);
    //DDLogVerbose(@"hls_list_size %i", ret);
}

- (void)addAudioStreamWithSampleRate:(int)sampleRate
{
    _audioStream = [[FFOutputStream alloc] initWithOutputFile:_outputFile outputCodec:@"aac"];
    _audioStream.stream->time_base.den = 90000;
    _audioStream.stream->time_base.num = 1;
    _audioStream.stream->codec->bit_rate = 64 * 1024;
    [_audioStream setupAudioContextWithSampleRate:sampleRate];
}

- (BOOL)prepareForWriting:(NSError *__autoreleasing *)error
{
    // Open the output file for writing and write header
    if (![_outputFile openFileForWritingWithError:error])
    {
        return NO;
    }
    if (![_outputFile writeHeaderWithError:error])
    {
        return NO;
    }
    return YES;
}


- (void)processEncodedData:(NSData *)data presentationTimestamp:(CMTime)pts streamIndex:(NSUInteger)streamIndex isKeyFrame:(BOOL)isKeyFrame
{
    if (data.length == 0)
    {
        return;
    }
    dispatch_async(_conversionQueue, ^{
        if (self.isFinished) return;

        av_init_packet(_packet);

        uint64_t originalPTS = pts.value;

        // This lets the muxer know about H264 keyframes
        if (streamIndex == 0 && isKeyFrame) // this is hardcoded to video right now
        {
            _packet->flags |= AV_PKT_FLAG_KEY;
        }

        _packet->data = (uint8_t*)data.bytes;
        _packet->size = (int)data.length;
        _packet->stream_index = streamIndex;
        uint64_t scaledPTS = av_rescale_q(originalPTS, _videoTimeBase, _outputFile.formatContext->streams[_packet->stream_index]->time_base);
        if (streamIndex == 0) // log for video only
        {
            //DDLogVerbose(@"*** Original PTS: %lld", originalPTS);
            //DDLogVerbose(@"*** Scaled PTS: %lld", scaledPTS);
        }

        _packet->pts = scaledPTS;
        _packet->dts = scaledPTS;
        NSError *error = nil;
        [_outputFile writePacket:_packet error:&error];
        if (error)
        {
            //DDLogError(@"Error writing packet at streamIndex %lu and PTS %lld: %@", (unsigned long)streamIndex, originalPTS, error.description);
        }
        else
        {
            //DDLogVerbose(@"Wrote packet of length %d at streamIndex %d and \t oPTS %lld \t scaledPTS %lld", data.length, streamIndex, originalPTS, scaledPTS);
        }
    });
}

- (BOOL)finishWriting:(NSError *__autoreleasing *)error
{
    __block BOOL success = NO;
    dispatch_sync(self.conversionQueue, ^{
        success = [_outputFile writeTrailerWithError:error];
        self.isFinished = YES;
    });
    return success;
}

@end