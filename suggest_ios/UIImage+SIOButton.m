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


#import "UIImage+SIOButton.h"

@implementation UIImage (SIOButton)

//
// create a CGImageMask from UIImage. This method returns a retained instance of CGImageMask,
// so make sure to CGImageRelease() it after use!
//

static CGImageRef createMaskWithImage(CGImageRef image)
{
    int maskWidth = CGImageGetWidth(image);
    int maskHeight = CGImageGetHeight(image);
    //  round bytesPerRow to the nearest 16 bytes, for performance's sake
    int bytesPerRow = (maskWidth + 15) & 0xfffffff0;
    int bufferSize = bytesPerRow * maskHeight;

    //  we use CFData instead of malloc(), because the memory has to stick around
    //  for the lifetime of the mask. if we used malloc(), we'd have to
    //  tell the CGDataProvider how to dispose of the memory when done. using
    //  CFData is just easier and cleaner.

    CFMutableDataRef dataBuffer = CFDataCreateMutable(kCFAllocatorDefault, 0);
    CFDataSetLength(dataBuffer, bufferSize);

    //  the data will be 8 bits per pixel, no alpha
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef ctx = CGBitmapContextCreate(CFDataGetMutableBytePtr(dataBuffer),
                                             maskWidth,
                                             maskHeight,
                                             8,
                                             bytesPerRow,
                                             colorSpace,
                                             kCGImageAlphaNone);
    //  drawing into this context will draw into the dataBuffer.
    CGContextDrawImage(ctx, CGRectMake(0, 0, maskWidth, maskHeight), image);
    CGContextRelease(ctx);

    //  now make a mask from the data.
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(dataBuffer);
    CGImageRef mask = CGImageMaskCreate(maskWidth,
                                        maskHeight,
                                        8,
                                        8,
                                        bytesPerRow,
                                        dataProvider,
                                        NULL,
                                        FALSE);

    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(colorSpace);
    CFRelease(dataBuffer);

    return mask;
}

- (UIImage *) btnImageWithText:(NSString *)captionText font:(UIFont *)font textColor:(UIColor *)color tintColor:(UIColor *)tintColor
{
    UIImage *btnImage;
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);

    // render the image
    [self drawInRect:(CGRect){{0.0, 0.0}, [self size]}];

    // apply tint
    [tintColor set];
    UIRectFillUsingBlendMode((CGRect){{0.0, 0.0}, [self size]}, kCGBlendModeMultiply);

    CGSize captionSize = [captionText sizeWithFont:font
                                 constrainedToSize:self.size];
    CGRect captionRect = CGRectMake(ceilf((self.size.width - captionSize.width) / 2.0),
                                    ceilf((self.size.height - captionSize.height) / 2.0),
                                    ceilf(captionSize.width),
                                    ceilf(captionSize.height));

    [color set];
    [captionText drawInRect:captionRect withFont:font];

    // Fetch the image
    btnImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    // apply mask:
    CGImageRef maskImageRef = createMaskWithImage([UIImage imageNamed:@"button_mask_inverse"].CGImage);
    UIImage *img = [UIImage imageWithCGImage:CGImageCreateWithMask(btnImage.CGImage, maskImageRef)];
    CGImageRelease(maskImageRef);
    return img;
}

+ (UIImage *) buttonImageWithText:(NSString *)captionText font:(UIFont *)font textColor:(UIColor *)color tintColor:(UIColor *)tintColor
{
    UIImage *btnImage = [UIImage imageNamed:@"button"];
    return [btnImage btnImageWithText:captionText font:font textColor:color tintColor:tintColor];
}

+ (UIImage *) pressedButtonImageWithText:(NSString *)captionText font:(UIFont *)font textColor:(UIColor *)color tintColor:(UIColor *)tintColor
{
    UIImage *btnImage = [UIImage imageNamed:@"button_pressed"];
    return [btnImage btnImageWithText:captionText font:font textColor:color tintColor:tintColor];
}


@end
