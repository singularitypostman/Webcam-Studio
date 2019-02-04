//
//  StreamClient.h
//  WebcamClientDemo
//
//  Copyright © 2019 All rights reserved.
//

#ifndef StreamClient_h
#define StreamClient_h

#ifndef StreamClient_h
#define StreamClient_h

#import <Foundation/Foundation.h>

#define STREAMING_ACTIVE_STATUS "Live"
#define STREAMING_READY_STATUS "Ready"
#define STREAMING_ERROR_STATUS "Error"

@interface StreamClient: NSObject

@property (nonatomic) srs_rtmp_t rtmpClient;
@property (nonatomic) int errorCode;
@property (nonatomic) CFSocketRef socket;

- (instancetype) initWithAddress:(NSString *)addr;
- (int) publishStream;
- (int) writeToStream:(char *)data;

@end


#endif /* StreamClient_h */
