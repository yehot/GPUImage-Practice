//
//  GPUImageTransitionFilter.h
//  FilterShowcase
//
//  Created by yehot on 2019/1/3.
//  Copyright © 2019年 Cell Phone. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

typedef enum {
    GPUTransitionType_Doorwar,
    GPUTransitionType_Heart,
    GPUTransitionType_Cube,
} GPUTransitionType;

@interface GPUImageTransitionFilter : GPUImageTwoInputFilter

- (id)initWithType:(GPUTransitionType)type;

- (void)setProgress:(CGFloat)newValue;


@end
