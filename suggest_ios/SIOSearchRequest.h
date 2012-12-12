//
//  SIOSearchRequest.h
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

#import <Foundation/Foundation.h>
#import "SIOSearchBar.h"

#define SIO_SEARCH_QUEUE_MAX_CONCURRENT_OPERATIONS   2
#define SIO_DEFAULT_REQUEST_TIMEOUT                  20

@interface SIOSearchRequest : NSObject <SIOSearchBarDataSource>

@property (strong) NSOperationQueue *searchQueue;

+ (id) sharedSearchRequest;
- (void) cancelAllSearches;

// SIOSearchBarDataSource methods
- (void) searchForSubstring:(NSString *)searchSubstring inDomain:(NSString *)searchDomain onCompletion:(SearchCompletionBlock)completionBlock;
- (void) cancelAllSearchesInDomain:(NSString *)searchDomain;

@end
