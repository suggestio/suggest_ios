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
#import "UIImage+SIO.h"
#import "UIColor+SIO.h"


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

static const CGFloat kCellWidth = 300.0;
static const CGFloat kParagraphSpacing = 3.0;
static const CGFloat kLineSpacing = 0.0;

#define SIO_TITLE_FONT   [UIFont fontWithName:@"Helvetica-Bold" size:15.0]
#define SIO_CONTENT_FONT [UIFont fontWithName:@"Helvetica" size:15.0]

+ (CGFloat) cellHeightForSearchResult:(SIOSearchResult *)entry
{
    CGFloat bodyTextWidth = kCellWidth;
    CGFloat height = 0;

    if (entry.imageURL)
        bodyTextWidth -= (kImageWidth + 10.0);


    height += [entry.title sizeToFitForWidth:kCellWidth
                                    withFont:SIO_TITLE_FONT
                                   alignment:kCTLeftTextAlignment].height;
    if (entry.imageURL) {
        height += MAX([entry.content sizeToFitForWidth:bodyTextWidth
                                              withFont:SIO_CONTENT_FONT
                                             alignment:kCTLeftTextAlignment].height,
                      kImageHeight + 10.0);

    }
    else {
        height += [entry.content sizeToFitForWidth:bodyTextWidth
                                          withFont:SIO_CONTENT_FONT
                                         alignment:kCTLeftTextAlignment].height;
    }
    return height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.searchResultEntry = nil;
        self.title = nil;
        self.content = nil;
        self.resultImage = nil;
        self.resultImageView = [[UIImageView alloc] initWithFrame:(CGRect){{0, 0}, {50, 70}}];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSearchResultEntry:(SIOSearchResult *)e
{
    _searchResultEntry = e;
    self.title = self.searchResultEntry.title;
    self.content = self.searchResultEntry.content;

    if (self.searchResultEntry.imageURL) {
        dispatch_queue_t callerQueue = dispatch_get_current_queue();
        dispatch_queue_t downloadQueue = dispatch_queue_create("suggest.io_download_q", NULL);
        dispatch_async(downloadQueue, ^{
            NSURLRequest *req = [NSURLRequest requestWithURL:self.searchResultEntry.imageURL
                                                 cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                             timeoutInterval:10.0];
            NSData *imageData = [NSURLConnection sendSynchronousRequest:req
                                                      returningResponse:nil
                                                                  error:nil];
            if (imageData) {
                UIImage *img = [UIImage imageWithData:imageData];

                img = [img resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                                                bounds:kResultImageSize
                                  interpolationQuality:kCGInterpolationDefault];
                CGFloat yOff = fabsf(kResultImageSize.height - img.size.height) / 2.0f;
                CGFloat xOff = fabsf(kResultImageSize.width - img.size.width) / 2.0f;
                self.resultImage = [[img croppedImage:(CGRect){{xOff, yOff}, kResultImageSize}] applyMask:[UIImage imageNamed:@"mask50x70"]];
                dispatch_async(callerQueue, ^{
                    [self setNeedsDisplay];
                });
            }
        });
    }
    else {
        self.resultImage = nil;
        self.resultImageView.image = nil;
        [self.resultImageView removeFromSuperview];
        [self setNeedsDisplay];
    }
}


- (void)drawRect:(CGRect)rect
{
    @autoreleasepool {
        CGFloat bodyTextWidth = kCellWidth;
        if (self.searchResultEntry.imageURL)
            bodyTextWidth -= 60.0;


        CGFloat titleHeight = [self.title sizeToFitForWidth:kCellWidth
                                                   withFont:SIO_TITLE_FONT
                                                  alignment:kCTLeftTextAlignment].height;
        CGFloat contentHeight = [self.content sizeToFitForWidth:bodyTextWidth
                                                       withFont:SIO_CONTENT_FONT
                                                      alignment:kCTLeftTextAlignment].height;

        CGRect titleRect = (CGRect) {{10.0f, 0.0f}, {300.0f, titleHeight}};
        CGRect contentRect = (CGRect) {{10.0f, 0.0f - titleHeight }, {300.0f, contentHeight}};

        if (self.searchResultEntry.imageURL) {
            contentRect.origin.x += 60.0f;
            contentRect.size.width -= 60.0f;
        }

        if (self.resultImage) {
            if (! self.resultImageView.superview) {
                self.resultImageView.frame = (CGRect){{10, titleHeight + 10}, {50, 70}};
                [self.contentView addSubview:self.resultImageView];
                self.resultImageView.image = self.resultImage;
            }
            else {
                self.resultImageView.frame = (CGRect){{10, titleHeight + 10}, {50, 70}};
            }
        }

        [self.title renderInRect:titleRect
                        withFont:SIO_TITLE_FONT
                           color:[UIColor colorWithHTMLColor:0xFF000099]
                       alignment:kCTLeftTextAlignment];

        [self.content renderInRect:contentRect
                          withFont:SIO_CONTENT_FONT
                             color:[UIColor colorWithHTMLColor:0xFF666666]
                         alignment:kCTLeftTextAlignment];
    }
}


@end
