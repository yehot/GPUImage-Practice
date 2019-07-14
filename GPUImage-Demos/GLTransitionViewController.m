//
//  GLTransitionViewController.m
//  GPUImage-Demos
//
//  Created by yehot on 2019/5/14.
//  Copyright © 2019 Xin Hua Zhi Yun. All rights reserved.
//

#import "GLTransitionViewController.h"
#import <Masonry/Masonry.h>
#import <GPUImage.h>
#import "GPUImageTransitionFilter.h"

@interface GLTransitionViewController ()

@property (strong, nonatomic) GPUImageView *gpuImageView;
//@property (weak, nonatomic) IBOutlet GPUImageView *contentView;

@property (weak, nonatomic) IBOutlet UISlider *progressSilder;

@property (nonatomic, strong) GPUImageTransitionFilter *filter;

@property (nonatomic, strong) GPUImagePicture *picture1;
@property (nonatomic, strong) GPUImagePicture *picture2;

@end

@implementation GLTransitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    [self test1];
}

- (void)test1 {
    self.gpuImageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 500)];
    self.gpuImageView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.gpuImageView];
    
    
    UIImage *img1 = [UIImage imageNamed:@"img1.jpg"];
    UIImage *img2 = [UIImage imageNamed:@"img2.jpg"];
    GPUImagePicture *picture1 = [[GPUImagePicture alloc] initWithImage:img1];
    GPUImagePicture *picture2 = [[GPUImagePicture alloc] initWithImage:img2];
    self.picture1 = picture1;
    self.picture2 = picture2;
    
    self.filter = [[GPUImageTransitionFilter alloc] initWithType:GPUTransitionType_Cube];
    [self.filter setProgress:0.5];
    
    [picture1 addTarget:self.filter];
    [picture2 addTarget:self.filter];
    
    [self.filter addTarget:self.gpuImageView];
    
    // 为什么必须要 useNextFrameForImageCapture，作用是什么？？
    [self.filter useNextFrameForImageCapture];
    [picture1 processImage];
    [picture2 processImage];
    
    UIImage *img = [self.filter imageFromCurrentFramebuffer];
    NSLog(@"%@", img);
}

- (IBAction)silder:(UISlider *)sender {
    
//    NSLog(@"----- %f", sender.value);
    
    [self.filter setProgress:sender.value];
    
    // 在 修改了 filter 的值时，动态更新 GPUImageView，只用更新 filter
    [self.filter useNextFrameForImageCapture];
    [self.picture1 processImage];
    [self.picture2 processImage];
}


- (void)test2 {
    UIImage *img1 = [UIImage imageNamed:@"img1.jpg"];
    UIImage *img2 = [UIImage imageNamed:@"img2.jpg"];
    
    GPUImagePicture *pic1 = [[GPUImagePicture alloc] initWithImage:img1];
    GPUImagePicture *pic2 = [[GPUImagePicture alloc] initWithImage:img2];
    
    GPUImageOverlayBlendFilter *filter = [[GPUImageOverlayBlendFilter alloc] init];

    [pic1 addTarget:filter];
    [pic2 addTarget:filter];
    
    // 使用静态图片时，在输出前，必须调用 useNextFrameForImageCapture ，否则没有画面
    [filter useNextFrameForImageCapture];
    [pic1 processImage];
    [pic2 processImage];
    
    UIImage *blendedImage = [filter imageFromCurrentFramebuffer];
    NSLog(@"%@", blendedImage);
}


- (void)test3 {
    
    UIImage *img1 = [UIImage imageNamed:@"img1.jpg"];
    
    GPUImagePicture *picture1 = [[GPUImagePicture alloc] initWithImage:img1 smoothlyScaleOutput:YES];
    
    GPUImageSketchFilter *filter = [[GPUImageSketchFilter alloc] init];
    
    [picture1 addTarget:filter];
    
    // 创建ImageView输出组件
    GPUImageView *imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 500)];
    [self.view addSubview:imageView];
    
    [filter addTarget:imageView];
    
    // 单个 input 输入时，只需要 processImage ，就绘制到了 GPUImageView 上，不需要 [filter imageFromCurrentFramebuffer]
    [picture1 processImage];
}

@end
