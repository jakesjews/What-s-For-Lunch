//
//  ViewController.h
//  I'm Hungry
//
//  Created by Jacob Jewell on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Restaurants.h"
#import <QuartzCore/QuartzCore.h>
#import "IASKAppSettingsViewController.h"
#import <iAd/iAd.h>

@interface ViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, ADBannerViewDelegate, IASKSettingsDelegate>
{
    Restaurants *restaurants;

    // iPhone
    IBOutlet UITextView *lblAddress;
    IBOutlet UITextView *lblUrl;

    // iPad
    IBOutlet UIWebView *wvRestaurant;
}

@property (nonatomic) IASKAppSettingsViewController* appSettingsViewController;
@property (strong) CLLocationManager* locationManager;
@property (strong) IBOutlet UIPickerView *restaurantPicker;
@property (strong) IBOutlet ADBannerView *adBanner;
@property BOOL adBannerViewIsVisible;

// Selects a random restaurant in the picker
- (IBAction) btnGetRestaurant:(id)sender;
// Opens the settings view
- (IBAction) btnOpenSettings:(id)sender;
//If the banner loaded an ad make sure it is visible
- (void) bannerViewDidLoadAd:(ADBannerView *)banner;
//If the banner failed to load an ad make it invisible
- (void) bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error;

@end
