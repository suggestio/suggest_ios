//
//  AMSearchBar.m
//  suggest_ios
//
//  Created by Andrey Yurkevich on 11/06/12.
//  Copyright (c) 2012 CBCA. All rights reserved.
//

// This code is distributed under the terms and conditions of the MIT license.

// Copyright (c) 2012 CBCA
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

#import "AMSearchBar.h"
#import "AMSearchField.h"
#import "AMMacros.h"

@interface AMSearchBar ()

@property (nonatomic, strong, readwrite) AMSearchField *searchField;
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) NSTimer *inputTimer;
@property (nonatomic, strong) UIButton *cancelButton;

- (void) search:(NSString *)searchSubstring;
- (void) cancelSearch;

@end



@implementation AMSearchBar

// search bar edge insets
static const CGFloat kBGInsetTop    = 21.0f;
static const CGFloat kBGInsetLeft   =  1.0f;
static const CGFloat kBGInsetBottom = 21.0f;
static const CGFloat kBGInsetRight  =  1.0f;


- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)];
    if (self) {

        CGRect buttonRect = (CGRect){{self.frame.size.width + 1, 6}, {71, 32}};
        CGRect fieldRect = {{6, 6}, {self.frame.size.width - 12, 32}};

        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.autoresizesSubviews = YES;

        self.hasCancelButton = YES;

        self.blendMode = kCGBlendModeMultiply;

        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cancelButton setImage:[UIImage imageNamed:@"search_bar_cancel_btn"] forState:UIControlStateNormal];
        [self.cancelButton setImage:[UIImage imageNamed:@"search_bar_cancel_btn_pressed"] forState:UIControlStateHighlighted];
        [self.cancelButton setImage:[UIImage imageNamed:@"search_bar_cancel_btn_pressed"] forState:UIControlStateSelected];
        self.cancelButton.autoresizingMask = UIViewAutoresizingNone;
        self.cancelButton.frame = buttonRect;
        if (self.hasCancelButton) {
            [self addSubview:self.cancelButton];
            [self.cancelButton addTarget:self
                                  action:@selector(cancelButtonPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
        }

        AMSearchField *se = [[AMSearchField alloc] initWithFrame:fieldRect];
        se.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.searchField = se, se = nil;
        self.searchField.enabled = YES;
        self.searchField.userInteractionEnabled = YES;
        [self addSubview:self.searchField];
        self.searchField.delegate = self;
    }
    return self;
}


- (void) drawRect:(CGRect)rect
{
    UIImage *img = [[UIImage imageNamed:@"bar_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(kBGInsetTop, kBGInsetLeft, kBGInsetBottom, kBGInsetRight)];
    [img drawInRect:rect];
    [self.tintColor set];
    UIRectFillUsingBlendMode(rect, self.blendMode);
}


- (void) search:(NSString *)searchSubstring
{
    if (self.inputTimer)
        [self.inputTimer invalidate];

    [self.delegate searchBar:self didStartSearching:self.searchField.text];
    [self.datasource searchForSubstring:searchSubstring
                               inDomain:[self.delegate searchBarQueryDomain:self]
                           onCompletion:^(NSArray *items, NSError *error) {
                               if (error) {
                                   DLog(@"%@", error);
                               }
                               [self.delegate searchBar:self
                                        didEndSearching:searchSubstring
                                       returningResults:error ? nil : items];
                           }];
}


- (void) cancelSearch
{
    [self.datasource cancelAllSearchesInDomain:[self.delegate searchBarQueryDomain:self]];
    [self.delegate searchBarDidCancelSearch:self];
}


- (void) showsSearchActivity:(BOOL)showsActivity
{
    if (showsActivity) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 24)];
        v.backgroundColor = [UIColor clearColor];
        UIActivityIndicatorView *av = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        av.backgroundColor = [UIColor clearColor];
        [v addSubview:av];
        av.frame = CGRectMake(4, 1, 20, 20);
        self.searchField.leftView = v;
        self.searchField.leftViewMode = UITextFieldViewModeAlways;
        self.searchField.leftView.hidden = NO;
        [av performSelectorOnMainThread:@selector(startAnimating)
                             withObject:nil
                          waitUntilDone:YES];
    }
    else {
        UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_search"]];
        iv.backgroundColor = [UIColor clearColor];
        iv.contentMode = UIViewContentModeCenter;
        iv.frame = CGRectMake(0, 0, 28, 24);
        self.searchField.leftView = iv;
        self.searchField.leftViewMode = UITextFieldViewModeAlways;
    }
}


