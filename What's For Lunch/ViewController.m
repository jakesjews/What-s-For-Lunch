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
    // If more than one restaurant was returned by yelp then select a random restaurant in the picker
    if ([restaurants getRestaurantCount] > 0) {
        
        // Use arc4Random because it does not require a seed and set it to a max value of the number
        // of restaurants in the picker
        int rand = arc4random() % [restaurants getRestaurantCount];
        
        // Select the restaurant index matching the previously created random number
        [restaurantPicker selectRow:rand inComponent:0 animated:YES];
        [restaurantPicker reloadComponent:0];
    }
    
    [self fillSelectedRestaurant];
}

- (void)fillSelectedRestaurant
{
    if ([restaurants getRestaurantCount] > 0) {
        
        // Get a reference to the selected restaurant
        NSInteger row = [restaurantPicker selectedRowInComponent:0];
        id restaurant = [[[restaurants restaurantList] valueForKeyPath: @"businesses"] objectAtIndex:row];
        
        // Get the url for the restaurant that was returned by the Yelp API
        NSString* urlString = [restaurant valueForKeyPath: @"url"];
        
        // If the device is an iPad navigate the web view to the restaurant's Yelp URL
        if ([self isIpad]) {
            
            NSURLRequest *requestObj = [NSURLRequest requestWithURL:
                                        [NSURL URLWithString: urlString]];
            [wvRestaurant loadRequest:requestObj];
            
        // If the device is an iphone fill in the web site text area with the Yelp URL and fill in the 
        // address text area with the restaurant's address
        } else {
            
            NSString* address = [[restaurant valueForKeyPath: @"location.display_address"] componentsJoinedByString: @" "];
            
            [lblAddress setText: address];
            lblAddress.dataDetectorTypes = UIDataDetectorTypeAddress;
            [lblUrl setText: urlString];
        }
    } else {
        [lblAddress setText: @""];
        [lblUrl setText: @""];
    }
}

- (NSString *)getLatString
{ 
    return [@(self.locationManager.location.coordinate.latitude) stringValue];
}

- (NSString *)getLngString
{   
    return [@(self.locationManager.location.coordinate.longitude) stringValue];
}

- (void)loadData
{
    // Create a restaurants object with the string values of the current latitude and longitude
    restaurants = [[Restaurants alloc] init: [self getLatString]: [self getLngString]];
    [restaurantPicker reloadAllComponents];
    
}

#pragma mark - Events

- (IBAction)btnGetRestaurant:(id)sender {
    [self displayRandomRestaurant];
}

- (IBAction)btnOpenSettings:(id)sender {
    UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController: self.appSettingsViewController];
    self.appSettingsViewController.showDoneButton = YES;
    [self presentModalViewController:aNavController animated:YES];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    //If the ad banner was not visible and an ad was loaded then make the banner visible
    if (!self.adBannerViewIsVisible) {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        [UIView commitAnimations];
        self.adBannerViewIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    //If the ad banner was visible but an ad could not be loaded then make the banner invisible
    if (self.adBannerViewIsVisible) {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        [UIView commitAnimations];
        self.adBannerViewIsVisible = NO;
    }
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
    [self displayRandomRestaurant];
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
    return [restaurants getRestaurantCount];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[[restaurants restaurantList] valueForKeyPath: @"businesses.name"] objectAtIndex:row];
}

#pragma mark - View lifecycle

- (void)becomeActive:(NSNotification *)notification
{
    [self loadData];
    [self displayRandomRestaurant];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    adBanner.delegate = self;
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
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
            self.adBanner.currentContentSizeIdentifier =
            ADBannerContentSizeIdentifierLandscape;
        else
            self.adBanner.currentContentSizeIdentifier =
            ADBannerContentSizeIdentifierPortrait;
        return YES;
    }
}

@end
