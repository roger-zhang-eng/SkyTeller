//
//  WXManager.m
//  SkyTeller
//
//  Created by Roger Zhang on 14/06/2015.
//  Copyright (c) 2015 Personal Dev. All rights reserved.
//

#import "WXManager.h"
#import "WXClient.h"
#import <TSMessages/TSMessage.h>

@interface WXManager ()

// Declare the same properties you added in the public interface, but this time declare them as readwrite so you can change the values behind the scenes.
@property (nonatomic, strong, readwrite) WXCondition *currentCondition;
@property (nonatomic, strong, readwrite) CLLocation *currentLocation;
@property (nonatomic, strong, readwrite) NSArray *hourlyForecast;
@property (nonatomic, strong, readwrite) NSArray *dailyForecast;

// Declare a few other private properties for location finding and data fetching
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) WXClient *client;

@end

@implementation WXManager

@synthesize delegate;

- (void)setDelegate:(id)aDelegate {
    delegate = aDelegate;
}

+ (instancetype)sharedManager {
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

/*- (float) fa2cen: (float) value {
    return ((value - 32) * 5)/9;
}*/

- (id)init {
    if (self = [super init]) {
        // 1
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        // 2
        _client = [[WXClient alloc] init];
        
        // 3
        [[[[RACObserve(self, currentLocation)
            // 4
            ignore:nil]
           // 5
           // Flatten and subscribe to all 3 signals when currentLocation updates
           flattenMap:^(CLLocation *newLocation) {
               return [RACSignal merge:@[
                                         [self updateCurrentConditions]
                                         ,[self updateDailyForecast],
                                         [self updateHourlyForecast]
                                         ]];
               // 6
           }] deliverOn:RACScheduler.mainThreadScheduler]
         // 7
         subscribeError:^(NSError *error) {
             [TSMessage showNotificationWithTitle:@"Error"
                                         subtitle:@"There was a problem fetching the latest weather."
                                             type:TSMessageNotificationTypeError];
         }];
    }
    return self;
}



- (void)findCurrentLocation {
    
    [self addObserverfunc];
    
    NSLog(@"Begin to find current location!");
    self.isFirstUpdate = YES;
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSLog(@"didUpdateLocations");
    // 1
    if (self.isFirstUpdate) {
        self.isFirstUpdate = NO;
        return;
    }
    
    CLLocation *location = [locations lastObject];
    
    // 2
    if (location.horizontalAccuracy > 0) {
        // 3
        self.currentLocation = location;
        [self.locationManager stopUpdatingLocation];
    }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWith Error: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to Get your location, use Sydney by default to indicate the weather!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [errorAlert show];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:-33.873400 longitude:151.206894];
    self.currentLocation = location;
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        NSLog(@"The location authentication is allowed!");
        [self.locationManager startUpdatingLocation];
    } else {
        NSLog(@"The location is not allowed!");
    }
}

- (RACSignal *)updateCurrentConditions {
    return [[self.client fetchCurrentConditionsForLocation:self.currentLocation.coordinate] doNext:^(WXCondition *condition) {
        self.currentCondition = condition;
    }];
}

- (RACSignal *)updateHourlyForecast {
    return [[self.client fetchHourlyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.hourlyForecast = conditions;
    }];
}

- (RACSignal *)updateDailyForecast {
    return [[self.client fetchDailyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.dailyForecast = conditions;
    }];
}

- (void)addObserverfunc {
    // 1
    [[RACObserve(self, currentCondition)
      // 2
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(WXCondition *newCondition) {
         NSLog(@"temper %@, condition %@, city %@, icon %@",newCondition.temperature,[newCondition.condition capitalizedString],[newCondition.locationName capitalizedString],[newCondition imageName]);
         
         if(newCondition) {

             NSString *temperText = [NSString stringWithFormat:@"%.0f",
                                 newCondition.temperature.floatValue ];
             
             NSString *conditionText = [newCondition.condition capitalizedString];
             NSString *city = [newCondition.locationName capitalizedString];
         
             NSString *icon = [newCondition imageName];
             NSString *hilotemp = [NSString stringWithFormat:@"%.0f° / %.0f°",newCondition.tempHigh.floatValue,newCondition.tempLow.floatValue];
             NSString *windspeed = [NSString stringWithFormat:@"%.0f km/h", newCondition.windSpeed.floatValue];
             
             float windgrade = 0;
             int speed = newCondition.windSpeed.floatValue;
             if(speed < 6) {
                 windgrade = 0;
             } else if((speed >= 6) && (speed < 21)) {
                 windgrade = 1;
             } else if((speed >= 21) && (speed < 41)) {
                 windgrade = 2;
             } else {
                 windgrade = 3;
             }
             NSString *windgrade_text = [NSString stringWithFormat:@"%.0f",windgrade];
             
        
             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
             [dateFormatter setDateFormat:@"hh:mm a"];
             
             NSString *sunrisetime = [dateFormatter stringFromDate:newCondition.sunrise];
             NSString *sunsettime = [dateFormatter stringFromDate:newCondition.sunset];
             //[self fa2cen:newCondition.tempLow.floatValue];
             
             [self.delegate conditionUpdate:temperText conditionText:conditionText city:city icon:icon hilowtemp:hilotemp windspeed:windspeed  windgrade:windgrade_text sunrisetime:sunrisetime sunsettime:sunsettime];
         }
     }];
    
    /*[[RACSignal combineLatest:@[ RACObserve(self, currentCondition.tempHigh), RACObserve(self, currentCondition.tempLow)] reduce:^(NSNumber *hi, NSNumber *low) {
        //NSString *text = [NSString stringWithFormat:@"%.0f° / %.0f°",hi.float,low.float];
        [self.delegate temperUpdate:@"good"];
        return @"good";
        }] deliverOn:RACScheduler.mainThreadScheduler];*/
    
    [[RACObserve(self, hourlyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.delegate hourlyUpdate];
     }];
    
    [[RACObserve(self, dailyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.delegate dailyUpdate];
     }];


     
}

@end
