//
//  UIImage+SIO.m
//  ldpr-ios
//
//  Created by Andrey Yurkevich on 12/03/12.
//  Copyright (c) 2012 Suggest.io. All rights reserved.
//

// This code is distributed under the terms and conditions of the MIT license.

// Copyright (c) 2012 Suggest.io
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "UIImage+SIO.h"

@implementation UIImage (SIO)

- (UIImage *) imageWithTextCaption:(NSString *)caption font:(UIFont *)font color:(UIColor *)color
{
    DLog(@"%@", caption);
    // create a new CGContext
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
//    CGContextRef context = UIGraphicsGetCurrentContext();

    // render the image
    [self drawInRect:(CGRect){{0.0, 0.0}, [self size]}];

    // render the caption
    UIFont *actualFont = [font fontWithSize:font.pointSize * [[UIScreen mainScreen] scale]];

    [color set];
    CGSize captionSize = [caption sizeWithFont:actualFont
                             constrainedToSize:self.size];
    CGRect captionRect = CGRectMake(ceilf((self.size.width - captionSize.width) / 2.0),
                                    ceilf((self.size.height - captionSize.height) / 2.0),
                                    captionSize.width,
                                    captionSize.height);

    [color set];
    [caption drawInRect:captionRect withFont:actualFont];

    // Fetch the image
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();

    // Cleanup
    UIGraphicsEndImageContext();

    return renderedImage;
}


- (UIImage *) imageWithTintColor:(UIColor *)color blendMode:(CGBlendMode)blendMode
{
    // create a new CGContext
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);

    // render the image
    [self drawInRect:(CGRect){{0.0, 0.0}, [self size]}];

    // apply tint
    [color set];
    UIRectFillUsingBlendMode((CGRect){{0.0, 0.0}, [self size]}, blendMode);

    // fetch resulting image
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();

    // Cleanup
    UIGraphicsEndImageContext();

    return [renderedImage roundedCornerImage:6];
}


// Adds a rectangular path to the given context and rounds its corners by the given extents
// Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/
- (void)addRoundedRectToPath:(CGRect)rect context:(CGContextRef)context ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight
{
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    CGFloat fw = CGRectGetWidth(rect) / ovalWidth;
    CGFloat fh = CGRectGetHeight(rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}


// Creates a copy of this image with rounded corners
// If borderSize is non-zero, a border of the given size will also be added
// If borderColor is not nil, a border of given color will be added, otherwise the border will be transparent.
// Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize// borderSize:(NSInteger)borderSize borderColor:(UIColor *)borderColor
{
    UIImage *image = self;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 image.size.width,
                                                 image.size.height,
                                                 CGImageGetBitsPerComponent(image.CGImage),
                                                 0,
                                                 CGImageGetColorSpace(image.CGImage),
                                                 CGImageGetBitmapInfo(image.CGImage));

    // Create a clipping path with rounded corners
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGContextBeginPath(context);
    CGRect clippingRectBordered = (CGRect){ {0.0f, 0.0f}, image.size};

    [self addRoundedRectToPath:clippingRectBordered
                       context:context
                     ovalWidth:cornerSize * scale
                    ovalHeight:cornerSize * scale];
    CGContextClosePath(context);
    CGContextClip(context);

    // Draw the image to the context; the clipping path will make anything outside the rounded rect transparent
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);

    // Create a CGImage from the context
    CGImageRef clippedImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);

    // Create a UIImage from the CGImage
    UIImage *roundedImage = [UIImage imageWithCGImage:clippedImage];
    CGImageRelease(clippedImage);

    return roundedImage;
}



@end
