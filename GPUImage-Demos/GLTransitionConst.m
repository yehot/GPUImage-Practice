//
//  GLTransitionConst.m
//  GPUImage-Demos
//
//  Created by yehot on 2019/5/14.
//  Copyright © 2019 Xin Hua Zhi Yun. All rights reserved.
//

#import "GLTransitionConst.h"
#import "GPUImageFilter.h"


#pragma mark - 开门效果

// opengl es 中的 glsl 支持 bool，但是：
// https://stackoverflow.com/questions/21206752/function-with-bool-return-type-in-opengl-es-shader-using-gpuimage

NSString *const kGPUImageTransitionDoorwarFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform mediump float progress;
 
 const mediump float reflection = 0.4;
 const mediump float perspective = 0.4;
 const mediump float depth = 3.0;
 
 const lowp vec4 black = vec4(0.0, 0.0, 0.0, 1.0);
 const mediump vec2 boundMin = vec2(0.0, 0.0);
 const mediump vec2 boundMax = vec2(1.0, 1.0);
 
 int inBounds (mediump vec2 p) {
     int a = 0;
     if ( all(lessThan(boundMin, p)) && all(lessThan(p, boundMax)) ) {
         a = 1;
     }
     return a;
 }
 
 
 mediump vec2 project (mediump vec2 p) {
     return vec2(( p.x), (1.0 - p.y) * -0.8) + vec2(0.0, -0.02);
 }
 
 lowp vec4 bgColor (mediump vec2 p, mediump vec2 pto) {
     lowp vec4 c = black;
     pto = project(pto);
     if (inBounds(pto) == 1) {
         mediump vec2 bg = vec2(pto.x, 1.0 -pto.y);
         c += mix(black, texture2D(inputImageTexture2, pto), reflection * mix(1.0, 0.0, pto.y));
     }
     return c;
 }
 
 lowp vec4 transition (mediump vec2 p) {
     mediump vec2 pfr = vec2(-1.);
     mediump vec2 pto = vec2(-1.);
     mediump float middleSlit = 2.0 * abs(p.x-0.5) - progress;
     if (middleSlit > 0.0) {
         pfr = p + (p.x > 0.5 ? -1.0 : 1.0) * vec2(0.5*progress, 0.0);
         mediump float d = 1.0/(1.0+perspective*progress*(1.0-middleSlit));
         pfr.y -= d/2.;
         pfr.y *= d;
         pfr.y += d/2.;
     }
     mediump float size = mix(1.0, depth, 1.-progress);
     pto = (p + vec2(-0.5, -0.5)) * vec2(size, size) + vec2(0.5, 0.5);
     if (inBounds(pfr) == 1) {
         return texture2D(inputImageTexture, pfr);
     }
     else if (inBounds(pto) == 1) {
         return texture2D(inputImageTexture2, pto);
     }
     else {
         return bgColor(p, pto);
     }
 }
 
 
 void main()
 {
     gl_FragColor = transition(textureCoordinate);
     
 }
 );

#pragma mark - 心形


NSString *const kGPUImageTransitionHeartFragmentShaderString = SHADER_STRING
(
 
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform mediump float progress;
 
 mediump float inHeart (mediump vec2 p, mediump vec2 center, mediump float size) {
     if (size==0.0) return 0.0;
     mediump vec2 o = (p-center)/(1.6*size);
     mediump float a = o.x*o.x+o.y*o.y-0.8;
     return step(a*a*a, o.x*o.x*o.y*o.y*o.y);
 }
 
 lowp vec4 transition (mediump vec2 uv) {
     return mix(
                texture2D(inputImageTexture, uv),
                texture2D(inputImageTexture2, uv),
                inHeart(vec2(uv.x, 1.0 - uv.y), vec2(0.5, 0.4), progress)
                );
 }
 
 void main()
 {
     gl_FragColor = transition(textureCoordinate);
     
 }
);


#pragma mark - cube

NSString *const kGPUImageTransitionCubeFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform mediump float progress;
 
 const mediump float persp = 0.7;
 const mediump float unzoom = 0.3;
 const mediump float reflection = 0.4;
 const mediump float floating = 3.0;
 
 mediump vec2 project (mediump vec2 p) {
     return vec2(( p.x), (1.0 - p.y) * -0.8) + vec2(0.0, -floating/100.);
 }
 
 int inBounds (mediump vec2 p) {
     int a = 0;
     if ( all(lessThan(vec2(0.0), p)) && all(lessThan(p, vec2(1.0))) ) {
         a = 1;
     }
     return a;
 }
 
 lowp vec4 bgColor (mediump vec2 p, mediump vec2 pfr, mediump vec2 pto) {
     lowp vec4 c = vec4(0.0, 0.0, 0.0, 1.0);
     pfr = project(pfr);
     // FIXME avoid branching might help perf!
     if (inBounds(pfr) == 1) {
         mediump vec2 tmp = vec2(pfr.x, 1.0 - pfr.y);
         c += mix(vec4(0.0), texture2D(inputImageTexture, tmp), reflection * mix(1.0, 0.0, pfr.y));
     }
     pto = project(pto);
     if (inBounds(pto) == 1) {
         mediump vec2 tmp = vec2(pto.x, 1.0 - pto.y);
         c += mix(vec4(0.0), texture2D(inputImageTexture2, tmp), reflection * mix(1.0, 0.0, pto.y));
     }
     return c;
 }
 
 // p : the position
 // persp : the perspective in [ 0, 1 ]
 // center : the xcenter in [0, 1] \ 0.5 excluded
 mediump vec2 xskew (mediump vec2 p, mediump float persp, mediump float center) {
     mediump float x = mix(p.x, 1.0-p.x, center);
     return (
             (
              vec2( x, (p.y - 0.5*(1.0-persp) * x) / (1.0+(persp-1.0)*x) )
              - vec2(0.5-distance(center, 0.5), 0.0)
              )
             * vec2(0.5 / distance(center, 0.5) * (center<0.5 ? 1.0 : -1.0), 1.0)
             + vec2(center<0.5 ? 0.0 : 1.0, 0.0)
             );
 }
 
 lowp vec4 transition(mediump vec2 op) {
     mediump float uz = unzoom * 2.0*(0.5-distance(0.5, progress));
     mediump vec2 p = -uz*0.5+(1.0+uz) * op;
     mediump vec2 fromP = xskew(
                        (p - vec2(progress, 0.0)) / vec2(1.0-progress, 1.0),
                        1.0-mix(progress, 0.0, persp),
                        0.0
                        );
     mediump vec2 toP = xskew(
                      p / vec2(progress, 1.0),
                      mix(pow(progress, 2.0), 1.0, persp),
                      1.0
                      );
     // FIXME avoid branching might help perf!
     if (inBounds(fromP) == 1) {
         return texture2D(inputImageTexture, fromP);
     }
     else if (inBounds(toP) == 1) {
         return texture2D(inputImageTexture2, toP);
     }
     return bgColor(op, fromP, toP);
 }

 void main()
 {
     gl_FragColor = transition(textureCoordinate);
     
 }
);

