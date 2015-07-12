//
//  WXManager.h
//  SimpleWeather
//
//  Created by Ryan Nystrom on 11/11/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

@import Foundation;
@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "WXCondition.h"


@protocol WXMangerAPIDelegate

-(void) conditionUpdate: (NSString*)temperText conditionText:(NSString*)conditionText city:(NSString*)city icon:(NSString*)icon hilowtemp:(NSString*)hilowtemp windspeed:(NSString*)windspeed  windgrade:(NSString*)windgrade sunrisetime:(NSString*)sunrisetime sunsettime:(NSString*)sunsettime;
-(void) temperUpdate: (NSString*)text;
-(void) dailyUpdate;
-(void) hourlyUpdate;

@end

@interface WXManager : NSObject
<CLLocationManagerDelegate>

// 2
+ (instancetype)sharedManager;

//delegate for ViewController
@property (nonatomic,assign) id delegate;

// 3
@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) WXCondition *currentCondition;
@property (nonatomic, strong, readonly) NSArray *hourlyForecast;
@property (nonatomic, strong, readonly) NSArray *dailyForecast;

// 4
- (void)findCurrentLocation;
- (void)addObserverfunc;
//- (float) fa2cen: (float) value;
@end