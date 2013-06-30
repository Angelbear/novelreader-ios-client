//
//  BookShelfViewController.m
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-28.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import "BookShelfViewController.h"
#import "DataBase.h"
#import "Book.h"
#import "Section.h"
#import "BookItemTableViewCell.h"
#import "Common.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface BookShelfViewController ()
@property(nonatomic, assign) NSUInteger _completedDownloadBooks;
@property(nonatomic, strong) NSMutableArray* _activeDownloadClients;
@end

@interface CustomNavigationBar : UINavigationBar
@end

@implementation CustomNavigationBar
-(void) drawRect:(CGRect)rect
{
    UIImage *image = [UIImage imageNamed: @"navigation_bar_bg"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
@end

@implementation BookShelfViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init
{
    self = [super initWithStyle:UITableViewStylePlain];
    self.isRefreshing = NO;
    self._completedDownloadBooks = 0;
    self._activeDownloadClients = [NSMutableArray arrayWithCapacity:0];
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.books = [DataBase getAllBooks];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIButton* refreshImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshImageButton setFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
    [refreshImageButton addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
    [refreshImageButton setImage:[UIImage imageNamed:@"bookshelf_update"] forState:UIControlStateNormal];
    
    
    UIButton *editImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editImageButton setFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
    [editImageButton addTarget:self action:@selector(enterEditMode:) forControlEvents:UIControlEventTouchUpInside];
    [editImageButton setImage:[UIImage imageNamed:@"bookshelf_edit"] forState:UIControlStateNormal];
    
    
    UIButton *doneImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneImageButton setFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
    [doneImageButton addTarget:self action:@selector(enterEditMode:) forControlEvents:UIControlEventTouchUpInside];
    [doneImageButton setImage:[UIImage imageNamed:@"bookshelf_ok"] forState:UIControlStateNormal];
    
    
    self.editButton = [[UIBarButtonItem alloc] initWithCustomView:editImageButton];
    self.doneButton = [[UIBarButtonItem alloc] initWithCustomView:doneImageButton];
    self.navigationItem.rightBarButtonItem = self.editButton;
    
    self.refreshButton = [[UIBarButtonItem alloc] initWithCustomView:refreshImageButton];
    [self.refreshButton setAction:@selector(refresh:)];
    self.navigationItem.leftBarButtonItem = self.refreshButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) stopAllDownloadTask {
    for (AFHTTPClient* client in self._activeDownloadClients) {
        [[client operationQueue] cancelAllOperations];
    }
    [self._activeDownloadClients removeAllObjects];
}

- (void) downloadAllSectionsOfAllBooks {
    self._completedDownloadBooks = 0;
    [self._activeDownloadClients removeAllObjects];
    NSString* baseURL = [NSString stringWithFormat:@"http://%@/", SERVER_HOST];
    for (Book* book in self.books) {
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
        [self._activeDownloadClients addObject:client];
        [client.operationQueue setMaxConcurrentOperationCount:1];
        NSMutableArray* sections = [DataBase getAllSectionsOfBook:book];
        NSMutableArray *operations = [NSMutableArray array];
        for (Section *sec in sections) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/note/get_section?from=%@&url=%@", SERVER_HOST, sec.from, [URLUtils uri_encode:sec.url]]];
            NSLog(@"%@", url);
            NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
            [request setValue:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3" forHTTPHeaderField:@"User-Agent"];
            AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                if (JSON != nil) {
                    sec.text = [JSON objectForKey:@"text"];
                    sec.name = [JSON objectForKey:@"title"];
                    [DataBase updateSection:sec];
                }
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                NSLog(@"failure %@", [error localizedDescription]);
            }];
            [operations addObject:operation];
        }
        [client enqueueBatchOfHTTPRequestOperations:operations
              progressBlock:^(NSUInteger numberOfCompletedOperations, NSUInteger totalNumberOfOperations) {
                  NSIndexPath* path = [NSIndexPath indexPathForRow:[self.books indexOfObject:book] inSection:0];
                  BookItemTableViewCell* cell = (BookItemTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
                  NSLog(@"download complemete %d %d",  numberOfCompletedOperations, totalNumberOfOperations);
                  [cell setProgress:(CGFloat)numberOfCompletedOperations / (CGFloat)totalNumberOfOperations];
              } completionBlock:^(NSArray *operations) {
                  self._completedDownloadBooks++;
                  if (self._completedDownloadBooks == [self.books count]) {
                      [self refresh:nil];
                  }
        }];
    }
}

// an ivar for your class:
BOOL animating;

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.2f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         self.navigationItem.leftBarButtonItem.customView.transform = CGAffineTransformRotate(self.navigationItem.leftBarButtonItem.customView.transform, M_PI_2 );
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (animating) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}

- (void) startSpin {
    if (!animating) {
        animating = YES;
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
    }
}

- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    animating = NO;
}

- (void) refresh:(id) sender {
    if (self.isRefreshing == YES) {
        [self stopSpin];
        [self stopAllDownloadTask];
        self.isRefreshing = NO;
    } else {
        self.isRefreshing = YES;
        [self startSpin];
        [self downloadAllSectionsOfAllBooks];
    }
    [self.tableView reloadData];
}

- (void) enterEditMode:(id)sender {
    if ([self.tableView isEditing]) {
        [self.tableView setEditing:NO animated:YES];
        self.navigationItem.rightBarButtonItem = self.editButton;
    }
    else {
        self.navigationItem.rightBarButtonItem = self.doneButton;
        [self.tableView setEditing:YES animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.books count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    BookItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BookItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    Book* book = [self.books objectAtIndex:indexPath.row];
    cell.textLabel.text =  book.name;
    cell.imageView.image = book.cover;
    
    if (self.isRefreshing == YES) {
        [cell.contentView addSubview:cell.dlProgress];        
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        [cell.dlProgress removeFromSuperview];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        Book* book = [self.books objectAtIndex:indexPath.row];
        [DataBase deleteBook:book];
        [self.books removeObject:book];
        [self.tableView reloadData];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    [self stopSpin];
    [self stopAllDownloadTask];
    self.isRefreshing = NO;
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    Book* book = [self.books objectAtIndex:indexPath.row];
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate switchToReader:book];
    
}

@end
