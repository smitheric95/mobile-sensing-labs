//
//  AudioModel.h
//  AudioLab
//
//  Created by Eric Smith on 9/12/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioModel : NSObject
+ (AudioModel *)sharedManager;
-(int)getBufferSize;
-(float*)getDataStream;
@end