#pragma mark - 
#pragma mark Custom property accessors

- (void) setFieldStyle:(AMSearchBarFieldStyle)fieldStyle
{
    switch (fieldStyle) {
        case AMSearchBarFieldStyleOval:
            self.searchField.borderStyle = UITextBorderStyleNone;
            self.searchField.background = [[UIImage imageNamed:@"search_bar_border"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 17, 15, 17)];
            break;

        case AMSearchBarFieldStyleRoundedRect:
            self.searchField.borderStyle = UITextBorderStyleRoundedRect;
            self.searchField.background = nil;
            self.searchField.background = [[UIImage imageNamed:@"textfield_bar_border"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 17, 15, 17)];
            break;

        case AMSearchBarFieldStyleCustom:
            self.searchField.background = nil;
            self.searchField.borderStyle = UITextBorderStyleNone;

        default:
            break;
    }
    [self.searchField setNeedsDisplay];
    _fieldStyle = fieldStyle;
}


#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isKindOfClass:[AMSearchField class]]) {
        [textField resignFirstResponder];
        [self search:textField.text];
        return NO;
    }
    else {
        return YES;
    }
}


- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isKindOfClass:[AMSearchField class]]) {
        if ((textField.text.length == 0) && (range.length == 0) && (string.length > 0)) {
            [self cancelSearch];
            if (self.inputTimer)
                [self.inputTimer invalidate];
            self.inputTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                               target:self
                                                             selector:@selector(inputTimerCallback:)
                                                             userInfo:nil
                                                              repeats:NO];
        }

        else if ((textField.text.length > 0) && (range.length == textField.text.length) && (string.length == 0)) {
            if (self.inputTimer)
                [self.inputTimer invalidate];
            [self cancelSearch];
        }

        else {
            [self cancelSearch];
            if (self.inputTimer)
                [self.inputTimer invalidate];
            self.inputTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                               target:self
                                                             selector:@selector(inputTimerCallback:)
                                                             userInfo:nil
                                                              repeats:NO];
        }
    }
    return YES;
}


- (BOOL) textFieldShouldClear:(UITextField *)textField
{
    if ([textField isKindOfClass:[AMSearchField class]]) {
        if (self.inputTimer) {
            [self.inputTimer invalidate];
        }
        [self cancelSearch];
    }
    return YES;
}


- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    __block CGRect buttonRect = (CGRect){{self.frame.size.width + 1, 6}, {71, 32}};
    __block CGRect fieldRect = {{6, 6}, {self.frame.size.width - 12, 32}};

    if (self.hasCancelButton && (self.cancelButton.frame.origin.x > self.frame.size.width)) {
        if (! [self.cancelButton superview]) {
            [self addSubview:self.cancelButton];
            [self.cancelButton addTarget:self
                                  action:@selector(cancelButtonPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
        }
        self.cancelButton.frame = buttonRect;

        buttonRect.origin.x = self.frame.size.width - 76;
        fieldRect.size.width = self.frame.size.width - 88;

        [UIView animateWithDuration:0.3
                         animations:^{
                             self.searchField.frame = fieldRect;
                             self.cancelButton.frame = buttonRect;
                         }];
    }
}


#pragma mark -
#pragma mark Input timer callback

- (void) inputTimerCallback:(NSTimer *)timer
{
    DLog (@"inputTimerCallback invoked");
    NSAssert(timer == self.inputTimer, @"Invoked timer callback for an unknown NSTimer instance");

    [self search:self.searchField.text];
}

@end
