//
//  Restaurants.h
//  I'm Hungry
//
//  Created by Jacob Jewell on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthConsumer.h"
#include <stdlib.h>

@interface Restaurants : NSObject {
    NSString* lat;
    NSString* lng;
    NSDictionary* restaurantList;
}

@property (strong) NSString* lat;
@property (strong) NSString* lng;
@property (strong) NSDictionary* restaurantList;

- (id)init: (NSString*) latString :(NSString*) lngString;
- (int) getRestaurantCount;

@end
