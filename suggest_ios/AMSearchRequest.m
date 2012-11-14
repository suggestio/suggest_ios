//
//  AMSearchRequest.m
//  suggest_ios
//
//  Created by Andrey Yurkevich on 10/23/12.
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

#import "AMSearchRequest.h"
#import "AMSearchResult.h"
#import "AMMacros.h"


@interface AMSearchRequest ()
- (id) init;
@end


@implementation AMSearchRequest

+ (id) sharedSearchRequest
{
    static dispatch_once_t pred = 0;
    static id sharedSearchRequest = nil;

    dispatch_once(&pred,
                  ^{
                      sharedSearchRequest = [[AMSearchRequest alloc] init];
                  });

    return sharedSearchRequest;
}


- (id) init
{
    self = [super init];
    if (self != nil) {
        _searchQueue = [[NSOperationQueue alloc] init];
        _searchQueue.maxConcurrentOperationCount = AM_SEARCH_QUEUE_MAX_CONCURRENT_OPERATIONS;
    }
    return self;
}


- (void) cancelAllSearches
{
    [self.searchQueue cancelAllOperations];
}


#pragma mark -
#pragma mark AMSearchBarDataSource methods

- (void) searchForSubstring:(NSString *)searchSubstring inDomain:(NSString *)searchDomain onCompletion:(SearchCompletionBlock)completionBlock
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSError *error = nil;
        NSMutableArray *searchResultItems = [[NSMutableArray alloc] init];
        NSHTTPURLResponse *response = nil;

        CFStringRef requestStrRef = (__bridge CFStringRef) [NSString stringWithFormat:@"/search?h=%@&q=%@", searchDomain, searchSubstring];
        CFStringRef encodedStrRef = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                            requestStrRef,
                                                                                            CFSTR(""),
                                                                                            kCFStringEncodingUTF8);
        CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                        encodedStrRef,
                                                                        NULL,
                                                                        NULL,
                                                                        kCFStringEncodingUTF8);
        NSURL *url = [NSURL URLWithString:(__bridge NSString *) urlString
                            relativeToURL:[NSURL URLWithString:@"https://suggest.io/"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url
                                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                             timeoutInterval:AM_DEFAULT_REQUEST_TIMEOUT];

        NSData *data = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];

        if (response && data) { // FIXME: check length of JSON data received
            NSMutableString *jsonString = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [jsonString replaceCharactersInRange:NSMakeRange(0, 18) withString:@""];
            [jsonString replaceCharactersInRange:NSMakeRange([jsonString length] - 2, 2) withString:@""];

            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options:0
                                                                   error:&error];
            NSArray *searchResults = [JSON objectForKey:@"search_result"];

            // Serialize JSON response
            for (NSDictionary *searchResultItem in searchResults) {
                AMSearchResult *sr = [[AMSearchResult alloc] initWithJSON:searchResultItem];
                [searchResultItems addObject:sr];
            }
            
            DLog(@"Search for '%@' returned %i results.", searchSubstring, [searchResultItems count]);
        }

        // Return to the main queue once the request has been processed.
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (error)
                completionBlock(nil, error);
            else
                completionBlock(searchResultItems, nil);
        }];
    }];

    // Optionally, set the operation priority. This is useful when flooding
    // the operation queue with different requests.

    [operation setQueuePriority:NSOperationQueuePriorityHigh];
    [self.searchQueue addOperation:operation];
}


- (void) cancelAllSearchesInDomain:(NSString *)searchDomain
{
    [self.searchQueue cancelAllOperations]; // FIXME: only cancel search operations for searchDomain
}


@end
