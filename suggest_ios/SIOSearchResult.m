//
//  SIOSearchResult.m
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

#import "SIOSearchResult.h"
#import "SIOMarkupParser.h"

@interface SIOSearchResult ()

@property (nonatomic, copy, readwrite) NSAttributedString *content;
@property (nonatomic, copy, readwrite) NSAttributedString *title;
@property (nonatomic, copy, readwrite) NSURL *url;
@property (nonatomic, copy, readwrite) NSURL *imageURL;

@end


@implementation SIOSearchResult

- (id) initWithJSON:(NSDictionary *)JSONDict
{
    self = [super init];
    if (self) {
        SIOMarkupParser* p = [[SIOMarkupParser alloc] init];

        if ([[JSONDict valueForKey:@"content_text"] isKindOfClass:[NSArray class]]) {
            NSMutableString *strContentText = [NSMutableString string];
            for (NSString *str in [JSONDict valueForKey:@"content_text"]) {
                [strContentText appendString:str];
            }
            self.content = [p attributedStringFromMarkup:strContentText];
        }
        else
            self.content = [p attributedStringFromMarkup:[JSONDict valueForKey:@"content_text"]];

        if ([[JSONDict valueForKey:@"title"] isKindOfClass:[NSArray class]]) {
            NSMutableString *strTitleText = [NSMutableString string];
            for (NSString *str in [JSONDict valueForKey:@"title"]) {
                [strTitleText appendString:str];
            }
            self.title = [p attributedStringFromMarkup:strTitleText];
        }
        else
            self.title = [p attributedStringFromMarkup:[JSONDict valueForKey:@"title"]];

        if ([JSONDict valueForKey:@"url"]) {
            self.url = [NSURL URLWithString:[JSONDict valueForKey:@"url"]];
        }

        if ([JSONDict valueForKey:@"image_rel_url"]) {
            self.imageURL = [NSURL URLWithString:[JSONDict valueForKey:@"image_rel_url"]
                                   relativeToURL:[NSURL URLWithString:@"https://suggest.io/"]]; 
        }
        else {
            self.imageURL = nil;
        }
    }
    return self;
}


- (NSString *) description
{
    return [NSString stringWithFormat:@"%@: url=%@, title=%@, content=%@", [super description], [self.url absoluteString], [self.title description], [self.content description]];
}


@end
