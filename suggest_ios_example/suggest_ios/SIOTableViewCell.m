//
//  SIOTableViewCell.m
//  suggest_ios
//
//  Created by Andrey Yurkevich on 12/12/12.
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

#import "SIOTableViewCell.h"
#import "NSAttributedString+SIO.h"

@interface SIOTableViewCell ()

@property (nonatomic, copy) NSAttributedString *title;
@property (nonatomic, copy) NSAttributedString *content;
@property (nonatomic, strong) UIImage *resultImage;
@property (nonatomic, strong) UIImageView *resultImageView;

@end

#define kImageWidth 50.0f
#define kImageHeight 70.0f
#define kImageScale [[UIScreen mainScreen] scale]
#define kResultImageSize (CGSize){kImageWidth * kImageScale, kImageHeight * kImageScale}

@implementation SIOTableViewCell

static const CGFloat kCellWidth = 320.0;
static const CGFloat kParagraphSpacing = 3.0;
static const CGFloat kLineSpacing = 0.0;

#define AM_SIO_TITLE_FONT   [UIFont fontWithName:@"Helvetica-Bold" size:15.0]
#define AM_SIO_CONTENT_FONT [UIFont fontWithName:@"Helvetica" size:15.0]

+ (CGFloat) cellHeightForSearchResult:(SIOSearchResult *)entry
{
    CGFloat bodyTextWidth = kCellWidth;
    CGFloat height = 0;

    if (entry.imageURL)
        bodyTextWidth -= 60;


    height += [entry.title sizeToFitForWidth:kCellWidth
                                    withFont:AM_SIO_TITLE_FONT
                                   alignment:kCTLeftTextAlignment].height;
    if (entry.imageURL) {
        height += MAX([entry.content sizeToFitForWidth:bodyTextWidth
                                              withFont:AM_SIO_CONTENT_FONT
                                             alignment:kCTLeftTextAlignment].height,
                      80.0f);

    }
    else {
        height += [entry.content sizeToFitForWidth:bodyTextWidth
                                          withFont:AM_SIO_CONTENT_FONT
                                         alignment:kCTLeftTextAlignment].height;
    }
    return height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
