//
//  ViewController.m
//  MapTest
//
//  Created by Viacheslav Goroshniuk on 04.10.17.
//  Copyright © 2017 Viacheslav Goroshniuk. All rights reserved.
//

#import "ViewController.h"
//#import "AddGeotificationViewController.h"
#import "Geotification.h"
#import "Utilities.h"

@import MapKit;

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UISearchControllerDelegate, UISearchBarDelegate, UITextFieldDelegate> {
    
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (nonatomic, strong) NSMutableArray *geotifications;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UITextField *radiusTextField;
@property (weak, nonatomic) IBOutlet UITextField *noteTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *eventTypeSegmentedControl;

@property (weak, nonatomic) IBOutlet UIView *descriptionView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewConstraints;

@property (nonatomic, readwrite) double firstCoordinate;
@property (nonatomic, readwrite) double secondCoordinate;
@property (nonatomic, readwrite) BOOL IsFirst;


@end

@implementation ViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.showsUserLocation = YES;
    _IsFirst = YES;
    self.locationManager = [CLLocationManager new];
    [self.locationManager setDelegate:self];
    [self.locationManager requestAlwaysAuthorization];

    [self loadAllGeotifications];
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    self.addButton.enabled = !(self.radiusTextField.text.length == 0) && !
    (self.noteTextField.text.length == 0);
    
    self.bottomViewConstraints.constant = -500;
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:userLocation.coordinate fromEyeCoordinate:CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude) eyeAltitude:10000];
    if (_IsFirst) {
        _IsFirst = NO;
         [mapView setCamera:camera animated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showFullDescription:(id)sender {
    if (self.bottomViewConstraints.constant == -100) {
        self.bottomViewConstraints.constant = -210;
        self.descriptionView.alpha = 1.0;
    } else {
        self.bottomViewConstraints.constant = -100;
        self.descriptionView.alpha = 0.0;
    }
    [self.view endEditing:YES];
}

#pragma mark - Loading and saving functions

- (void) loadAllGeotifications {
    
    self.geotifications = [NSMutableArray array];
    
    NSArray *savedItems = [[NSUserDefaults standardUserDefaults] arrayForKey:kSavedItemsKey];
    if (savedItems) {
        for (id savedItem in savedItems) {
            Geotification *geotification = [NSKeyedUnarchiver unarchiveObjectWithData:savedItem];
            if ([geotification isKindOfClass:[Geotification class]]) {
                [self addGeotification: geotification];
            }
        }
    }
}

- (void) saveAllGeotifications {
    
    NSMutableArray *items = [NSMutableArray array];
    for (Geotification *geotifotaion in self.geotifications) {
        id item = [NSKeyedArchiver archivedDataWithRootObject:geotifotaion];
        [items addObject:item];
    }
    [[NSUserDefaults standardUserDefaults] setObject:items forKey:kSavedItemsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

#pragma mark - Functions that update the model/associated views with geotification changes

- (void)addGeotification:(Geotification *)geotification {
    
    [self.geotifications addObject:geotification];
    [self.mapView addAnnotation:geotification];
    [self addRadiusOverlayForGeotification: geotification];
    [self updateGeotificationsCount];
}

- (void)removeGeotification:(Geotification *)geotification{
    
    [self.geotifications removeObject:geotification];
    [self.mapView removeAnnotation:geotification];
    [self removeRadiusOverlayForGeotification:geotification];
    [self updateGeotificationsCount];
}

- (void)updateGeotificationsCount {
    
    self.title = [NSString stringWithFormat:@"Geotifications (%lu)", (unsigned long)self.geotifications.count];
    [self.navigationItem.rightBarButtonItem setEnabled:self.geotifications.count < 20];
}


#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (self.bottomViewConstraints.constant == -100) {
        self.bottomViewConstraints.constant = -210;
        self.descriptionView.alpha = 1.0;
    } else {
        self.bottomViewConstraints.constant = -100;
        self.descriptionView.alpha = 0.0;
    }
}

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *identifier = @"myGeotification";
    if ([annotation isKindOfClass:[Geotification class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (![annotation isKindOfClass:[MKPinAnnotationView class]] || annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            [annotationView setCanShowCallout:YES];
            
            UIButton *removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            removeButton.frame = CGRectMake(.0f, .0f, 23.0f, 23.0f);
            [removeButton setImage:[UIImage imageNamed:@"DeleteGeotification"] forState:UIControlStateNormal];
            [annotationView setLeftCalloutAccessoryView:removeButton];
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    return nil;
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        circleRenderer.lineWidth = 1.0f;
        circleRenderer.strokeColor = [UIColor purpleColor];
        circleRenderer.fillColor = [[UIColor purpleColor] colorWithAlphaComponent:.4f];
        return circleRenderer;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    Geotification *geotification = (Geotification *) view.annotation;
    [self stopMonitoringGeotification:geotification];
    [self removeGeotification:geotification];
    [self saveAllGeotifications];
}

#pragma mark - Map overlay functions

- (void) addRadiusOverlayForGeotification:(Geotification *) geotification {
    
    if (self.mapView) [self.mapView addOverlay:[MKCircle circleWithCenterCoordinate:geotification.coordinate radius:geotification.radius]];
}

- (void)removeRadiusOverlayForGeotification:(Geotification *)geotification{
    if (self.mapView){
        NSArray *overlays = self.mapView.overlays;
        for (MKCircle *circleOverlay in overlays) {
            if ([circleOverlay isKindOfClass:[MKCircle class]]) {
                CLLocationCoordinate2D coordinate = circleOverlay.coordinate;
                if (coordinate.latitude == geotification.coordinate.latitude && coordinate.longitude == geotification.coordinate.longitude && circleOverlay.radius == geotification.radius) {
                    [self.mapView removeOverlay:circleOverlay];
                    break;
                }
            }
        }
    }
}

#pragma mark - Other mapview functions

- (IBAction)zoomToCurrentLocation:(id)sender {
    
    [Utilities zoomToUserLocationInMapView:self.mapView];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    [self.mapView setShowsUserLocation:status==kCLAuthorizationStatusAuthorizedAlways];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    NSLog(@"Monitoring failed for region with identifer: %@", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Location Manager failed with the following error: %@", error);
}


#pragma mark - Geotifications

- (CLCircularRegion *)regionWithGeotification:(Geotification *)geotification{
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:geotification.coordinate radius:geotification.radius identifier:geotification.identifier];
    [region setNotifyOnEntry:geotification.eventType==OnEntry];
    [region setNotifyOnExit:!region.notifyOnEntry];
    
    return region;
}

- (void)startMonitoringGeotification:(Geotification *)geotification{
    if (![CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        [Utilities showSimpleAlertWithTitle:@"Error" message:@"Geofencing is not supported on this device!" viewController:self];
        return;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        [Utilities showSimpleAlertWithTitle:@"Warning" message:@"Your geotification is saved but will only be activated once you grant GeofencesTest permission to access the device location." viewController:self];
    }
    
    CLCircularRegion *region = [self regionWithGeotification:geotification];
    [self.locationManager startMonitoringForRegion:region];
}

- (void)stopMonitoringGeotification:(Geotification *)geotification{
    for (CLCircularRegion *circularRegion in self.locationManager.monitoredRegions) {
        if ([circularRegion isKindOfClass:[CLCircularRegion class]]) {
            if ([circularRegion.identifier isEqualToString:geotification.identifier]) {
                [self.locationManager stopMonitoringForRegion:circularRegion];
            }
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddGeotificationViewController"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        AddGeotificationViewController *vc = navigationController.viewControllers.firstObject;
        [vc setDelegate:self];
    }
}
 */

#pragma mark - UISearchBarDelegate

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    //Activity Indicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] init];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    activityIndicator.center = self.view.center;
    activityIndicator.hidesWhenStopped = true;
    [activityIndicator startAnimating];
    
    [self.view addSubview:activityIndicator];
    
    //Hide searchBar
    [searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:true completion:nil];
    
    //Create the search request
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    searchRequest.naturalLanguageQuery = searchBar.text;
    
    MKLocalSearch *activeSearch = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    [activeSearch startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        
        [activityIndicator stopAnimating];
        [UIApplication.sharedApplication endIgnoringInteractionEvents];
        
        if (response == nil) {
            
            NSLog(@"Error");
            
        } else {
           
            //Remove annotations
            
            //Getting data
            
            CLLocationDegrees latitude = response.boundingRegion.center.latitude;
            CLLocationDegrees longitude = response.boundingRegion.center.longitude;
            
            //Create annotation
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.title = searchBar.text;
            annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            self.firstCoordinate = latitude;
            self.secondCoordinate = longitude;
            [self.mapView addAnnotation:annotation];
            
            //Zooming in on annotation
            MKMapRect zoomRect = MKMapRectNull;
            
            for (id <MKAnnotation> annotation in self.mapView.annotations) {
                
                CLLocationCoordinate2D location = annotation.coordinate;
                MKMapPoint center = MKMapPointForCoordinate(location);
                static double delta = 500;
                
                MKMapRect rect = MKMapRectMake(center.x - delta, center.y - delta, delta * 2, delta * 2);
                zoomRect = MKMapRectUnion(zoomRect, rect);
            }
            
            zoomRect = [self.mapView mapRectThatFits:zoomRect];
            
            [self.mapView setVisibleMapRect:zoomRect
                                edgePadding:UIEdgeInsetsMake(50.f, 50.f, 50.f, 50.f)
                                   animated:YES];
            
        }
    }];
}


#pragma mark - Action

- (IBAction)actionSearch:(UIBarButtonItem *)sender {
    
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.searchBar.delegate = self;
    
    [self presentViewController:searchController animated:YES completion:nil];
    
}

- (IBAction)textFieldEditingChanged:(UITextField *)sender {
    
//    self.addButton.enabled = !(self.radiusTextField.text.length == 0) && !
//    (self.noteTextField.text.length == 0);
//
//    self.bottomViewConstraints.constant = -500;
    
}



- (IBAction)onAdd:(id)sender {
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.firstCoordinate, self.secondCoordinate);
    CGFloat radius = self.radiusTextField.text.floatValue;
    NSString *identifier = [[NSUUID new] UUIDString];
    NSString *note = self.noteTextField.text;
    EventType eventType = (self.eventTypeSegmentedControl.selectedSegmentIndex == 0) ? OnEntry : OnExit;
    
    if (self.mapView)
    {
        Geotification* geotification = [[Geotification alloc] initWithCoordinate:coordinate radius:radius identifier:identifier note:note eventType:eventType];
        [self addGeotification:geotification];
        [self.mapView addOverlay:[MKCircle circleWithCenterCoordinate: coordinate radius: radius]];
        [self saveAllGeotifications];
    }
    
    [self.view endEditing:YES];
}

@end
