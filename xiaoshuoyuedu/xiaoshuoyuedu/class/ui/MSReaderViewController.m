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
#import "Common.h"
#import "Section.h"
#import "Book.h"
#import "SectionReaderTableViewController.h"
#import <ViewDeck/IIViewDeckController.h>
#import "AppDelegate.h"
@interface MSReaderViewController ()
@property(nonatomic, strong) NSMutableArray* sections;
@property(nonatomic, strong) Section* currentSection;
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
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    _cellHeight = cell.frame.size.height;
    return self;
}


- (void) loadBook:(Book*) book {
    self.book = book;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        self.sections = [DataBase getAllSectionsOfBook:self.book];
        self.bookmark = [DataBase getDefaultBookmarkForBook:self.book];
        if ([self.sections count] == 0) {
            return;
        }
        
        NSUInteger indexForJump = 0;
        for (indexForJump = 0; indexForJump < [self.sections count]; indexForJump++) {
            Section* section = [self.sections objectAtIndex:indexForJump];
            if (self.bookmark.section_id == section.section_id) {
                self.currentSection = section;
                break;
            }
        }
        
        indexForJump = MAX(0, MIN(indexForJump, [self.sections count] - 1));
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self transitionToViewController:[self.sections objectAtIndex:indexForJump]];
        });
    });
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.searchBar sizeToFit];
    if (self.strongSearchDisplayController.isActive) {
        NSUInteger index = [self.filteredSections indexOfObject:self.currentSection];
        [self.tableView setContentOffset:CGPointMake(0.0 , _cellHeight * index - CGRectGetHeight(self.searchBar.bounds))];
    } else {
        NSUInteger index = [self.sections indexOfObject:self.currentSection];
        [self.tableView setContentOffset:CGPointMake(0.0 , _cellHeight * index - CGRectGetHeight(self.searchBar.bounds))];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.deckViewController.delegate = self;
    self.currentReaderViewController.delegate = self;
    self.tableView.bounces = NO;

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.searchBar.placeholder = @"搜索";
    self.searchBar.delegate = self;
    [self.searchBar sizeToFit];
        
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
    Section * sec;
    
    if (tableView == self.strongSearchDisplayController.searchResultsTableView) {
        sec = [self.filteredSections objectAtIndex:indexPath.row];
    } else {
        sec = [self.sections objectAtIndex:indexPath.row];
    }
    
    if (self.currentSection == sec) {
        cell.selected = YES;
    } else {
        cell.selected = NO;
        cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"font_selection_background"]];
    }

    if (sec.text !=nil && [sec.text length] > 0) {
        cell.imageView.image = [UIImage imageNamed:@"checkmark"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"sync"];
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
    
    NSString* searchUrl = [NSString stringWithFormat:@"http://%@/note/get_section?from=%@&url=%@", SERVER_HOST, sec.from, [URLUtils uri_encode:sec.url]];
    if ( [[DownloadManager init_instance] queryDownloadTask:NOVEL_DOWNLOAD_TASK_TYPE_SECTION url:searchUrl] != nil) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.frame = CGRectMake(0, 0, 24, 24);
        cell.accessoryView = spinner;
        [spinner startAnimating];
    } else {
        cell.accessoryView = nil;
    }
    
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
        [self.currentReaderViewController prepareForRead];
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
    self.currentSection = section;
    self.bookmark.section_id = section.section_id;
    self.bookmark.offset = 0;
    [DataBase updateBookMark:self.bookmark];
    [tableView reloadData];
}


#pragma mark - ChangeSectionDelegate
- (void) nextSection {
    NSUInteger index = [self.sections indexOfObject:self.currentSection];
    if (index < [self.sections count] - 1) {
        index ++;
    }
    Section* sec = (Section*)[self.sections objectAtIndex:index];
    self.currentSection = sec;
    self.bookmark.section_id = sec.section_id;
    self.bookmark.offset = 0;
    [self transitionToViewController:sec];
    [DataBase updateBookMark:self.bookmark];
}

- (void) prevSection {
    NSUInteger index = [self.sections indexOfObject:self.currentSection];
    if (index > 0) {
        index --;
    }
    Section* sec = (Section*)[self.sections objectAtIndex:index];
    self.currentSection = sec;
    self.bookmark.section_id = sec.section_id;
    self.bookmark.offset = [sec.text length];
    [self transitionToViewController:sec];
    [DataBase updateBookMark:self.bookmark];
}

- (void) downloadLaterSections {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger index = [self.sections indexOfObject:self.currentSection];
        index++;
        for (;index < [self.sections count]; index++) {
            __block Section* section = [self.sections objectAtIndex:index];
            if (section.text == nil || section.text.length == 0) {
                NSString* searchUrl = [NSString stringWithFormat:@"http://%@/note/get_section?from=%@&url=%@", SERVER_HOST, section.from, [URLUtils uri_encode:section.url]];
                [[DownloadManager init_instance] addDownloadTask:NOVEL_DOWNLOAD_TASK_TYPE_SECTION url:searchUrl piority:NSOperationQueuePriorityLow success:^(NSURLRequest *request, NSHTTPURLResponse *response, id data) {
                    if (data != nil) {
                        section.text = [data objectForKey:@"text"];
                        [DataBase updateSection:section];
                        [self.tableView reloadData];
                    }
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, id data, NSError *error) {
                }];
            }
        }
    });
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
        if (self.currentSearchString.length > 0 && [searchString rangeOfString:self.currentSearchString].location == 0) {
            sectionsToSearch = self.filteredSections;
        }
        self.filteredSections = [sectionsToSearch filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name contains %@)", searchString]];
    } else {
        self.filteredSections = self.sections;
    }
    
    self.currentSearchString = searchString;
    [self.strongSearchDisplayController.searchResultsTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    NSUInteger index = [self.sections indexOfObject:self.currentSection];
    [self.tableView setContentOffset:CGPointMake(0.0 , _cellHeight * index - CGRectGetHeight(self.searchBar.bounds))];
}

@end
