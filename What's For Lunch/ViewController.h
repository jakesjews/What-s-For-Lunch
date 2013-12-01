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
#import <MapKit/MapKit.h>
#import <StoreKit/StoreKit.h>

@interface ViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, ADBannerViewDelegate, IASKSettingsDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    Restaurants *restaurants;
}

@property (nonatomic) IASKAppSettingsViewController* appSettingsViewController;
@property (strong) CLLocationManager* locationManager;
@property (strong) IBOutlet UIPickerView *restaurantPicker;
@property (strong) IBOutlet ADBannerView *adBanner;
@property BOOL adBannerViewIsVisible;

- (IBAction)directionsClicked:(id)sender;
- (IBAction)websiteClicked:(id)sender;
- (IBAction)inAppClicked:(id)sender;

// Selects a random restaurant in the picker
- (IBAction) btnGetRestaurant:(id)sender;
// Opens the settings view
- (IBAction) btnOpenSettings:(id)sender;
//If the banner loaded an ad make sure it is visible
- (void) bannerViewDidLoadAd:(ADBannerView *)banner;
//If the banner failed to load an ad make it invisible
- (void) bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error;

- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;

@end
