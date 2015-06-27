//
//  GPTableViewController.m
//  GPSearch
//
//  Created by David Lathrop on 4/28/15.
//  Copyright (c) 2015 Fry An Egg Technology. All rights reserved.
//  elated-chariot-93004 googleid


#import "GPTableViewController.h"

#import "GPTableViewCell.h"

#import "AFHTTPSessionManager.h"
#import "UIImageView+AFNetworking.h"


@interface GPTableViewController ()

    - (UIImage*)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
    - (void)locationUpdateNotif:(NSNotification*) notif;
    - (void)sendSearchRequest;
    - (void)sendNextPageRequest : (NSTimer*) timer;

@end

@implementation GPTableViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    defaultImage = [UIImage imageNamed:@"avatar_default"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(locationUpdateNotif:)name:@"LOCATION_UPDATED_NOTIF"  object:nil];
    
}


#pragma mark - GPTableViewController


- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


-(void) locationUpdateNotif:(NSNotification*) notif {
    
    if (!nextPageToken || nextPageToken.length == 0) { // only when nextpage request is not in progress.
        lastLocation = (CLLocation *) notif.object;
    }
}


- (void) sendSearchRequest {
    
    NSString *baseURLString = [ NSString stringWithFormat:@"https://maps.googleapis.com"];
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    NSString *targetURLString = [NSString stringWithFormat:@"maps/api/place/textsearch/json?query=%@&%@&key=AIzaSyAv6ffGlz2d3NGXBTM2OB5WFvlSLUvV61U", searchText, locationText];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [manager GET:targetURLString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary * result = (NSDictionary *)responseObject;
        
        landmarks = [result objectForKey:@"results"];
        retryCount = 0;
        
        nextPageToken = [result objectForKey:@"next_page_token"];
        
        [self.searchDisplayController.searchResultsTableView reloadData];
        
        [self.tableView reloadData];
        
        if (nextPageToken && nextPageToken.length > 0) {
            
            // per documentation we must wait to get next page
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendNextPageRequest:) userInfo:nil repeats:NO];
            
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Search Request Error"
                                                message:[error localizedDescription]
                                                delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [alertView show];
    }];

}


- (void) sendNextPageRequest : (NSTimer*) timer {
    
    NSString *baseURLString = [ NSString stringWithFormat:@"https://maps.googleapis.com"];
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    NSString *targetURLString = [NSString stringWithFormat:@"maps/api/place/textsearch/json?query=%@&%@&key=AIzaSyAv6ffGlz2d3NGXBTM2OB5WFvlSLUvV61U&pagetoken=%@", searchText, locationText, nextPageToken];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [manager GET:targetURLString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary * result = (NSDictionary *)responseObject;
        
        NSString * statusString = [result objectForKey:@"status"];
        
        if([statusString compare:@"INVALID_REQUEST" ] == NSOrderedSame) {
            
            if (retryCount>=5) {
                retryCount = 0;
                NSLog(@"next page failed 5 times, aborting request.");
            } else {
                retryCount++;
                [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendNextPageRequest:) userInfo:nil repeats:NO];
            }
            
            return;
        }
        
        landmarks = [landmarks arrayByAddingObjectsFromArray:[result objectForKey:@"results"]];
        
        nextPageToken = [result objectForKey:@"next_page_token"];
        
        [self.searchDisplayController.searchResultsTableView reloadData];
        
        [self.tableView reloadData];
        
        if (nextPageToken && nextPageToken.length > 0) {
            
            // per documentation we must wait to get next page
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendNextPageRequest:) userInfo:nil repeats:NO];
            
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"next page failure : %@", [error localizedDescription]);
    }];
}


#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (!nextPageToken || nextPageToken.length == 0) {
        return landmarks.count;
    } else {
        return landmarks.count + 20;
    }
    
}


#pragma mark - UITableViewDelegate


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    GPTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"gpCell" forIndexPath:indexPath];
    
    if (indexPath.row < landmarks.count) {
        
        NSDictionary * landmark = [landmarks objectAtIndex:indexPath.row];
        
        NSString* name = [landmark objectForKey:@"name"];
        
        NSDictionary * openingHoursD = [landmark objectForKey:@"opening_hours"];
        NSNumber * openNumber = [openingHoursD objectForKey:@"open_now"];
        
        BOOL bOpen = [openNumber boolValue];
        if (bOpen) {
            cell.openLabel.text = @"OPEN";
            cell.openLabel.textColor = [UIColor greenColor];
        } else {
            cell.openLabel.text = @"CLOSED";
            cell.openLabel.textColor = [UIColor redColor];
        }
        
        NSArray * types = [landmark objectForKey:@"types"];
        
        NSMutableString * typeString = [[NSMutableString alloc]init];
        for (int i=0; i<types.count; i++) {
            NSString * type = [types objectAtIndex:i];
            [typeString appendString:type];
            if (i<types.count-1) {
                [typeString appendString:@" | "];
            }
        }
        
        NSString * request_URL_String = [landmark objectForKey:@"icon"];
        NSURL *url = [NSURL URLWithString:request_URL_String];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        UIImage *cachedImage = [[[UIImageView class] sharedImageCache] cachedImageForRequest:request];
        if (cachedImage) {
            
            CGSize newSize = CGSizeMake(50., 50.);
            UIImage * nImage = [self imageWithImage:cachedImage scaledToSize:newSize];
            
            cell.gpImageView.image = nImage;
        
        }
        else {
            
            __weak GPTableViewCell *weakCell = cell;
            
            [cell.gpImageView setImageWithURLRequest:request
                placeholderImage:defaultImage
                success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    
                    CGSize newSize = CGSizeMake(50., 50.);
                    UIImage * nImage = [self imageWithImage:image scaledToSize:newSize];
                    
                        weakCell.gpImageView.image = nImage;
                        [weakCell setNeedsLayout];
                                                   
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                        NSLog(@"ERROR %@ loading image %@", request_URL_String, [error description]);
                                               }];
        }
        
        cell.titleLabel.text = name;
        cell.typesLabel.text = typeString;
        
    } else { // this cell is on the pending next page
        
        cell.titleLabel.text = @"Loading...";
        cell.typesLabel.text = @"in progress";
        cell.openLabel.text = @"";
        cell.gpImageView.image = defaultImage;
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}


#pragma mark - UISearchBarDelegate


- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    
    searchText = searchBar.text;
    
    if (!lastLocation) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Location!"
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];

    } else {
        locationText = [NSString stringWithFormat:@"location=%4.6f,%4.6f&radius=2500",lastLocation.coordinate.latitude, lastLocation.coordinate.longitude ];
    
        [self sendSearchRequest];
    }
}


@end
