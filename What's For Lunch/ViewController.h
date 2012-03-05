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

@interface ViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>  {
    CLLocationManager* locationManager;
    Restaurants *restaurants;

    //iPhone
    UIPickerView *restaurantPicker;
    __weak IBOutlet UITextView *lblAddress;
    __weak IBOutlet UITextView *lblUrl;

    //iPad
    __weak IBOutlet UIWebView *wvRestaurant;
   
}

@property (strong) CLLocationManager* locationManager;
@property (strong) IBOutlet UIPickerView *restaurantPicker;

- (IBAction) btnGetRestaurant:(id)sender;

- (NSString*) getLatString;
- (NSString*) getLngString;
- (void) fillSelectedRestaurant;

@end
