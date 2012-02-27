//
//  Restaurants.m
//  I'm Hungry
//
//  Created by Jacob Jewell on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Restaurants.h"

@implementation Restaurants

@synthesize lat, lng, restaurants;

static NSString* const serviceURL = @"http://api.yelp.com/v2/search?term=fast%20food&radius_filter=40232&";

static NSString* const CONSUMER_KEY = @"jokgmNi8LtP5IW8muDE5-Q";
static NSString* const CONSUMER_SECRET = @"0F_ZRudvsGPQ_kBXW2VnDmDXpjo";
static NSString* const TOKEN = @"XVrjcUock5lrR8GJ4orqbzuLQs_OmPkN";
static NSString* const TOKEN_SECRET = @"jqXa9QivTJF1qCoTZ8RpfwpCvhs";

- (id)init: (NSString*) latString: (NSString*) lngString
{
    self = [super init];
    
    if (self) {
        lat = latString;
        lng = lngString;
        [self getRestaurants];
    }
    
    return self;
}

- (NSString*) getRequestURLString
{    
    return [NSString stringWithFormat:@"%@ll=%@,%@", serviceURL,[self lat],[self lng]];
}

- (OAMutableURLRequest*) getOARequest
{
    NSString *realm;
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey: CONSUMER_KEY secret: CONSUMER_SECRET];
    OAToken *token = [[OAToken alloc] initWithKey: TOKEN secret: TOKEN_SECRET]; 
    id<OASignatureProviding, NSObject> provider = [[OAHMAC_SHA1SignatureProvider alloc] init];
    
    OAMutableURLRequest* request = [[OAMutableURLRequest alloc] 
                                    initWithURL: [NSURL URLWithString:[self getRequestURLString]]
                                    consumer: consumer
                                    token: token
                                    realm: realm
                                    signatureProvider: provider];
    [request prepare];
    return request;
}

- (void) getRestaurants
{
    NSHTTPURLResponse* response;    
    NSError* error;
    
    NSData* data = [NSURLConnection sendSynchronousRequest: [self getOARequest] 
                                         returningResponse: &response 
                                                     error: &error];
    
    if ([response statusCode] == 200) {
        NSError *jsonParsingError = nil;
        restaurants = [NSJSONSerialization JSONObjectWithData: data 
                                                      options: 0 
                                                        error: &jsonParsingError];    
    }
}

@end
