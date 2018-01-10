//
//  ViewController.h
//  MapTest
//
//  Created by Viacheslav Goroshniuk on 04.10.17.
//  Copyright © 2017 Viacheslav Goroshniuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Geotification.h"

static NSString *kSavedItemsKey = @"savedItems";

@import MapKit;

@protocol ViewControllerDelegate;

@interface ViewController : UIViewController

@property (nonatomic, strong) id <ViewControllerDelegate> delegate;

- (IBAction)onAdd:(id)sender;
- (IBAction)textFieldEditingChanged:(UITextField *)sender;

- (IBAction)actionSearch:(UIBarButtonItem *)sender;

@end



