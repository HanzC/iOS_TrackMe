//
//  GLManager.h
//  TrackMe
//
//  Created by Hanz Meyer on 4/9/21.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
@import UserNotifications;

static NSString *const GLNewDataNotification = @"GLNewDataNotification";
static NSString *const GLSendingStartedNotification = @"GLSendingStartedNotification";
static NSString *const GLSendingFinishedNotification = @"GLSendingFinishedNotification";

static NSString *const GLAPIEndpointDefaultsName = @"GLAPIEndpointDefaults";
static NSString *const GLAPIAccessTokenDefaultsName = @"GLAPIAccessTokenDefaults";
static NSString *const GLDeviceIdDefaultsName = @"GLDeviceIdDefaults";
static NSString *const GLLastSentDateDefaultsName = @"GLLastSentDateDefaults";
static NSString *const GLTrackingStateDefaultsName = @"GLTrackingStateDefaults";
static NSString *const GLSendIntervalDefaultsName = @"GLSendIntervalDefaults";
static NSString *const GLPausesAutomaticallyDefaultsName = @"GLPausesAutomaticallyDefaults";
static NSString *const GLResumesAutomaticallyDefaultsName = @"GLResumesAutomaticallyDefaults";
static NSString *const GLEnableGogoTrackerDefaultsName = @"GLEnableGogoTrackerDefaultsName";
static NSString *const GLIncludeTrackingStatsDefaultsName = @"GLIncludeTrackingStatsDefaultsName";
static NSString *const GLActivityTypeDefaultsName = @"GLActivityTypeDefaults";
static NSString *const GLDesiredAccuracyDefaultsName = @"GLDesiredAccuracyDefaults";
static NSString *const GLDefersLocationUpdatesDefaultsName = @"GLDefersLocationUpdatesDefaults";
static NSString *const GLSignificantLocationModeDefaultsName = @"GLSignificantLocationModeDefaults";
static NSString *const GLPointsPerBatchDefaultsName = @"GLPointsPerBatchDefaults";
static NSString *const GLNotificationPermissionRequestedDefaultsName = @"GLNotificationPermissionRequestedDefaults";
static NSString *const GLNotificationsEnabledDefaultsName = @"GLNotificationsEnabledDefaults";

static NSString *const GLTripTrackingEnabledDefaultsName = @"GLTripTrackingEnabledDefaults";
static NSString *const GLTripModeDefaultsName = @"GLTripModeDefaults";
static NSString *const GLTripStartTimeDefaultsName = @"GLTripStartTimeDefaults";
static NSString *const GLTripStartLocationDefaultsName = @"GLTripStartLocationDefaults";
static NSString *const GLTripModeWalk = @"walk";
static NSString *const GLTripModeRun = @"run";
static NSString *const GLTripModeBicycle = @"bicycle";
static NSString *const GLTripModeCar = @"car";
static NSString *const GLTripModeCar2go = @"car2go";
static NSString *const GLTripModeTaxi = @"taxi";
static NSString *const GLTripModeBus = @"bus";
static NSString *const GLTripModeTrain = @"train";
static NSString *const GLTripModePlane = @"plane";
static NSString *const GLTripModeTram = @"tram";
static NSString *const GLTripModeMetro = @"metro";
static NSString *const GLTripModeBoat = @"boat";

typedef enum {
    kGLSignificantLocationDisabled,
    kGLSignificantLocationEnabled,
    kGLSignificantLocationExclusive
} GLSignificantLocationMode;

@interface GLManager : NSObject <CLLocationManagerDelegate, UNUserNotificationCenterDelegate>

@end
