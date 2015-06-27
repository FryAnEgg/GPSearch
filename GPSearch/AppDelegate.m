//
//  AppDelegate.m
//  GPSearch
//
//  Created by David Lathrop on 4/28/15.
//  Copyright (c) 2015 Fry An Egg Technology. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize locationManager;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [ self startLocationEvents ];
    
    return YES;
}


- (void)startLocationEvents {
    
    if (!locationManager) {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        
        if([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
            [locationManager requestWhenInUseAuthorization];
        }else{
            [locationManager startUpdatingLocation];
        }
    }
    [locationManager startUpdatingLocation];
    
}


#pragma mark - CLLocationManager delegate


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LOCATION_UPDATED_NOTIF" object:currentLocation userInfo:nil];
    
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"CLLocationManager : didFailWithError");
}


-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            // error handling
            break;
        default:
            [locationManager startUpdatingLocation];
            break;
    }
}

@end
