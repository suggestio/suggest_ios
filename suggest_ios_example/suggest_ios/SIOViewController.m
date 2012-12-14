//
//  SIOViewController.m
//  suggest_ios
//
//  Created by Andrey Yurkevich on 12/11/12.
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

#import "SIOViewController.h"
#import "SIOSearchBar.h"
#import "SIOTableViewCell.h"
#import "SIOSearchRequest.h"

@interface SIOViewController ()

@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, strong) IBOutlet SIOSearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
    
@end

@implementation SIOViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.searchResults = [NSMutableArray array];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    self.searchBar.datasource = [SIOSearchRequest sharedSearchRequest];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}


- (void) viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // TODO: fix the XIB for proper tableView size/position on 3.5"/3.5"@2x/4"@2x
    //       to avoid setting its frame with code
    CGRect tableRect = self.view.frame;
    tableRect.size.height -= self.searchBar.frame.size.height;
    tableRect.origin.y = self.searchBar.frame.size.height;
    self.tableView.frame = tableRect;
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark -
#pragma mark UITableView delegate / datasource methods

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SIOTableViewCell cellHeightForSearchResult:[self.searchResults objectAtIndex:indexPath.row]] + 6.0;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSAssert(section == 0, @"SIOViewController: Invalid taleView section (%d)", section);
    return [self.searchResults count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"SIOTableCellId";
    SIOTableViewCell *cell = nil;

    cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (nil == cell) {
        cell = [[SIOTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.searchResultEntry = [self.searchResults objectAtIndex:indexPath.row];

    return (UITableViewCell *) cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SIOSearchResult *e = [self.searchResults objectAtIndex:indexPath.row];
    NSURL *url = e.url;
    [[UIApplication sharedApplication] openURL:url];
}


#pragma mark -
#pragma mark - Keyboard notification handlers

-(void) keyboardDidShow:(NSNotification *)notification
{
    NSValue *v = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [v CGRectValue];
    CGRect tableRect = self.tableView.frame;
    tableRect.size.height -= keyboardRect.size.height;
    tableRect.origin.y = self.searchBar.frame.size.height;
    self.tableView.frame = tableRect;
}

-(void) keyboardWillHide:(NSNotification *)notif
{
    CGRect tableRect = self.view.frame;
    tableRect.size.height -= self.searchBar.frame.size.height;
    tableRect.origin.y = self.searchBar.frame.size.height;
    self.tableView.frame = tableRect;
}


#pragma mark -
#pragma mark SIOSearchBar delegate methods

static NSOperationQueue *cellsQueue = nil;


- (void) addSearchResult:(SIOSearchResult *)entry
{
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        cellsQueue = [[NSOperationQueue alloc] init];
        [cellsQueue setMaxConcurrentOperationCount:1];
    });

    [cellsQueue addOperationWithBlock:^{
        [self.tableView beginUpdates];
        [self.searchResults insertObject:entry atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0
                                                                    inSection:0]]
                              withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }];
}


- (void) removeSearchResult:(SIOSearchResult *)entry
{
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        cellsQueue = [[NSOperationQueue alloc] init];
        [cellsQueue setMaxConcurrentOperationCount:1];
    });

    [cellsQueue addOperationWithBlock:^{
        [self.searchResults removeObjectIdenticalTo:entry];
    }];
}

- (NSString *) searchBarQueryDomain:(SIOSearchBar *)searchBar
{
    return @"aversimage.ru";
}


- (void) searchBarWasDismissed:(SIOSearchBar *)searchBar
{
    NSLog(@"SIOSeachBar was dismissed");
    self.searchBar.searchField.text = @"";
    [self.searchBar.searchField resignFirstResponder];
    [self.searchBar.datasource cancelAllSearchesInDomain:@"aversimage.ru"];
    self.searchResults = [NSMutableArray array];
    [self.tableView reloadData];
}

- (void) searchBar:(SIOSearchBar *)searchBar didStartSearching:(NSString *)searchSubstring
{
    NSLog(@"Started search for %@", searchSubstring);
}


- (void) searchBar:(SIOSearchBar *)searchBar didEndSearching:(NSString *)searchSubstring returningResults:(NSArray *)searchResults
{
    self.searchResults  = [NSMutableArray arrayWithArray:searchResults];
    [self.tableView reloadData];
}

@end
