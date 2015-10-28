//
//  WXClient.h
//  SkyTeller
//
//  Created by Roger Zhang on 14/06/2015.
//  Copyright (c) 2015 Personal Dev. All rights reserved.
//

@import Foundation;
@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa.h>



@interface WXClient : NSObject
- (RACSignal *)fetchJSONFromURL:(NSURL *)url;
- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate;
- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate;
- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate;
@end
