//
//  StreamClient.h
//  Monique
//
//  Created by Shavit Tzuriel on 1/28/19.
//  Copyright © 2019 Shavit Tzuriel. All rights reserved.
//

#ifndef StreamClient_h
#define StreamClient_h

#import <Foundation/Foundation.h>

@interface StreamClient: NSObject

@property (nonatomic) int errorCode;
@property (nonatomic) CFSocketRef socket;

- (instancetype) initWithAddress:(NSString *)addr port:(int)port;

@end

#endif /* StreamClient_h */
