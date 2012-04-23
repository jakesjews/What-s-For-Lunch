//
//  ViewController.m
//  I'm Hungry
//
//  Created by Jacob Jewell on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

// Declare private methods
@interface ViewController (PrivateMethods)

    // Fills in the details for the restaurant selected in the picker
    - (void) fillSelectedRestaurant;

    // Starts the location manager with an accuracy of 1 kilometer
    - (void) startLocationManager;

    // Whether the app is running in an iPad or not
    - (Boolean) isIpad;

    // Selects a random restaurant in the picker
    - (void) displayRandomRestaurant;

    // Converts the current latitude to a string for the Yelp api request
    - (NSString*) getLatString;

    // Converts the current longitude to a string for the Yelp api request    
    - (NSString*) getLngString;

    // Loads a Restaurants object using the current latitude and longitude
    - (void)loadData;

@end

@implementation ViewController

@synthesize locationManager, restaurantPicker, appSettingsViewController;

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
    // Use arc4Random because it does not require a seed and set it to a max value of the number
    // of restaurants in the picker
    int rand = arc4random() % [[[restaurants restaurants] valueForKeyPath: @"businesses"] count];
    
    // Select the restaurant index matching the previously created random number
    [restaurantPicker selectRow:rand inComponent:0 animated:YES];
    [restaurantPicker reloadComponent:0];
    [self fillSelectedRestaurant];
}

- (void)fillSelectedRestaurant
{
    // Get a reference to the selected restaurant
    NSInteger row = [restaurantPicker selectedRowInComponent:0];
    id restaurant = [[[restaurants restaurants] valueForKeyPath: @"businesses"] objectAtIndex:row];
    
    // Get the url for the restaurant that was returned by the Yelp API
    NSString* urlString = [restaurant valueForKeyPath: @"url"];
    
    // If the device is an iPad navigate the web view to the restaurant's Yelp URL
    if ([self isIpad]) {
        
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:
                                    [NSURL URLWithString: urlString]];
        [wvRestaurant loadRequest:requestObj];
    
    /* If the device is an iphone fill in the web site text area with the Yelp URL and fill in the 
       address text area with the restaurant's address
     */
    } else {
        
        NSString* address = [[restaurant valueForKeyPath: @"location.display_address"] componentsJoinedByString: @" "];
        
        [lblAddress setText: address];
        lblAddress.dataDetectorTypes = UIDataDetectorTypeAddress;
        [lblUrl setText: urlString];
    }
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
    // Create a restaurants object with the string values of the current latitude and longitude
    restaurants = [[Restaurants alloc] init: [self getLatString]: [self getLngString]];
    
    int restaurantCount = [[[restaurants restaurants] valueForKeyPath: @"businesses"] count];
    
    // If more than one restaurant was returned by yelp then select a random restaurant in the picker
    if (restaurantCount > 0) {
        [self displayRandomRestaurant];
    }
}

#pragma mark - Events

- (IBAction)btnGetRestaurant:(id)sender {
    [self loadData];
}

- (IBAction)btnOpenSettings:(id)sender {
    UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController: self.appSettingsViewController];
    self.appSettingsViewController.showDoneButton = YES;
    [self presentModalViewController:aNavController animated:YES];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self fillSelectedRestaurant];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [self displayRandomRestaurant];
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController *)sender {

    [self dismissModalViewControllerAnimated:YES];

    [self loadData];

}

#pragma mark - InAppSettingsKit

- (IASKAppSettingsViewController*)appSettingsViewController {
    if (!appSettingsViewController) {
        appSettingsViewController = [[IASKAppSettingsViewController alloc] initWithNibName:@"IASKAppSettingsView" bundle:nil];
        appSettingsViewController.delegate = self;
    }
    return appSettingsViewController;
}

#pragma mark - PickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [[[restaurants restaurants] valueForKeyPath: @"businesses"] count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[[restaurants restaurants] valueForKeyPath: @"businesses.name"] objectAtIndex:row];
}

#pragma mark - View lifecycle

- (void)becomeActive:(NSNotification *)notification
{
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startLocationManager];
    
    // Add snazzy rounded corners to the iPhone text areas
    if ( ![self isIpad] ) 
    {
        lblAddress.layer.cornerRadius = 10;
        lblUrl.layer.cornerRadius = 10;
    }
    
    // Add a notification for when the app is loaded from the background
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
