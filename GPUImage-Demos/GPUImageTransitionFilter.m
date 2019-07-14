//
//  GPUImageTransitionFilter.m
//  FilterShowcase
//
//  Created by yehot on 2019/1/3.
//  Copyright © 2019年 Cell Phone. All rights reserved.
//

#import "GPUImageTransitionFilter.h"
#import <GLKit/GLKit.h>
#import "GLTransitionConst.h"

@interface GPUImageTransitionFilter()
{
    GLint progressUniform;
}

@property(assign, nonatomic, readonly) CGFloat progress;

@end


@implementation GPUImageTransitionFilter


- (id)initWithType:(GPUTransitionType)type
{
    NSString *str;
    switch (type) {
        case GPUTransitionType_Doorwar:
            str = kGPUImageTransitionDoorwarFragmentShaderString;
            break;
            
        case GPUTransitionType_Heart:
            str = kGPUImageTransitionHeartFragmentShaderString;
            break;
            
        case GPUTransitionType_Cube:
            str = kGPUImageTransitionCubeFragmentShaderString;
            break;
            
        default:
            str = kGPUImageTransitionDoorwarFragmentShaderString;
            break;
    }
    
    if (!(self = [super initWithFragmentShaderFromString:str]))
    {
        return nil;
    }
    
    
    progressUniform = [filterProgram uniformIndex:@"progress"];
    self.progress = 0.0;
    
    return self;
}



- (void)setProgress:(CGFloat)newValue;
{
    _progress = newValue;
    
    [self setFloat:_progress forUniform:progressUniform program:filterProgram];
}

@end
