//
//  SIOSearchBar.h
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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SIOSearchField.h"

@class SIOSearchBar;


/**
 * SIOSearchBarDataSource protocol defines the methods that a datasource object should implement. Basically,
 * the delegate object is responsible of performing HTTP request to the Suggest.io server, passing the target
 * domain and a substring to search in the request and returing an array of SIOSearchResult objects that it reads
 * in the HTTP response.
 *
 */
@protocol SIOSearchBarDataSource <NSObject>

/**
 * definition for the onCompletion block for datasource search request
 *
 */
typedef void (^SearchCompletionBlock)(NSArray *items, NSError *error);

@required

/**
 * Performs the HTTP request to the Suggest.io server, calling the SearchCompletionBlock when the results are received.
 *
 * The Suggest.io server returns results serialized into a JSON array. After the result is received, the datasource
 * object needs to parse the response and create an array of SIOSearchResult objects, passing it to the completionBlock.
 *
 * @param searchSubsting The substring to search for
 * @param searchDomain The domain name where the search should be performed
 * @param completionBlock The block that is executed on completion/error
 *
 * @see cancelAllSearchesInDomain:
 *
 */
- (void)searchForSubstring:(NSString *)searchSubstring inDomain:(NSString *)searchDomain onCompletion:(SearchCompletionBlock)completionBlock;

/**
 * Cancels search request to the searchDomain.
 *
 * @param searchDomain The domain name for which the search request has been initiated
 *
 * @see searchForSubstring:inDomain:onCompletion:
 *
 */
- (void)cancelAllSearchesInDomain:(NSString *)searchDomain;

@end


/**
 * Protocol for the SIOSearchBar's delegate object. The delegate is responsible
 * for providing the domain name for the search. It also receives notifications when the search is
 * srarted/cancelled/completed receiving the search results as an array of SIOSearchResult objects.
 */
@protocol SIOSearchBarDelegate <NSObject>
@required

/**
 * Provides the domain name where the search should be performed.
 *
 * @param searchBar The instance of SIOSearchBar that has requested the domain name for searching
 * @return The domain name where the search should be performed
 */
- (NSString *)searchBarQueryDomain:(SIOSearchBar *)searchBar;

/**
 * Notifies the delegate thet the search bar has been dismissed.
 *
 * @param searchBar The instance of SIOSearchBar that has been dismissed
 *
 */
- (void)searchBarWasDismissed:(SIOSearchBar *)searchBar;

@optional
/**
 * Called when the search is started
 *
 * @param searchBar The instance of SIOSearchBar that has initiated the search
 * @param searchSubstring The search substring
 *
 * @see searchBarDidCancelSearch:
 * @see searchBar:didEndSearching:returningResults:
 */
- (void)searchBar:(SIOSearchBar *)searchBar didStartSearching:(NSString *)searchSubstring;

/**
 * Called when the search is finished
 *
 * @param searchBar The instance of SIOSearchBar that has initiated the search
 * @param searchSubstring The search substring
 * @param searchResults An array of SIOSearchResult objects (or an empty array if there were no search results returned from the server)
 *
 * @see searchBar:didStartSearching:
 * @see searchBarDidCancelSearch:
 */
- (void)searchBar:(SIOSearchBar *)searchBar didEndSearching:(NSString *)searchSubstring returningResults:(NSArray *)searchResults;

/**
 * Called when the search is cancelled
 *
 * @param searchBar The instance of SIOSearchBar that has initiated the search
 *
 * @see searchBar:didStartSearching:
 * @see searchBar:didEndSearching:returningResults:
 */
- (void)searchBarDidCancelSearch:(SIOSearchBar *)searchBar;
@end


/**
 * Displays a simple search bar for Suggest.io search.
 *
 * This is a simple class for displaying a search bar similar to Apple's UISearchBar which provides
 * search start/end/cancel callbacks as well as array of search results to its delegate object.
 * The search itself is performed by a datasource object.
 *
 */
@interface SIOSearchBar : UIView <UITextFieldDelegate>


/**
 * (read-only) reference to the search textfield
 */
@property (nonatomic, strong, readonly) UITextField *searchField;

/**
 * Whether the cancel button is shown in the seatch bar
 */
@property (assign) BOOL hasCancelButton;
 
/**
 * Title for the Cancel button (default is NSLocalizedString(@"Cancel", @"Cancel"))
 */
@property (nonatomic, copy) NSString *cancelButtonTitle;

/**
 * Tint color for the search bar
 */
@property (nonatomic, strong, setter = setTintColor:) UIColor *tintColor;

/**
 * CGBlendMode to use when painting the tint color (default is kCGBlendModeMultiply)
 */
@property (assign) CGBlendMode blendMode;


/**
 * Search bar delegate object
 *
 * @see datasource
 */
@property (atomic, unsafe_unretained) id<SIOSearchBarDelegate> delegate;

/**
 * Search bar data source object
 *
 * @see delegate
 */
@property (atomic, unsafe_unretained) id<SIOSearchBarDataSource> datasource;

/**
 * The designated initializer for SIOSearchBar
 */
- (id) initWithStyle:(SIOSearchBarFieldStyle)fs rect:(CGRect)rect;

/**
 * Toggles the search bar to show/hide the activity indicator
 */
- (void) showsSearchActivity:(BOOL)showsActivity;

@end
