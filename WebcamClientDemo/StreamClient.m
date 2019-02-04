//
//  StreamClient.m
//  WebcamClientDemo
//
//  Copyright © 2019 All rights reserved.
//

#import "StreamClient.h"

@implementation StreamClient

- (instancetype)initWithAddress:(NSString *)addr {
    const char *url = [addr UTF8String];
    self.rtmpClient = srs_rtmp_create(url);
    if (self.rtmpClient == nil) {
        return nil;
    }
    
    int err;
    
    err = srs_rtmp_handshake(self.rtmpClient);
    if (err != 0){
        return nil;
    }
    err = srs_rtmp_set_schema(self.rtmpClient, srs_url_schema_normal);
    if (err != 0){
        return nil;
    }
    err = srs_rtmp_connect_app(self.rtmpClient);
    if (err != 0){
        return nil;
    }
    
    char *ip;
    int pid = -1;
    int cid = -1;
    err = srs_rtmp_get_server_id(self.rtmpClient, &ip, &pid, &cid);
    if (err != 0){
        return nil;
    }
    
    int vmaj;
    int vmin;
    int vrev;
    int vbuild;
    err = srs_rtmp_get_server_version(self.rtmpClient, &vmaj, &vmin, &vrev, &vbuild);
    if (err != 0) {
        return nil;
    }
    
    return self;
}

- (int) publishStream {
    return srs_rtmp_publish_stream(self.rtmpClient);
}

- (int) writeToStream:(char *)data {
    int err = 0;
    time_t ttime = time(0);
    uint32_t timestamp = static_cast<uint32_t>(ttime);
    
    srs_rtmp_write_packet(self.rtmpClient, SRS_RTMP_TYPE_VIDEO, timestamp, data, sizeof(data));
    
    return err;
}

@end
