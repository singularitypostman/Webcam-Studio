//
//  StreamEncoder.h
//  WebcamClientDemo
//
//  Copyright © 2019 All rights reserved.
//

#ifndef StreamEncoder_h
#define StreamEncoder_h

#import <AVFoundation/AVFoundation.h>

@interface StreamEncoder: NSObject

- (void) checkWebcamPermissions;

- (int) encodeFile:(NSURL *)path;

@end


#endif /* StreamEncoder_h */
