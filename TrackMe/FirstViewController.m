//
//  ViewController.m
//  TrackMe
//
//  Created by Hanz Meyer on 4/8/21.
//

#import "FirstViewController.h"
#import "GLManager.h"
#import <QuartzCore/QuartzCore.h>
#import "MapViewController.h"

@interface FirstViewController ()

@property (strong, nonatomic) NSTimer *viewRefreshTimer;
@property (strong, nonatomic) MapViewController *mapController;
@property (nonatomic, assign) BOOL nextRegionChangeIsFromUserInteraction;

@end

@implementation FirstViewController


NSArray *intervalMap;
NSArray *intervalMapStrings;
NSString *tmpLabel;
MKPointAnnotation *point;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    intervalMap = @[@1, @5, @10, @15, @30, @60, @120, @300, @600, @1800, @-1];
    intervalMapStrings = @[@"1s", @"5s", @"10s", @"15s", @"30s", @"1m", @"2m", @"5m", @"10m", @"30m", @"off"];
    
//    [[GLManager sharedManager] accountInfo:^(NSString *name) {
//        self.accountInfo.text = name;
//    }];
    
//    UIImage *pattern = [UIImage imageNamed:@"topobkg"];
//    self.view.backgroundColor = [UIColor colorWithPatternImage:pattern];
//    [self.tripView.layer setCornerRadius:6.0];
//    [self.sendNowButton.layer setCornerRadius:4.0];
//    [self.tripStartStopButton.layer setCornerRadius:4.0];
//    [self setNeedsStatusBarAppearanceUpdate];
    
    _mapController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapView"];
    
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    
    self.nextRegionChangeIsFromUserInteraction = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [self sendingFinished];
    
    if([GLManager sharedManager].sendingInterval) {
        self.sendIntervalSlider.value = [intervalMap indexOfObject:[GLManager sharedManager].sendingInterval];
        [self updateSendIntervalLabel];
    }
    
    [self updateTripState];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newDataReceived)
                                                 name:GLNewDataNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendingStarted)
                                                 name:GLSendingStartedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendingFinished)
                                                 name:GLSendingFinishedNotification
                                               object:nil];

    self.viewRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                             target:self
                                                           selector:@selector(refreshView)
                                                           userInfo:nil
                                                            repeats:YES];

    NSLocale *locale = [NSLocale currentLocale];
    self.usesMetricSystem = [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];
    if(self.usesMetricSystem) {
        self.tripDistanceUnitLabel.text = @"km";
    } else {
        self.tripDistanceUnitLabel.text = @"miles";
    }
    
    if([GLManager sharedManager].gogoTrackerEnabled == YES) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    } else {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.viewRefreshTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)viewWillUnload {
    [self.viewRefreshTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    NSLog(@"view is deallocd");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - MapView Delegates
- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation
{
    MKCoordinateRegion region;
//    MKCoordinateSpan span;
//    span.latitudeDelta = 0.005;
//    span.longitudeDelta = 0.005;
//    CLLocationCoordinate2D location;
//    location.latitude = aUserLocation.coordinate.latitude;
//    location.longitude = aUserLocation.coordinate.longitude;
//    region.span = span;
//    region.center = location;
//    [aMapView setRegion:region animated:YES];
//    [self.mapView setCenterCoordinate:aUserLocation.location.coordinate animated:YES];
    
    if(self.nextRegionChangeIsFromUserInteraction)
    {
        self.nextRegionChangeIsFromUserInteraction = NO;
        region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000.0f, 1000.0f);
        [self.mapView setRegion:region animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    UIView *view = mapView.subviews.firstObject;
    
    //    Look through gesture recognizers to determine
    //    whether this region change is from user interaction
    for(UIGestureRecognizer* recognizer in view.gestureRecognizers)
    {
        //    The user cause of this...
        if(recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateEnded)
        {
            //self.nextRegionChangeIsFromUserInteraction = YES;
        }
    }
}


#pragma mark - Tracking Interface

- (void)newDataReceived {
    //    NSLog(@"New data received!");
    //    NSLog(@"Location: %@", [GLManager sharedManager].lastLocation);
    //    NSLog(@"Activity: %@", [GLManager sharedManager].lastMotion);
    self.locationAgeLabel.textColor = [UIColor whiteColor];
    [self refreshView];
}

- (void)sendingStarted {
    self.sendNowButton.titleLabel.text = @"Sending...";
    self.sendNowButton.backgroundColor = [UIColor colorWithRed:74.0/255.0 green:150.0/255.0 blue:107.0/255.0 alpha:1.0];
    //self.sendNowButton.enabled = NO;
}

- (void)sendingFinished {
    self.sendNowButton.titleLabel.text = @"Send Now";
    if([[GLManager sharedManager] apiEndpointURL] == nil) {
        self.sendNowButton.backgroundColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0];
        //self.sendNowButton.enabled = NO;
    } else {
        self.sendNowButton.backgroundColor = [UIColor colorWithRed:106.0/255.0 green:212.0/255.0 blue:150.0/255.0 alpha:1.0];
        self.sendNowButton.enabled = YES;
    }
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (NSString *)speedUnitText {
    if(self.usesMetricSystem) {
        return @"KM/H";
    } else {
        return @"MPH";
    }
}

- (void)refreshView {
    
    NSString *stringLoc = [NSString stringWithFormat:@"%.06f", [GLManager sharedManager].lastLocation.coordinate.latitude];
    if (![stringLoc isEqualToString:tmpLabel])
    {
        NSLog(@" *** FirstViewController > refreshView > NOT EQUAL *** ");
        NSLog(@" *** FirstViewController > refreshView > String:    %@", stringLoc);
        NSLog(@" *** FirstViewController > refreshView > Text:      %@", tmpLabel);
        NSLog(@"\n\n");
        
        point = [[MKPointAnnotation alloc] init];
        point.coordinate = [GLManager sharedManager].lastLocation.coordinate;
        //point.title = @"Where am I?";
        //point.subtitle = @"I'm here!!!";
        [self.mapView addAnnotation:point];
    }
    
    CLLocation *location = [GLManager sharedManager].lastLocation;
    tmpLabel = [NSString stringWithFormat:@"%.06f", location.coordinate.latitude];
    self.locationLabel.text = [NSString stringWithFormat:@"%-4.4f\n%-4.4f", location.coordinate.latitude, location.coordinate.longitude];
    self.locationAltitudeLabel.text = [NSString stringWithFormat:@"+/-%dm %dm", (int)round(location.horizontalAccuracy), (int)round(location.altitude)];

    int speed;
    if(self.usesMetricSystem) {
        speed = (int)(round(location.speed*3.6));
    } else {
        speed = (int)(round(location.speed*2.23694));
    }
    if(speed < 0) speed = 0;
    self.locationSpeedLabel.text = [NSString stringWithFormat:@"%d", speed];

    int age = -(int)round([GLManager sharedManager].lastLocation.timestamp.timeIntervalSinceNow);
    if(age == 1) age = 0;
    self.locationAgeLabel.text = [FirstViewController timeFormatted:age];
    
    NSString *motionTypeString;
    CMMotionActivity *activity = [GLManager sharedManager].lastMotion;
    if(activity.walking)
        motionTypeString = @"walking";
    else if(activity.running)
        motionTypeString = @"running";
    else if(activity.cycling)
        motionTypeString = @"cycling";
    else if(activity.automotive)
        motionTypeString = @"driving";
    else if(activity.stationary)
        motionTypeString = @"stationary";
    else {
        if([GLManager sharedManager].lastMotionString)
            motionTypeString = [GLManager sharedManager].lastMotionString;
        else
            motionTypeString = nil;
    }

    if(motionTypeString != nil) {
        self.motionTypeLabel.text = motionTypeString;
    } else {
        self.motionTypeLabel.text = @"";
    }
    
    self.locationSpeedUnitLabel.text = [self speedUnitText];

    if([GLManager sharedManager].lastSentDate) {
        age = -(int)round([GLManager sharedManager].lastSentDate.timeIntervalSinceNow);
        self.queueAgeLabel.text = [NSString stringWithFormat:@"%@", [FirstViewController timeFormatted:age]];
    } else {
        self.queueAgeLabel.text = @"n/a";
    }
    
    [[GLManager sharedManager] numberOfLocationsInQueue:^(long num) {
        self.queueLabel.text = [NSString stringWithFormat:@"%ld", num];
        point.title = [NSString stringWithFormat:@"%ld", num];
    }];

    [self updateTripState];
    
    if([GLManager sharedManager].currentFlightSummary) {
        self.flightSummary.text = [GLManager sharedManager].currentFlightSummary;
        self.flightInfoView.hidden = NO;
    } else {
        self.flightSummary.text = @"";
        self.flightInfoView.hidden = YES;
    }
}

- (IBAction)sendQueue:(id)sender {
    [[GLManager sharedManager] sendQueueNow];
}

- (void)updateSendIntervalLabel {
    NSString *val = intervalMapStrings[(int)roundf([self.sendIntervalSlider value])];
    self.sendIntervalLabel.text = val;
}

- (IBAction)sendIntervalDragged:(UISlider *)sender {
    // Snap to whole numbers
    sender.value = roundf([sender value]);
    [self updateSendIntervalLabel];
}

- (IBAction)sendIntervalChanged:(UISlider *)sender {
    sender.value = roundf([sender value]);
    NSNumber *val = intervalMap[(int)roundf([self.sendIntervalSlider value])];
    if([GLManager sharedManager].sendingInterval != val) {
        [self updateSendIntervalLabel];
        [GLManager sharedManager].sendingInterval = val;
    }
}

- (IBAction)locationAgeWasTapped:(id)sender {
    self.locationAgeLabel.textColor = [UIColor colorWithRed:(210.f/255.f) green:(30.f/255.f) blue:(30.f/255.f) alpha:1];
    [[GLManager sharedManager] refreshLocation];
}

- (IBAction)locationCoordinatesWasTapped:(UILongPressGestureRecognizer *)sender {
    if(sender.state == UIGestureRecognizerStateBegan) {
        CLLocation *location = [GLManager sharedManager].lastLocation;
        NSString *string = [NSString stringWithFormat:@"%.5f,%.5f", location.coordinate.latitude, location.coordinate.longitude];

        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:string];
        NSLog(@"Copied %@", string);

        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Copied"
                                                                       message:string
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                             }];
        [alert addAction:closeAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Trip Interface

- (double)metersToDisplayUnits:(double)meters {
    if(self.usesMetricSystem) {
        return meters * 0.001;
    } else {
        return meters * 0.000621371;
    }
}

- (void)updateTripState {
    self.currentModeImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [GLManager sharedManager].currentTripMode]];
    self.currentModeLabel.text = [GLManager sharedManager].currentTripMode;

    if([GLManager sharedManager].tripInProgress) {
        [self.tripStartStopButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.tripStartStopButton.backgroundColor = [UIColor colorWithRed:252.f/255.f green:109.f/255.f blue:111.f/255.f alpha:1];
        self.tripDurationLabel.text = [FirstViewController timeFormatted:[GLManager sharedManager].currentTripDuration];
        self.tripDurationUnitLabel.text = [FirstViewController timeUnits:[GLManager sharedManager].currentTripDuration];
        double distance = [self metersToDisplayUnits:[GLManager sharedManager].currentTripDistance];
        NSString *format;
        if(distance >= 1000) {
            format = @"%0.0f";
        } else if(distance >= 100) {
            format = @"%0.1f";
        } else {
            format = @"%0.2f";
        }
        self.tripDistanceLabel.text = [NSString stringWithFormat:format, distance];
    } else {
        [self.tripStartStopButton setTitle:@"Start" forState:UIControlStateNormal];
        self.tripStartStopButton.backgroundColor = [UIColor colorWithRed:106.f/255.f green:212.f/255.f blue:150.f/255.f alpha:1];
        self.tripDistanceLabel.text = @" ";
        self.tripDurationLabel.text = @" ";
    }
}
 
- (IBAction)tripModeWasTapped:(UILongPressGestureRecognizer *)sender {
    if(sender.state == UIGestureRecognizerStateBegan) {
        [self performSegueWithIdentifier:@"tripMode" sender:self];
    }
}

- (IBAction)tripStartStopWasTapped:(id)sender {
    if([GLManager sharedManager].tripInProgress) {
        [[GLManager sharedManager] endTrip];
        
        // If tracking was off when the trip started, turn it off now
        if([[NSUserDefaults standardUserDefaults] boolForKey:GLTripTrackingEnabledDefaultsName] == NO) {
            [[GLManager sharedManager] stopAllUpdates];
        }
    } else {
        // Keep track of whether tracking was on or off when this trip started
        [[NSUserDefaults standardUserDefaults] setBool:[GLManager sharedManager].trackingEnabled forKey:GLTripTrackingEnabledDefaultsName];

        [[GLManager sharedManager] startAllUpdates];
        [[GLManager sharedManager] startTrip];
    }
    [self updateTripState];
}

#pragma mark -

+ (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    if(hours == 0) {
        return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    } else {
        return [NSString stringWithFormat:@"%d:%02d", hours, minutes];
    }
}

+ (NSString *)timeUnits:(int)totalSeconds {
    int hours = totalSeconds / 3600;
    if(hours == 0) {
        return @"minutes";
    } else {
        return @"hours";
    }
}

#pragma mark - Pop Up Window
- (void)showAnimate
{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MapViewController" bundle:nil];
//    UIViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"MapView"];
//    [(UINavigationController*)_mapController presentViewController:ivc animated:NO completion:nil];
//    NSLog(@"It's hitting log");
    
    //_mapController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapView"];
    [self presentViewController:_mapController animated:YES completion:nil];
    
}

- (void)removeAnimate
{
    [UIView animateWithDuration:.25 animations:^{
        
    } completion:^(BOOL finished) {
        if (finished) {
        }
    }];
}

- (IBAction)showPopup:(id)sender
{
    [self showAnimate];
}

- (IBAction)closePopup:(id)sender
{
    [self removeAnimate];
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    [aView addSubview:self.view];
    if (animated) {
        [self showAnimate];
    }
}

@end
