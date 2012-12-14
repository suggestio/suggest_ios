//
//  SIOSearchField.m
//  suggest_ios
//
//  Created by Andrey Yurkevich on 10/23/12.
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

#import "SIOSearchField.h"

@implementation SIOSearchField

static const int kMarginX = 3;
static const int kMarginY = 0;


- (id) initWithFrame:(CGRect)frame style:(SIOSearchBarFieldStyle)fs
{
    self = [super initWithFrame:frame];
    if (self) {
        self.fieldStyle = fs;

        self.font = [UIFont systemFontOfSize:15];
        self.keyboardAppearance = UIKeyboardAppearanceDefault;
        self.keyboardType = UIKeyboardTypeDefault;
        self.returnKeyType = UIReturnKeySearch;
        self.clearButtonMode = UITextFieldViewModeAlways;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

        UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_search"]];
        iv.frame = CGRectMake(0, 0, 28, 24);
        iv.contentMode = UIViewContentModeCenter;
        iv.backgroundColor = [UIColor clearColor];
        self.leftView = iv, iv = nil;
        self.leftViewMode = UITextFieldViewModeAlways;

        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }
    return self;
}


- (void) setFieldStyle:(SIOSearchBarFieldStyle)fs
{
    switch (fs) {
        case SIOSearchBarFieldStyleOval:
            self.borderStyle = UITextBorderStyleNone;
            self.background = [[UIImage imageNamed:@"search_bar_border"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 17, 15, 17)];
            break;

        case SIOSearchBarFieldStyleRoundedRect:
            self.borderStyle = UITextBorderStyleRoundedRect;
            self.background = nil;
            self.background = [[UIImage imageNamed:@"textfield_bar_border"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 17, 15, 17)];
            break;

        case SIOSearchBarFieldStyleCustom:
            self.background = nil;
            self.borderStyle = UITextBorderStyleNone;

        default:
            break;
    }

    if (self.superview)
        [self setNeedsDisplay];
}


- (CGRect) textRectForBounds:(CGRect)bounds
{
    CGRect inset = [super textRectForBounds:bounds];
    if (self.fieldStyle == SIOSearchBarFieldStyleOval) {
        inset.origin.y += kMarginY;
        inset.origin.x += kMarginX;
    }
    return inset;
}


- (CGRect) editingRectForBounds:(CGRect)bounds
{
    CGRect inset = [super editingRectForBounds:bounds];
    if (self.fieldStyle == SIOSearchBarFieldStyleOval) {
        inset.origin.y += kMarginY;
        inset.origin.x += kMarginX;
    }
    return inset;
}


@end
