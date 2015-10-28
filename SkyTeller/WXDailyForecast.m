//
//  WXDailyForecast.m
//  SkyTeller
//
//  Created by Roger Zhang on 14/06/2015.
//  Copyright (c) 2015 Personal Dev. All rights reserved.
//

#import "WXDailyForecast.h"

@implementation WXDailyForecast

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    return paths;
}

@end
