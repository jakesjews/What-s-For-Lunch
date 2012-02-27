//
//  ViewController.m
//  I'm Hungry
//
//  Created by Jacob Jewell on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize locationManager, restaurantPicker;

- (Boolean) isIpad
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

- (void)startLocationManager
{
    self.locationManager = [CLLocationManager new];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [self.locationManager startUpdatingLocation];
}

- (void)displayRandomRestaurant
{
    int rand = arc4random() % [[[restaurants restaurants] valueForKeyPath: @"businesses"] count];
    [restaurantPicker selectRow:rand inComponent:0 animated:YES];
    [restaurantPicker reloadComponent:0];
    [self fillSelectedRestaurant];
}

- (void)fillSelectedRestaurant
{
    NSInteger row = [restaurantPicker selectedRowInComponent:0];
    id restaurant = [[[restaurants restaurants] valueForKeyPath: @"businesses"] objectAtIndex:row];
    
    NSString* urlString = [restaurant valueForKeyPath: @"url"];
    
    if ([self isIpad]) {
        
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:
                                    [NSURL URLWithString: urlString]];
        [wvRestaurant loadRequest:requestObj];
        
    } else {
        
        NSString* address = [[restaurant valueForKeyPath: @"location.display_address"] componentsJoinedByString: @" "];
        
        [lblAddress setText: address];
        [lblUrl setText: urlString];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView { 	
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [[[restaurants restaurants] valueForKeyPath: @"businesses"] count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[[restaurants restaurants] valueForKeyPath: @"businesses.name"] objectAtIndex:row];
}

- (NSString *)getLatString
{ 
    return [[NSNumber numberWithDouble:self.locationManager.location.coordinate.latitude] stringValue];
}

- (NSString *)getLngString
{   
    return [[NSNumber numberWithDouble:self.locationManager.location.coordinate.longitude] stringValue];
}

- (void)loadData
{
    restaurants = [[Restaurants alloc] init: [self getLatString]: [self getLngString]];
    
    if ([[restaurants restaurants] count] > 0) {
        [self displayRandomRestaurant];
    }
}

- (void)becomeActive:(NSNotification *)notification 
{
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self fillSelectedRestaurant];
}

- (IBAction)btnGetRestaurant:(id)sender 
{ 
    if([[restaurants restaurants] count] == 0)
    {
        [self loadData];
    }
        
    [self displayRandomRestaurant];  
}

- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [self displayRandomRestaurant];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startLocationManager];
    
    if ( ![self isIpad] ) 
    {
        lblAddress.layer.cornerRadius = 10;
        lblUrl.layer.cornerRadius = 10;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                          selector:@selector(becomeActive:)
                                          name:UIApplicationDidBecomeActiveNotification
                                          object:nil];
    [self loadData];
}

- (void)viewDidUnload
{
    restaurantPicker = nil;
    lblAddress = nil;
    lblUrl = nil;
    wvRestaurant = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
