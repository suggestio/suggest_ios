//
//  UIColor+AMUtils.m
//  suggest_ios
//
//  Created by Andrey Yurkevich on 8/22/12.
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

#import "UIColor+AMUtils.h"

static void rgb2hsv (CGFloat r, CGFloat g, CGFloat b, CGFloat* h, CGFloat* s, CGFloat* v);
static void hsv2rgb (CGFloat h, CGFloat s, CGFloat v, CGFloat* r, CGFloat* g, CGFloat* b);

@implementation UIColor (AMUtils)

+ (UIColor *) colorWithHTMLColor:(NSUInteger)htmlColor
{
    CGFloat xR = (CGFloat) ((NSUInteger) (htmlColor & 0xff0000) >> 16);
    CGFloat xG = (CGFloat) ((NSUInteger) (htmlColor & 0x00ff00) >> 8);
    CGFloat xB = (CGFloat) ((NSUInteger) htmlColor & 0x0000ff);
    
    UIColor *c = [UIColor colorWithRed:xR/255.0 green:xG/255.0 blue:xB/255.0 alpha:1.0];
    return c;
}


- (UIColor *)adjustBrightness:(CGFloat)adjustment
{

    if (adjustment == 0) {
        return self;
    }
    else {
        CGFloat r, g, b, a;
        CGFloat h, s, v;

        [self getRed:&r green:&g blue:&b alpha:&a];
        rgb2hsv(r, g, b, &h, &s, &v);

        v *= adjustment;
        if (v < 0.0)
            v = 0.0;
        else if (v > 1.0)
            v = 1.0;

        hsv2rgb(h, s, v, &r, &g, &b);
        return [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
}

#pragma mark -
#pragma mark Conversion to/from HSV

static void rgb2hsv (CGFloat r, CGFloat g, CGFloat b, CGFloat *h, CGFloat *s, CGFloat *v)
{
    CGFloat min, max, delta;
    min = MIN(r, MIN(g, b));
    max = MAX(r, MAX(g, b));
    *v = max; // v
    delta = max - min;
    if (max != 0)
        *s = delta / max;       // s
    else {
        // r = g = b = 0        // s = 0, v is undefined
        *s = 0;
        *h = -1;
        return;
    }
    if (r == max)
        *h = (g - b) / delta;     // between yellow & magenta
    else if (g == max)
        *h = 2 + (b - r) / delta; // between cyan & yellow
    else
        *h = 4 + (r - g) / delta; // between magenta & cyan
    *h *= 60;               // degrees
    if( *h < 0 )
        *h += 360;
    *h /= 360.0;
}


static void hsv2rgb (CGFloat h, CGFloat s, CGFloat v, CGFloat* r, CGFloat* g, CGFloat* b)
{
    int i;
    CGFloat f, p, q, t;
    if (s == 0) {
        // achromatic (grey)
        *r = *g = *b = v;
        return;
    }
    if (h == 1.0)
        h = 0.0;
    else
        h *= 6;            // sector 0 to 5
    i = floor (h);
    f = h - i;          // factorial part of h
    p = v * (1 - s);
    q = v * (1 - s * f);
    t = v * (1 - s * (1 - f));
    switch (i) {
        case 0:
            *r = v;
            *g = t;
            *b = p;
            break;

        case 1:
            *r = q;
            *g = v;
            *b = p;
            break;

        case 2:
            *r = p;
            *g = v;
            *b = t;
            break;

        case 3:
            *r = p;
            *g = q;
            *b = v;
            break;

        case 4:
            *r = t;
            *g = p;
            *b = v;
            break;

        default:        // case 5:
            *r = v;
            *g = p;
            *b = q;
            break;
    }
}


@end
