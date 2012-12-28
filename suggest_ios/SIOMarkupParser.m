//
//  SIOMarkupParser.m
//  suggest_ios
//
//  Created by Andrey Yurkevich on 10/31/12.
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

#import "SIOMarkupParser.h"
#import "SIOMacros.h"

@interface SIOMarkupParser()

@property (nonatomic, strong) NSString *font;
@property (assign) CTUnderlineStyle underlineStyle;

@end


@implementation SIOMarkupParser

-(id)init
{
    self = [super init];
    if (self) {
        self.font = SIO_DEFAULT_FONT_NAME;
        self.underlineStyle = kCTUnderlineStyleNone;
    }
    return self;
}


-(NSAttributedString *) attributedStringFromMarkup:(NSString*)strHTML
{
  if (! strHTML)
    return nil;

    NSMutableAttributedString* aString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"(.*?)(<[^>]+>|\\Z)"
                                                                      options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                                                        error:nil];
    NSArray* chunks = [regex matchesInString:strHTML
                                     options:0
                                       range:NSMakeRange(0, [strHTML length])];

    for (NSTextCheckingResult* b in chunks) {
        NSArray* parts = [[strHTML substringWithRange:b.range] componentsSeparatedByString:@"<"];
        CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef) self.font, 15.0f, NULL);

        //apply the current text style
        NSDictionary* attrs = @{ (NSString *) kCTFontAttributeName:(__bridge UIFont*)fontRef,
                                 (NSString *) kCTUnderlineStyleAttributeName:[NSNumber numberWithInt:self.underlineStyle] };

        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[parts objectAtIndex:0]
                                                                        attributes:attrs]];
        CFRelease(fontRef);

        //handle new formatting tag
        if ([parts count]>1) {
            NSString* tag = (NSString*) [parts objectAtIndex:1];
            if ([tag isEqualToString:@"em>"] || [tag isEqualToString:@"EM>"]) {
                self.underlineStyle = kCTUnderlineStyleSingle;
            }
            else if([tag hasPrefix:@"/"]) {
                self.font = SIO_DEFAULT_FONT_NAME;
                self.underlineStyle = kCTUnderlineStyleNone;
            }
        }
    }
    return (NSAttributedString*) aString;
}


-(void) dealloc
{
    self.font = nil;
}


@end
