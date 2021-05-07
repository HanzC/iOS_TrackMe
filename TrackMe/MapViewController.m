//
//  MapViewController.m
//  TrackMe
//
//  Created by Hanz Meyer on 4/13/21.
//

#import "MapViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface MapViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIButton *arrowButton;
@property (nonatomic, assign) BOOL nextRegionChangeIsFromUserInteraction;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _mapView.layer.cornerRadius = 5;
    _mapView.layer.shadowOpacity = 0.8;
    _mapView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    
    self.arrowButton.tag = 111;
    
    // Map drag handler
    UIPanGestureRecognizer *panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRec setDelegate:self];
    [self.mapView addGestureRecognizer:panRec];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (IBAction)closeMapView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation
{
    /*
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = aUserLocation.coordinate.latitude;
    location.longitude = aUserLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [aMapView setRegion:region animated:YES];
    */
    
    //[self.mapView setCenterCoordinate:aUserLocation.location.coordinate animated:YES];
}


- (IBAction)changeRegion:(id)sender
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 300.0f, 300.0f);
    if(self.arrowButton.tag == 111)
    {
        //this is the Arrow Clear state
        [self.arrowButton setImage:[UIImage imageNamed:@"arrowBlue"] forState:UIControlStateNormal];
        self.arrowButton.tag = 222;
        [self.mapView setRegion:region animated:YES];
        return;
    }
    if(self.arrowButton.tag == 222)
    {
        //this is the Arrow Blue state
        [self.arrowButton setImage:[UIImage imageNamed:@"arrowUp"] forState:UIControlStateNormal];
        self.arrowButton.tag = 333;
        self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
        return;
    }
    if(self.arrowButton.tag == 333)
    {
        //this is the Arrow Up state
        [self.arrowButton setImage:[UIImage imageNamed:@"arrowClear"] forState:UIControlStateNormal];
        self.arrowButton.tag = 111;
        self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        //NSLog(@"Map drag begin");
        [self.arrowButton setImage:[UIImage imageNamed:@"arrowClear"] forState:UIControlStateNormal];
        self.arrowButton.tag = 111;
        self.mapView.userTrackingMode = MKUserTrackingModeNone;
    }
}

#pragma mark - MapView Delegates
//- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
//{
//    UIView *view = mapView.subviews.firstObject;
//
//    //    Look through gesture recognizers to determine
//    //    whether this region change is from user interaction
//    for(UIGestureRecognizer* recognizer in view.gestureRecognizers)
//    {
//        //    The user cause of this...
//        if(recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateEnded)
//        //if(recognizer.state == UIGestureRecognizerStateBegan)
//        {
//            self.nextRegionChangeIsFromUserInteraction = YES;
//
//            CLLocationCoordinate2D center = self.mapView.userLocation.coordinate;
//            //center.latitude = self.mapView.region.span.latitudeDelta * 0.25;
//            //NSLog(@" *** MapViewController > regionWillChangeAnimated > Latitude: %f", center.latitude);
//            NSLog(@" *** MapViewController > regionWillChangeAnimated > Latitude: %f", self.mapView.region.center.latitude);
//            //if (center.latitude < (center.latitude + 0.000005))
////            if ((center.latitude+=0.1) < center.latitude)
////            {
//                [self.arrowButton setImage:[UIImage imageNamed:@"arrowClear"] forState:UIControlStateNormal];
//                self.arrowButton.tag = 111;
////            }
//            //break;
//        }
//    }
//}

//- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
//{
//    if(self.nextRegionChangeIsFromUserInteraction)
//    {
//        self.nextRegionChangeIsFromUserInteraction = NO;
//
//        //    Perform code here
//        [self.arrowButton setImage:[UIImage imageNamed:@"arrowClear"] forState:UIControlStateNormal];
//        self.arrowButton.tag = 111;
//        self.mapView.userTrackingMode = MKUserTrackingModeNone;
//    }
//}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.alpha = 0.75;
    renderer.lineWidth = 1.0;

    return renderer;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
