//
//  Utilities.m
//  MapTest
//
//  Created by Viacheslav Goroshniuk on 11.10.17.
//  Copyright © 2017 Viacheslav Goroshniuk. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (void)showSimpleAlertWithTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewController{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [viewController presentViewController:alert animated:YES completion:nil];
}

+ (void)zoomToUserLocationInMapView:(MKMapView *)mapView{
    CLLocation *location = mapView.userLocation.location;
    if (location) {
        CLLocationCoordinate2D coordinate = location.coordinate;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 10000.0f, 10000.0f);
        [mapView setRegion:region animated:YES];
    }
}



@end
