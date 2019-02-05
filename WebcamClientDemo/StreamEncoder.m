//
//  StreamEncoder.m
//  WebcamClientDemo
//
//  Copyright © 2019 All rights reserved.
//

#import "StreamEncoder.h"

@implementation StreamEncoder

- (void) checkWebcamPermissions {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
    }];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
    }];
}

- (int) encodeFile:(NSURL *)path
{
    int err = 0;
    
    printf("[StreamEncoder] Encoding path: %s", [path absoluteString]);
    
    return err;
}

@end
