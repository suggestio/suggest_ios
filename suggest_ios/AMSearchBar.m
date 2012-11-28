//
//  AMSearchBar.m
//  suggest_ios
//
//  Created by Andrey Yurkevich on 11/06/12.
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

#import "AMSearchBar.h"
#import "AMMacros.h"

@interface AMSearchBar ()

@property (nonatomic, strong, readwrite) AMSearchField *searchField;
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) NSTimer *inputTimer;
@property (nonatomic, strong) UIButton *cancelButton;

- (void) search:(NSString *)searchSubstring;
- (void) cancelSearch;
- (void) cancelButtonPressed:(id)sender;

@end



@implementation AMSearchBar

// search bar edge insets
static const CGFloat kBGInsetTop    = 21.0f;
static const CGFloat kBGInsetLeft   =  1.0f;
static const CGFloat kBGInsetBottom = 21.0f;
static const CGFloat kBGInsetRight  =  1.0f;


- (id) initWithStyle:(AMSearchBarFieldStyle)fs rect:(CGRect)rect
{
    CGRect initRect;
    if (CGRectEqualToRect(rect, CGRectZero))
        initRect = (CGRectMake(0, 0, 320, 44));
    else
        initRect = rect;

    self = [super initWithFrame:initRect];

    if (self) {

        CGRect buttonRect = (CGRect){{self.frame.size.width + 1, ceilf((self.frame.size.height - 32) / 2)}, {71, 32}};
        CGRect fieldRect = (CGRect){{6, ceilf((self.frame.size.height - 32) / 2)}, {self.frame.size.width - 12, 32}};

        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
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

        AMSearchField *se = [[AMSearchField alloc] initWithFrame:fieldRect style:fs];
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

    if ([self.delegate respondsToSelector:@selector(searchBar:didStartSearching:)]) {
        [self.delegate searchBar:self didStartSearching:self.searchField.text];
    }
    [self.datasource searchForSubstring:searchSubstring
                               inDomain:[self.delegate searchBarQueryDomain:self]
                           onCompletion:^(NSArray *items, NSError *error) {
                               if (error) {
                                   DLog(@"%@", error);
                               }
//                               if ([self.delegate respondsToSelector:@selector(searchBar:didEndSearchig:returningResults:)]) {
                                   [self.delegate searchBar:self
                                            didEndSearching:searchSubstring
                                           returningResults:error ? nil : items];
//                               }
                           }];
}


- (void) cancelSearch
{
    [self.datasource cancelAllSearchesInDomain:[self.delegate searchBarQueryDomain:self]];
    if ([self.delegate respondsToSelector:@selector(searchBarDidCancelSearch:)]) {
        [self.delegate searchBarDidCancelSearch:self];
    }
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
    __block CGRect buttonRect = (CGRect){{self.frame.size.width + 1, (self.frame.size.height - 32) / 2}, {71, 32}};
    __block CGRect fieldRect = {{6, (self.frame.size.height - 32) / 2}, {self.frame.size.width - 12, 32}};

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
#pragma mark UIControl action callbacks

- (void) cancelButtonPressed:(id)sender
{
    [self performSelector:@selector(cancelSearch) onThread:[NSThread currentThread] withObject:self waitUntilDone:YES];
    [self.delegate searchBarWasDismissed:self];
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
