//
//  BMWDetailViewController.m
//  Notes
//
//  Created by Benjamin Wang on 3/1/13.
//  Copyright (c) 2013 Benjamin Wang. All rights reserved.
//

#import "BMWDetailViewController.h"


@interface BMWDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) CLLocationManager *locationManager;
- (void)configureView;
@end

@implementation BMWDetailViewController


#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    
    //Setting up location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = 100.0;
    self.locationManager.distanceFilter = 1000.0;
    [self.locationManager startMonitoringSignificantLocationChanges];
    

    //Setting up map
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeStandard;

    //Update once, add pin to map, then stop monitoring location changes
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Notes", @"Notes");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}


#pragma mark - MapView Methods

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:
(NSArray *) locations
{
    CLLocation *location = [locations lastObject];
    NSLog(@"lat: %f, lon: %f", location.coordinate.latitude, location.coordinate.longitude);
    [self addPinToMapAtLocation:location];
}

- (void) addPinToMapAtLocation:(CLLocation *) location
{
    //this is the red pin
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = location.coordinate;
    
    //Labels, with latitude/longitude markings to two decimal places
    pin.title = @"Note created here";
    float lat = location.coordinate.latitude;
    float lon = location.coordinate.longitude;
    pin.subtitle = [NSString stringWithFormat: @"lat: ~%f, lon: ~%f", lat, lon];
    
    //Add pin to map, puts center of screen at the pin
    [self.mapView addAnnotation:pin];
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.01;
    span.longitudeDelta = 0.01;
    CLLocationCoordinate2D newCenter;
    newCenter.latitude = location.coordinate.latitude;
    newCenter.longitude = location.coordinate.longitude;
    region.span = span;
    region.center = newCenter;
    [self.mapView setRegion:region animated:YES];
}

@end
