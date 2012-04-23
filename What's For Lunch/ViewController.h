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

@interface ViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, IASKSettingsDelegate>
{
    CLLocationManager* locationManager;
    Restaurants *restaurants;

    //iPhone
    UIPickerView *restaurantPicker;
    IBOutlet UITextView *lblAddress;
    IBOutlet UITextView *lblUrl;

    //iPad
    IBOutlet UIWebView *wvRestaurant;

    IASKAppSettingsViewController *appSettingsViewController;
   
}

@property (strong) IASKAppSettingsViewController* appSettingsViewController;
@property (strong) CLLocationManager* locationManager;
@property (strong) IBOutlet UIPickerView *restaurantPicker;

// Selects a random restaurant in the picker
- (IBAction) btnGetRestaurant:(id)sender;
- (IBAction) btnOpenSettings:(id)sender;

@end
