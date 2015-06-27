//
//  AppDelegate.h
//  GPSearch
//
//  Created by David Lathrop on 4/28/15.
//  Copyright (c) 2015 Fry An Egg Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CLLocationManager *locationManager;


@end

