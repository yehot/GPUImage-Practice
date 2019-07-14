//
//  RawDataViewController.m
//  GPUImage-Demos
//
//  Created by yehot on 2019/7/11.
//  Copyright © 2019 Xin Hua Zhi Yun. All rights reserved.
//

#import "RawDataViewController.h"
#import "GPUImage.h"

@interface RawDataViewController ()

@property (nonatomic, strong) GPUImageRawDataInput *rawDataInput;
@property (nonatomic, strong) GPUImageRawDataOutput *rawDataOutput;

@property (nonatomic, strong) GPUImageBrightnessFilter *filter;
@property (nonatomic, strong) GPUImageView *filterView;

@end

@implementation RawDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.filterView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 300)];
    [self.view addSubview:self.filterView];
    
    
    // 1. UIImage -> CGImage -> CFDataRef -> UInt8 * data
    UIImage *image = [UIImage imageNamed:@"img1.jpg"];
    CGImageRef newImageSource = [image CGImage];
    CFDataRef dataFromImageDataProvider = CGDataProviderCopyData(CGImageGetDataProvider(newImageSource));
    GLubyte* imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
    
    // 2. UInt8 * data -> GPUImageRawDataInput
    self.rawDataInput = [[GPUImageRawDataInput alloc] initWithBytes:imageData size:image.size pixelFormat:GPUPixelFormatRGBA];
    
    self.filter = [[GPUImageBrightnessFilter alloc] init];
    self.filter.brightness = 0.1;
    

    [self.rawDataInput addTarget:self.filter];
    // 3. 输出到 GPUImageView
    [self.filter addTarget:self.filterView];

    
    // 4. 同时输出到 raw data output
    self.rawDataOutput = [[GPUImageRawDataOutput alloc] initWithImageSize:image.size resultsInBGRAFormat:YES];
    [self.filter addTarget:self.rawDataOutput];
    
    // important
    [self.filter useNextFrameForImageCapture];
    [self.rawDataInput processData];
    
    
    // 5. read data from GPUImageRawDataOutput
    [self.rawDataOutput lockFramebufferForReading];
    
    GLubyte *outputBytes = [self.rawDataOutput rawBytesForImage];
    NSInteger bytesPerRow = [self.rawDataOutput bytesPerRowInOutput];

    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, outputBytes, bytesPerRow * image.size.height, NULL);
    CGImageRef cgImage = CGImageCreate(image.size.width, image.size.height, 8, 32, bytesPerRow, rgbColorSpace, kCGImageAlphaPremultipliedFirst|kCGBitmapByteOrder32Little, provider, NULL, true, kCGRenderingIntentDefault);
    
    [self.rawDataOutput unlockFramebufferAfterReading];

    // 断点到这一行，查看 outImage
    UIImage *outImage = [UIImage imageWithCGImage:cgImage];
    NSLog(@"%@", outImage);
    

    
    // debug filter 的输出的一个方法:
//    UIImage *img = [self.filter imageFromCurrentFramebuffer];
//    NSLog(@"%@", img);
}


@end
