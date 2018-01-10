//
//  Utilities.h
//  MapTest
//
//  Created by Viacheslav Goroshniuk on 11.10.17.
//  Copyright © 2017 Viacheslav Goroshniuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;
@import MapKit;

@interface Utilities : NSObject

+ (void)showSimpleAlertWithTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewController;

+ (void)zoomToUserLocationInMapView:(MKMapView *)mapView;

@end
