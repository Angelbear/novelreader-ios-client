//
//  MSReaderViewController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-29.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "MSReaderViewController.h"
#import "DataBase.h"
#import "Bookmark.h"
#import "Section.h"
#import "Book.h"
#import "SectionReaderTableViewController.h"
#import <ViewDeck/IIViewDeckController.h>
#import "AppDelegate.h"
@interface MSReaderViewController ()
@property(nonatomic, strong) NSMutableArray* sections;
@property(nonatomic, assign) NSUInteger readingSection;
@property(nonatomic, copy) NSArray *filteredSections;
@property(nonatomic, copy) NSString *currentSearchString;
@end

@implementation MSReaderViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

CGFloat _cellHeight;

- (id) init {
    self = [super initWithStyle:UITableViewStylePlain];
    self.readingSection = 0;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    _cellHeight = cell.frame.size.height;
    return self;
}


- (void) loadBook:(Book*) book {
    self.book = book;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        self.sections = [DataBase getAllSectionsOfBook:self.book];
        self.bookmark = [DataBase getDefaultBookmarkForBook:self.book];
        NSUInteger indexForJump = 0;
        for (indexForJump = 0; indexForJump < [self.sections count]; indexForJump++) {
            Section* section = [self.sections objectAtIndex:indexForJump];
            if (self.bookmark.section_id == section.section_id) {
                break;
            }
        }
        self.readingSection = indexForJump;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self transitionToViewController:[self.sections objectAtIndex:indexForJump]];
        });
    });
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.tableView setContentOffset:CGPointMake(0.0 , _cellHeight * self.readingSection)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.deckViewController.delegate = self;
    self.currentReaderViewController.delegate = self;
    self.tableView.bounces = NO;

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 44)];
    self.searchBar.placeholder = @"搜索";
    self.searchBar.delegate = self;
    
    self.strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    
    self.strongSearchDisplayController.delegate = self;
    self.strongSearchDisplayController.searchResultsDataSource = self;
    self.strongSearchDisplayController.searchResultsDelegate = self;
    
    [self.tableView addSubview:self.searchBar];
    
    self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.searchBar.bounds), 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CGRectGetHeight(self.searchBar.bounds), 0, 0, 0);

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) { // Don't do anything if the search table view get's scrolled
        if (scrollView.contentOffset.y < -CGRectGetHeight(self.searchBar.bounds)) {
            self.searchBar.layer.zPosition = 0; // Make sure the search bar is below the section index titles control when scrolling up
        } else {
            self.searchBar.layer.zPosition = 1; // Make sure the search bar is above the section headers when scrolling down
        }
        
        CGRect searchBarFrame = self.searchBar.frame;
        searchBarFrame.origin.y = MAX(scrollView.contentOffset.y, -CGRectGetHeight(searchBarFrame));
        
        self.searchBar.frame = searchBarFrame;
    }
}

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    // The search bar is always visible, so just scroll to the first section
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.strongSearchDisplayController.searchResultsTableView) {
        return [self.filteredSections count];
    } else {
        return [self.sections count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.book.name;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.strongSearchDisplayController.searchResultsTableView) {
        return;
    }
    
    if (self.readingSection == indexPath.row) {
        cell.selected = YES;
    } else {
        cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"font_selection_background"]];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    Section * sec;
    
    if (tableView == self.strongSearchDisplayController.searchResultsTableView) {
        sec = [self.filteredSections objectAtIndex:indexPath.row];
    } else {
        sec = [self.sections objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = sec.name;
    cell.backgroundColor = [UIColor blackColor];
    if (sec.text !=nil && [sec.text length] > 0) {
        cell.imageView.image = [UIImage imageNamed:@"checkmark"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"sync"];
    }

    return cell;
}


- (void)transitionToViewController:(Section*) section {
    self.currentReaderViewController.navigationItem.title = section.name;
    [self.currentReaderViewController setSection:section];
    [self.currentReaderViewController setBookmark:self.bookmark];
    [self.deckViewController closeRightViewAnimated:YES completion:^(IIViewDeckController* controller, BOOL finished) {
        if (section.text !=nil && [section.text length] > 0) {
            [self.currentReaderViewController prepareForRead];
        } else {
            [self.currentReaderViewController reloadSection];
        }
    }];   
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Section* section = nil;
    if (tableView == self.strongSearchDisplayController
        .searchResultsTableView) {
        [self.view endEditing:YES];
        section = [self.filteredSections objectAtIndex:indexPath.row];
    } else {
        section = [self.sections objectAtIndex:indexPath.row];
    }
  
    if (section == nil) {
        return;
    }
    
    [self transitionToViewController:section];
    self.readingSection = indexPath.row;
    Section* sec = (Section*)[self.sections objectAtIndex:self.readingSection];
    self.bookmark.section_id = sec.section_id;
    self.bookmark.offset = 0;
    [DataBase updateBookMark:self.bookmark];
    [self.tableView reloadData];
}


#pragma mark - ChangeSectionDelegate
- (void) nextSection {
    if (self.readingSection < [self.sections count] - 1) {
        self.readingSection ++;
    }
    Section* sec = (Section*)[self.sections objectAtIndex:self.readingSection];
    self.bookmark.section_id = sec.section_id;
    self.bookmark.offset = 0;
    [self transitionToViewController:sec];
    [DataBase updateBookMark:self.bookmark];
}

- (void) prevSection {
    if (self.readingSection > 0) {
        self.readingSection --;
    }
    Section* sec = (Section*)[self.sections objectAtIndex:self.readingSection];
    self.bookmark.section_id = sec.section_id;
    self.bookmark.offset = [sec.text length];
    [self transitionToViewController:sec];
    [DataBase updateBookMark:self.bookmark];
}

#pragma mark - Search Delegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.filteredSections = nil;
    self.currentSearchString = @"";
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.filteredSections = nil;
    self.currentSearchString = nil;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchString {
    if (searchString.length > 0) { // Should always be the case
        NSArray *sectionsToSearch = self.sections;
        if (self.currentSearchString.length > 0 && [searchString rangeOfString:self.currentSearchString].location == 0) { // If the new search string starts with the last search string, reuse the already filtered array so searching is faster
            sectionsToSearch = self.filteredSections;
        }
        
        self.filteredSections = [sectionsToSearch filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name contains %@)", searchString]];
    } else {
        self.filteredSections = self.sections;
    }
    
    self.currentSearchString = searchString;
    [self.strongSearchDisplayController.searchResultsTableView reloadData];
}

@end
