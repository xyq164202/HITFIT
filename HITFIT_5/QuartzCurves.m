/*
     File: QuartzCurves.m
 Abstract: Demonstrates using Quartz to draw ellipses & arcs (QuartzEllipseArcView) and bezier & quadratic curves (QuartzBezierView).
  Version: 3.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
*/
#import "QuartzCurves.h"

@implementation QuartzEllipseArcView
@synthesize steps;

-(void)drawInContext:(CGContextRef)context
{
	// Drawing with a white stroke color
	CGContextSetRGBStrokeColor(context, 51.0/255, 204.0/255, 204.0/255, 1.0);
	// And draw with a blue fill color
	CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
	// Draw them with a 4.0 stroke width so they are a bit more visible.
	CGContextSetLineWidth(context, 4.0);
	
	// 画仪表盘轮廓
	CGContextAddArc(context, 160.0, 164.0, 130.0, 3.0*M_PI/4.0, M_PI/4.0, false);
    CGContextStrokePath(context);
    
    //画黄色的仪表盘，表示已经走的步数
    [self drawStepsOfAllWithContext:context currentSteps: steps];
//    CGContextSetRGBStrokeColor(context, 247.0/255, 207.0/255, 36.0/255, 1.0);
//    CGContextSetLineWidth(context, 12.0);
//    CGContextSetLineCap(context, kCGLineCapRound);
//    CGContextAddArc(context, 160.0, 164.0, 130.0, 3.0*M_PI/4.0, (3+6*0.6 /* x 计步百分比*/ )*M_PI/4.0, false);
//    CGContextStrokePath(context);
    
    //画仪表盘开头和结尾刻度0 ，10000
    UILabel * progressStartLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 264, 20,12)];
    progressStartLabel.text = @"0";
    UILabel * progressEndLabel = [[UILabel alloc] initWithFrame:CGRectMake(231, 264, 80,12)];
    progressEndLabel.text = @"10000";
    [self addSubview:progressStartLabel];
    [self addSubview:progressEndLabel];
}

-(void)drawStepsOfAllWithContext:(CGContextRef)context currentSteps:(NSString *)step
{
    NSLog(@"start draw steps.");
    //画黄色的仪表盘，表示已经走的步数
    CGContextSetRGBStrokeColor(context, 247.0/255, 207.0/255, 36.0/255, 1.0);
    CGContextSetLineWidth(context, 12.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    if (step) {
        NSLog(@"drawing");
        CGContextAddArc(context, 160.0, 164.0, 130.0, 3.0*M_PI/4.0, (3+6*([step floatValue] / 10000.0) /* x 计步百分比*/ )*M_PI/4.0, false);
    }
    CGContextStrokePath(context);
}

@end