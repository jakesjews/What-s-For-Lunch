//
//  Restaurants.m
//  I'm Hungry
//
//  Created by Jacob Jewell on 2/26/12.
//  Copyright (c) 2012 Immersive Applicatons. All rights reserved.
//

#import "Restaurants.h"

// Declare private methods
@interface Restaurants (PrivateMethods)

    // Loads restaurant data from the Yelp api
    - (void) getRestaurants;

    /*  Creates a URL to make a search request to the yelp api
        The URL is in the format http://api.yelp.com/v2/search?radius_filter=40232&term=fast%20food&ll=10.0,10.0     
        This url will not work by itself because it requires OAuth authentication
     */
    - (NSString*) getRequestURLString;

    // Creates a OAuth URL request to access the Yelp API, this is the request that is actually sent
    - (OAMutableURLRequest*) getOARequest;

@end

@implementation Restaurants

@synthesize lat, lng, restaurants;

// The base url used to construct a Yelp API request
static NSString* const serviceURL = @"http://api.yelp.com/v2/search?";

// Parameters required for authentication with the Yelp API
static NSString* const CONSUMER_KEY = @"jokgmNi8LtP5IW8muDE5-Q";
static NSString* const CONSUMER_SECRET = @"0F_ZRudvsGPQ_kBXW2VnDmDXpjo";
static NSString* const TOKEN = @"XVrjcUock5lrR8GJ4orqbzuLQs_OmPkN";
static NSString* const TOKEN_SECRET = @"jqXa9QivTJF1qCoTZ8RpfwpCvhs";

/* 
 Creates the restaurants object and retrieves all restaurants within 25 miles of
 the input latitude and longitude
 */
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
    return [NSString stringWithFormat:@"%@ll=%@,%@&radius_filter=%@&category_filter=%@",
                    serviceURL,
                    [self lat],
                    [self lng],
                    [self getRadiusFilter],
                    [self getCategoryList]];
}

- (NSString*) getRadiusFilter
{
    int distance = [[NSUserDefaults standardUserDefaults] integerForKey: @"distance_pref"];

    return [NSString stringWithFormat: @"%li", distance];
}

- (NSString*) getCategoryList
{
    NSMutableArray *categories = [[NSMutableArray alloc] init];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];

    if([settings boolForKey:@"pizza_pref"]) {
        [categories addObject: @"pizza"];
    }

    if([settings boolForKey:@"fastfood_pref"]) {
        [categories addObject: @"hotdogs"];
    }

    if([settings boolForKey:@"buffets_pref"]) {
        [categories addObject: @"buffets"];
    }

    if([settings boolForKey:@"chinese_pref"]) {
        [categories addObject: @"chinese"];
    }

    if([settings boolForKey:@"italian_pref"]) {
        [categories addObject: @"italian"];
    }

    if([settings boolForKey:@"mexican_pref"]) {
        [categories addObject: @"mexican"];
    }

    if([settings boolForKey:@"middleeast_pref"]) {
        [categories addObject: @"mideastern"];
    }

    if([settings boolForKey:@"vegan_pref"]) {
        [categories addObject: @"vegan"];
    }

    if([settings boolForKey:@"american_pref"]) {
        [categories addObject: @"tradamerican"];
    }

    if([settings boolForKey:@"delis_pref"]) {
        [categories addObject: @"delis"];
    }
    
    if([settings boolForKey:@"bars_pref"]) {
        [categories addObject: @"bars"];
    }

    if ([categories count] == 0) {
        [categories addObject: @"restaurants"];
    }

    return [categories componentsJoinedByString:@","];
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
    
    // If the response is all good then fill in the restaurant dictionary with
    // the Yelp JSON data
    if ([response statusCode] == 200) {
        NSError *jsonParsingError = nil;
        restaurants = [NSJSONSerialization JSONObjectWithData: data 
                                                      options: 0 
                                                        error: &jsonParsingError];    
    }
}

@end
