//
//  GPTableViewController.h
//  GPSearch
//
//  Created by David Lathrop on 4/28/15.
//  Copyright (c) 2015 Fry An Egg Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CLLocation.h>

@interface GPTableViewController : UITableViewController {
    
    CLLocation * lastLocation;
    
    NSArray * landmarks;
    
    UIImage * defaultImage;
    NSString * searchText;
    NSString * locationText;
    NSString * nextPageToken;
    int retryCount;
    
}

@end
