/* Copyright 2013 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#import <SenTestingKit/SenTestingKit.h>
#import "PacoNotificationManager.h"
#import "UILocalNotification+Paco.h"
#import "PacoDateUtility.h"

@interface PacoNotificationManager ()

@property (atomic, retain, readwrite) NSMutableDictionary* notificationDict;
- (void)purgeCachedNotifications;
- (void)processCachedNotificationsWithBlock:(void(^)(NSMutableDictionary*, NSArray*, NSArray*))block;
- (void)addNotifications:(NSArray*)allNotifications;

@end

@interface PacoNotificationManagerTests : SenTestCase
@property(nonatomic, strong) PacoNotificationManager* testManager;
@property(nonatomic, assign) NSTimeInterval sleepTime;

@property(nonatomic, strong) UILocalNotification* activeNotification;
@property(nonatomic, strong) UILocalNotification* scheduled11;
@property(nonatomic, strong) UILocalNotification* scheduled12;
@property(nonatomic, strong) UILocalNotification* scheduled21;
@property(nonatomic, strong) UILocalNotification* scheduled22;
@property(nonatomic, strong) NSArray* expectExpiredNotifications;

@end

@implementation PacoNotificationManagerTests

//remove notification plist from the document directory
- (void)cleanDocumentDirectory {
  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString* documentsDirectory = [paths objectAtIndex:0];
  NSFileManager* fileMgr = [NSFileManager defaultManager];
  NSArray* filePathArray = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
  for (NSString* filename in filePathArray)  {
    NSString* fullPath = [documentsDirectory stringByAppendingPathComponent:filename] ;
    [fileMgr removeItemAtPath:fullPath error:NULL];
  }
}

- (void)setUp {
  [super setUp];
  // Put setup code here; it will be run once, before the first test case.
  [[UIApplication sharedApplication] cancelAllLocalNotifications];
  [self cleanDocumentDirectory];
  self.testManager = [PacoNotificationManager managerWithDelegate:nil firstLaunchFlag:YES];
}

- (void)tearDown {
  // Put teardown code here; it will be run once, after the last test case.
  self.testManager = nil;
  [[UIApplication sharedApplication] cancelAllLocalNotifications];
  [self cleanDocumentDirectory];
  [super tearDown];
}

- (void)testSaveAndLoadNotifications {
  NSMutableDictionary* notificationDict = [NSMutableDictionary dictionaryWithCapacity:2];

  //set up the first experiment
  NSString* experimentId1 = @"1";
  NSString* experimentTitle1 = @"title";
  NSTimeInterval timeoutInterval1 = 3;//3 seconds
  NSDate* baseDate = [NSDate dateWithTimeIntervalSinceNow:2]; //2 seconds later
  NSDate* date1 = [NSDate dateWithTimeInterval:0 sinceDate:baseDate]; //timeout
  NSDate* date2 = [NSDate dateWithTimeInterval:2 sinceDate:baseDate]; //obsolete
  NSDate* date3 = [NSDate dateWithTimeInterval:3 sinceDate:baseDate]; //active
  NSDate* date4 = [NSDate dateWithTimeInterval:7 sinceDate:baseDate]; //scheduled 1
  NSDate* date5 = [NSDate dateWithTimeInterval:10 sinceDate:baseDate]; //scheduled 2
  
  UILocalNotification* noti1 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId1
                                        experimentTitle:experimentTitle1
                                               fireDate:date1
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval1 sinceDate:date1]];
  UILocalNotification* noti2 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId1
                                        experimentTitle:experimentTitle1
                                               fireDate:date2
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval1 sinceDate:date2]];
  UILocalNotification* noti3 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId1
                                        experimentTitle:experimentTitle1
                                               fireDate:date3
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval1 sinceDate:date3]];
  UILocalNotification* noti4 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId1
                                        experimentTitle:experimentTitle1
                                               fireDate:date4
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval1 sinceDate:date4]];
  UILocalNotification* noti5 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId1
                                        experimentTitle:experimentTitle1
                                               fireDate:date5
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval1 sinceDate:date5]];
  NSMutableArray* allNotificationsForExperiment1 = [NSMutableArray arrayWithObjects:noti1, noti2, noti3, noti4, noti5, nil];
  [notificationDict setObject:allNotificationsForExperiment1 forKey:experimentId1];
  
  //set up the second experiment
  NSString* experimentId2 = @"2";
  NSString* experimentTitle2 = @"title2";
  NSTimeInterval timeoutInterval2 = 1;//1 seconds
  date1 = [NSDate dateWithTimeInterval:1 sinceDate:baseDate]; //timeout
  date2 = [NSDate dateWithTimeInterval:3 sinceDate:baseDate]; //timeout
  date3 = [NSDate dateWithTimeInterval:8 sinceDate:baseDate]; //scheduled
  date4 = [NSDate dateWithTimeInterval:9 sinceDate:baseDate]; //scheduled
  UILocalNotification* noti21 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId2
                                        experimentTitle:experimentTitle2
                                               fireDate:date1
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval2 sinceDate:date1]];
  UILocalNotification* noti22 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId2
                                        experimentTitle:experimentTitle2
                                               fireDate:date2
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval2 sinceDate:date2]];
  UILocalNotification* noti23 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId2
                                        experimentTitle:experimentTitle2
                                               fireDate:date3
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval2 sinceDate:date3]];
  UILocalNotification* noti24 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId2
                                        experimentTitle:experimentTitle2
                                               fireDate:date4
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval2 sinceDate:date4]];
  NSMutableArray* allNotifications2 = [NSMutableArray arrayWithObjects:noti21, noti22, noti23, noti24,nil];
  [notificationDict setObject:allNotifications2 forKey:experimentId2];
  
  self.testManager.notificationDict = notificationDict;
  BOOL success = [self.testManager saveNotificationsToCache];
  STAssertTrue(success, @"should be saved successfully");
  
  self.testManager.notificationDict = nil;
  success = [self.testManager loadNotificationsFromCache];
  STAssertTrue(success, @"should be loaded successfully");
  STAssertEquals([[self.testManager notificationDict] count], (NSUInteger)2, @"should have 2 key-value pairs");
  STAssertTrue([[self.testManager notificationDict] isKindOfClass:[NSMutableDictionary class]], @"should be a mutable dictionary");
  NSMutableArray* notificationsForExperiment1 = [[self.testManager notificationDict] objectForKey:experimentId1];
  STAssertTrue([notificationsForExperiment1 isKindOfClass:[NSMutableArray class]], @"should be a mutable array");
  STAssertEqualObjects(notificationsForExperiment1,allNotificationsForExperiment1, @"should be loaded correctly");
  NSMutableArray* notificationsForExperiment2 = [[self.testManager notificationDict] objectForKey:experimentId2];
  STAssertTrue([notificationsForExperiment2 isKindOfClass:[NSMutableArray class]], @"should be a mutable array");
  STAssertEqualObjects(notificationsForExperiment2, allNotifications2,@"should be loaded correctly");
}


- (void)testProcessCachedNotificationsWithBlock {
  NSMutableDictionary* notificationDict = [NSMutableDictionary dictionaryWithCapacity:2];
  
  //set up the first experiment
  NSString* experimentId = @"1";
  NSString* experimentTitle = @"title";
  NSTimeInterval timeoutInterval = 3;//3 seconds
  
  //schedule all notifications at once, sleep for 6 seconds and wake up
  self.sleepTime = 7;
  NSDate* baseDate = [NSDate dateWithTimeIntervalSinceNow:2]; //2 seconds later
  NSDate* date1 = [NSDate dateWithTimeInterval:0 sinceDate:baseDate]; //timeout
  NSDate* date2 = [NSDate dateWithTimeInterval:2 sinceDate:baseDate]; //obsolete
  NSDate* date3 = [NSDate dateWithTimeInterval:3 sinceDate:baseDate]; //active
  
  NSDate* date4 = [NSDate dateWithTimeInterval:7 sinceDate:baseDate]; //scheduled 1
  NSDate* date5 = [NSDate dateWithTimeInterval:10 sinceDate:baseDate]; //scheduled 2
  
  UILocalNotification* timeoutNoti =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date1
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date1]];
  
  UILocalNotification* obsoleteNoti =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date2
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date2]];
  
  
  UILocalNotification* activeNoti =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date3
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date3]];
  self.activeNotification = activeNoti;
  
  UILocalNotification* scheduledNoti11 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date4
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date4]];
  self.scheduled11 = scheduledNoti11;
  
  UILocalNotification* scheduledNoti12 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date5
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date5]];
  self.scheduled12 = scheduledNoti12;
  NSArray* allNotifications = @[timeoutNoti, obsoleteNoti, activeNoti, scheduledNoti11, scheduledNoti12];
  [notificationDict setObject:allNotifications forKey:experimentId];
  
  //set up the second experiment
  experimentId = @"2";
  experimentTitle = @"title2";
  timeoutInterval = 1;//1 seconds
  date1 = [NSDate dateWithTimeInterval:1 sinceDate:baseDate]; //timeout
  date2 = [NSDate dateWithTimeInterval:3 sinceDate:baseDate]; //timeout
  date3 = [NSDate dateWithTimeInterval:8 sinceDate:baseDate]; //scheduled
  date4 = [NSDate dateWithTimeInterval:9 sinceDate:baseDate]; //scheduled
  
  UILocalNotification* timeoutNoti1 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date1
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date1]];
  
  UILocalNotification* timeoutNoti2 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date2
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date2]];
  
  
  UILocalNotification* scheduledNoti21 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date3
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date3]];
  self.scheduled21 = scheduledNoti21;
  
  UILocalNotification* scheduledNoti22 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date4
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date4]];
  self.scheduled22 = scheduledNoti22;
  NSMutableArray* notificationsToSchedule = [NSMutableArray arrayWithArray:allNotifications];
  allNotifications = @[timeoutNoti1, timeoutNoti2,scheduledNoti21, scheduledNoti22];
  [notificationsToSchedule addObjectsFromArray:allNotifications];
  [notificationDict setObject:allNotifications forKey:experimentId];
  
  self.expectExpiredNotifications = @[timeoutNoti, obsoleteNoti, timeoutNoti1, timeoutNoti2];
  
  STAssertEquals((int)[notificationsToSchedule count], 9, @"should have 9 notifications in total");
  [UIApplication sharedApplication].scheduledLocalNotifications = notificationsToSchedule;
  STAssertEquals((int)[[UIApplication sharedApplication].scheduledLocalNotifications count], 9,
                 @"should have 9 notifications scheduled");
  
  self.testManager.notificationDict = notificationDict;

  sleep(self.sleepTime);
  
  [self.testManager processCachedNotificationsWithBlock:^(NSMutableDictionary* newNotificationDict,
                                                          NSArray* expiredNotifications,
                                                          NSArray* notFiredNotifications) {
    NSDictionary* expectNewDict = @{@"1":@[self.activeNotification]};
    STAssertEqualObjects(newNotificationDict, expectNewDict, @"should have one active notification");

    STAssertEqualObjects(expiredNotifications, self.expectExpiredNotifications,
                         @"should have 4 expired notifications");
    
    NSArray* scheduled = [UIApplication sharedApplication].scheduledLocalNotifications;
    NSArray* expectScheduled = @[self.scheduled11, self.scheduled21, self.scheduled22, self.scheduled12];
    NSArray* expectNotFired = @[self.scheduled11, self.scheduled12, self.scheduled21, self.scheduled22];
    STAssertEqualObjects(notFiredNotifications, expectNotFired, @"should have 4 notification scheduled");
    STAssertEqualObjects(scheduled, expectScheduled, @"should have 4 notification scheduled");
  }];
}


- (void)testProcessCachedNotificationsWithoutExpiredNotifications {
  NSMutableDictionary* notificationDict = [NSMutableDictionary dictionaryWithCapacity:2];
  
  //set up the first experiment
  NSString* experimentId = @"1";
  NSString* experimentTitle = @"title";
  NSTimeInterval timeoutInterval = 3;//3 seconds
  
  //schedule all notifications at once, sleep for 6 seconds and wake up
  self.sleepTime = 7;
  NSDate* baseDate = [NSDate dateWithTimeIntervalSinceNow:2]; //2 seconds later
  NSDate* date3 = [NSDate dateWithTimeInterval:3 sinceDate:baseDate]; //active
  
  NSDate* date4 = [NSDate dateWithTimeInterval:7 sinceDate:baseDate]; //scheduled 1
  NSDate* date5 = [NSDate dateWithTimeInterval:10 sinceDate:baseDate]; //scheduled 2
  
  UILocalNotification* activeNoti =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date3
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date3]];
  self.activeNotification = activeNoti;
  
  UILocalNotification* scheduledNoti11 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date4
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date4]];
  self.scheduled11 = scheduledNoti11;
  
  UILocalNotification* scheduledNoti12 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date5
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date5]];
  self.scheduled12 = scheduledNoti12;
  NSArray* allNotifications = @[activeNoti, scheduledNoti11, scheduledNoti12];
  [notificationDict setObject:allNotifications forKey:experimentId];
  
  //set up the second experiment
  experimentId = @"2";
  experimentTitle = @"title2";
  timeoutInterval = 1;//1 seconds
  date3 = [NSDate dateWithTimeInterval:8 sinceDate:baseDate]; //scheduled
  date4 = [NSDate dateWithTimeInterval:9 sinceDate:baseDate]; //scheduled
  
  UILocalNotification* scheduledNoti21 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date3
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date3]];
  self.scheduled21 = scheduledNoti21;
  
  UILocalNotification* scheduledNoti22 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date4
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date4]];
  self.scheduled22 = scheduledNoti22;
  NSMutableArray* notificationsToSchedule = [NSMutableArray arrayWithArray:allNotifications];
  allNotifications = @[scheduledNoti21, scheduledNoti22];
  [notificationsToSchedule addObjectsFromArray:allNotifications];
  [notificationDict setObject:allNotifications forKey:experimentId];
  
  STAssertEquals((int)[notificationsToSchedule count], 5, @"should have 5 notifications in total");
  [UIApplication sharedApplication].scheduledLocalNotifications = notificationsToSchedule;
  STAssertEquals((int)[[UIApplication sharedApplication].scheduledLocalNotifications count], 5,
                 @"should have 5 notifications scheduled");
  
  self.testManager.notificationDict = notificationDict;
  
  sleep(self.sleepTime);
  
  [self.testManager processCachedNotificationsWithBlock:^(NSMutableDictionary* newNotificationDict,
                                                          NSArray* expiredNotifications,
                                                          NSArray* notFiredNotifications) {
    NSDictionary* expectNewDict = @{@"1":@[self.activeNotification]};
    STAssertEqualObjects(newNotificationDict, expectNewDict, @"should have one active notification");
    STAssertNil(expiredNotifications, @"should be nil");
    
    NSArray* scheduled = [UIApplication sharedApplication].scheduledLocalNotifications;
    NSArray* expectScheduled = @[self.scheduled11, self.scheduled21, self.scheduled22, self.scheduled12];
    NSArray* expectNotFired = @[self.scheduled11, self.scheduled12, self.scheduled21, self.scheduled22];
    STAssertEqualObjects(notFiredNotifications, expectNotFired, @"should have 4 notification scheduled");
    STAssertEqualObjects(scheduled, expectScheduled, @"should have 4 notification scheduled");
  }];
}

- (void)testProcessCachedNotificationsWithoutScheduledNotifications {
  NSMutableDictionary* notificationDict = [NSMutableDictionary dictionaryWithCapacity:2];
  
  //set up the first experiment
  NSString* experimentId = @"1";
  NSString* experimentTitle = @"title";
  NSTimeInterval timeoutInterval = 3;//3 seconds
  
  //schedule all notifications at once, sleep for 6 seconds and wake up
  self.sleepTime = 7;
  NSDate* baseDate = [NSDate dateWithTimeIntervalSinceNow:2]; //2 seconds later
  NSDate* date1 = [NSDate dateWithTimeInterval:0 sinceDate:baseDate]; //timeout
  NSDate* date2 = [NSDate dateWithTimeInterval:2 sinceDate:baseDate]; //obsolete
  NSDate* date3 = [NSDate dateWithTimeInterval:3 sinceDate:baseDate]; //active
  
  UILocalNotification* timeoutNoti =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date1
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date1]];
  
  UILocalNotification* obsoleteNoti =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date2
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date2]];
  
  
  UILocalNotification* activeNoti11 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date3
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date3]];
  NSArray* allNotifications = @[timeoutNoti, obsoleteNoti, activeNoti11];
  [notificationDict setObject:allNotifications forKey:experimentId];
  
  //set up the second experiment
  experimentId = @"2";
  experimentTitle = @"title2";
  timeoutInterval = 1;//1 seconds
  date1 = [NSDate dateWithTimeInterval:1 sinceDate:baseDate]; //timeout
  date2 = [NSDate dateWithTimeInterval:3 sinceDate:baseDate]; //timeout
  date3 = [NSDate dateWithTimeInterval:4.5 sinceDate:baseDate]; //active
  
  UILocalNotification* timeoutNoti1 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date1
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date1]];
  
  UILocalNotification* timeoutNoti2 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date2
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date2]];

  UILocalNotification* activeNoti21 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date3
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date3]];

  
  NSMutableArray* notificationsToSchedule = [NSMutableArray arrayWithArray:allNotifications];
  allNotifications = @[timeoutNoti1, timeoutNoti2, activeNoti21];
  [notificationsToSchedule addObjectsFromArray:allNotifications];
  [notificationDict setObject:allNotifications forKey:experimentId];
  
  self.expectExpiredNotifications = @[timeoutNoti, obsoleteNoti, timeoutNoti1, timeoutNoti2];
  
  STAssertEquals((int)[notificationsToSchedule count], 6, @"should have 6 notifications in total");
  [UIApplication sharedApplication].scheduledLocalNotifications = notificationsToSchedule;
  STAssertEquals((int)[[UIApplication sharedApplication].scheduledLocalNotifications count], 6,
                 @"should have 6 notifications scheduled");
  
  self.testManager.notificationDict = notificationDict;
  
  sleep(self.sleepTime);
  
  [self.testManager processCachedNotificationsWithBlock:^(NSMutableDictionary* newNotificationDict,
                                                          NSArray* expiredNotifications,
                                                          NSArray* notFiredNotifications) {
    NSDictionary* expectNewDict = @{@"1":@[activeNoti11], @"2":@[activeNoti21]};
    STAssertEqualObjects(newNotificationDict, expectNewDict, @"should have two active notifications");
    STAssertEqualObjects(expiredNotifications, self.expectExpiredNotifications,
                         @"should have 4 expired notifications");
    
    STAssertNil(notFiredNotifications, @"should be nil");
    NSArray* scheduled = [UIApplication sharedApplication].scheduledLocalNotifications;
    STAssertEqualObjects(scheduled, @[], @"should be empty");
  }];
}

- (void)testProcessCachedNotificationsWithoutActiveNotifications {
  NSMutableDictionary* notificationDict = [NSMutableDictionary dictionaryWithCapacity:2];
  
  //set up the first experiment
  NSString* experimentId = @"1";
  NSString* experimentTitle = @"title";
  NSTimeInterval timeoutInterval = 3;//3 seconds
  
  //schedule all notifications at once, sleep for 6 seconds and wake up
  self.sleepTime = 7;
  NSDate* baseDate = [NSDate dateWithTimeIntervalSinceNow:2]; //2 seconds later
  NSDate* date1 = [NSDate dateWithTimeInterval:0 sinceDate:baseDate]; //timeout
  NSDate* date2 = [NSDate dateWithTimeInterval:2 sinceDate:baseDate]; //obsolete
  
  NSDate* date4 = [NSDate dateWithTimeInterval:7 sinceDate:baseDate]; //scheduled 1
  NSDate* date5 = [NSDate dateWithTimeInterval:10 sinceDate:baseDate]; //scheduled 2
  
  UILocalNotification* timeoutNoti =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date1
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date1]];
  
  UILocalNotification* obsoleteNoti =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date2
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date2]];
  
  
  UILocalNotification* scheduledNoti11 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date4
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date4]];
  self.scheduled11 = scheduledNoti11;
  
  UILocalNotification* scheduledNoti12 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date5
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date5]];
  self.scheduled12 = scheduledNoti12;
  NSArray* allNotifications = @[timeoutNoti, obsoleteNoti, scheduledNoti11, scheduledNoti12];
  [notificationDict setObject:allNotifications forKey:experimentId];
  
  //set up the second experiment
  experimentId = @"2";
  experimentTitle = @"title2";
  timeoutInterval = 1;//1 seconds
  date1 = [NSDate dateWithTimeInterval:1 sinceDate:baseDate]; //timeout
  date2 = [NSDate dateWithTimeInterval:3 sinceDate:baseDate]; //timeout
  NSDate* date3 = [NSDate dateWithTimeInterval:8 sinceDate:baseDate]; //scheduled
  date4 = [NSDate dateWithTimeInterval:9 sinceDate:baseDate]; //scheduled
  
  UILocalNotification* timeoutNoti1 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date1
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date1]];
  
  UILocalNotification* timeoutNoti2 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date2
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date2]];
  
  
  UILocalNotification* scheduledNoti21 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date3
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date3]];
  self.scheduled21 = scheduledNoti21;
  
  UILocalNotification* scheduledNoti22 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId
                                        experimentTitle:experimentTitle
                                               fireDate:date4
                                            timeOutDate:[NSDate dateWithTimeInterval:timeoutInterval sinceDate:date4]];
  self.scheduled22 = scheduledNoti22;
  NSMutableArray* notificationsToSchedule = [NSMutableArray arrayWithArray:allNotifications];
  allNotifications = @[timeoutNoti1, timeoutNoti2,scheduledNoti21, scheduledNoti22];
  [notificationsToSchedule addObjectsFromArray:allNotifications];
  [notificationDict setObject:allNotifications forKey:experimentId];
  
  self.expectExpiredNotifications = @[timeoutNoti, obsoleteNoti, timeoutNoti1, timeoutNoti2];
  
  STAssertEquals((int)[notificationsToSchedule count], 8, @"should have 8 notifications in total");
  [UIApplication sharedApplication].scheduledLocalNotifications = notificationsToSchedule;
  STAssertEquals((int)[[UIApplication sharedApplication].scheduledLocalNotifications count], 8,
                 @"should have 8 notifications scheduled");
  
  self.testManager.notificationDict = notificationDict;
  
  sleep(self.sleepTime);
  
  [self.testManager processCachedNotificationsWithBlock:^(NSMutableDictionary* newNotificationDict,
                                                          NSArray* expiredNotifications,
                                                          NSArray* notFiredNotifications) {
    STAssertEquals((int)[newNotificationDict count], 0, @"should be empty");
    
    STAssertEqualObjects(expiredNotifications, [NSArray arrayWithArray:self.expectExpiredNotifications],
                         @"should have 4 expired notifications");
    
    NSArray* scheduled = [UIApplication sharedApplication].scheduledLocalNotifications;
    NSArray* expectScheduled = @[self.scheduled11, self.scheduled21, self.scheduled22, self.scheduled12];
    NSArray* expectNotFired = @[self.scheduled11, self.scheduled12, self.scheduled21, self.scheduled22];
    STAssertEqualObjects(notFiredNotifications, expectNotFired, @"should have 4 notification scheduled");
    STAssertEqualObjects(scheduled, expectScheduled, @"should have 4 notification scheduled");
  }];
}


- (void)testAddNotifications {
  NSDate* now = [NSDate date];
  NSDate* date1 = [NSDate dateWithTimeInterval:10 sinceDate:now];
  NSDate* date2 = [NSDate dateWithTimeInterval:20 sinceDate:now];
  NSDate* date3 = [NSDate dateWithTimeInterval:30 sinceDate:now];
  NSDate* date4 = [NSDate dateWithTimeInterval:40 sinceDate:now];
  
  NSTimeInterval timeoutInterval = 479*60;
  NSDate* timeout1 = [NSDate dateWithTimeInterval:timeoutInterval sinceDate:date1];
  NSDate* timeout2 = [NSDate dateWithTimeInterval:timeoutInterval sinceDate:date2];
  NSDate* timeout3 = [NSDate dateWithTimeInterval:timeoutInterval sinceDate:date3];
  NSDate* timeout4 = [NSDate dateWithTimeInterval:timeoutInterval sinceDate:date4];
  
  NSString* experimentId1 = @"1";
  NSString* experimentId2 = @"2";
  NSString* title1 = @"title1";
  NSString* title2 = @"title2";
  
  //id:1, fireDate:date4
  //id:2, fireDate:date3
  //id:1, fireDate:date1
  //id:2, fireDate:date2
  NSMutableArray* allNotifications = [NSMutableArray arrayWithCapacity:4];
  
  //id:1, fireDate:date4
  UILocalNotification* notification1 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId1
                                        experimentTitle:title1
                                               fireDate:date4
                                            timeOutDate:timeout4];
  [allNotifications addObject:notification1];
  
  //id:2, fireDate:date3
  UILocalNotification* notification2 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId2
                                        experimentTitle:title2
                                               fireDate:date3
                                            timeOutDate:timeout3];
  [allNotifications addObject:notification2];
  
  //id:1, fireDate:date1
  UILocalNotification* notification3 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId1
                                        experimentTitle:title1
                                               fireDate:date1
                                            timeOutDate:timeout1];
  [allNotifications addObject:notification3];
  
  //id:2, fireDate:date2
  UILocalNotification* notification4 =
  [UILocalNotification pacoNotificationWithExperimentId:experimentId2
                                        experimentTitle:title2
                                               fireDate:date2
                                            timeOutDate:timeout2];
  [allNotifications addObject:notification4];
  
  //original notifications
  UILocalNotification* firstNoti = [[UILocalNotification alloc] init];
  firstNoti.fireDate = [NSDate dateWithTimeIntervalSinceNow:-10];
  UILocalNotification* secondNoti = [[UILocalNotification alloc] init];
  secondNoti.fireDate = [NSDate dateWithTimeIntervalSinceNow:-20];
  NSMutableDictionary* originalDict = [NSMutableDictionary dictionary];
  NSString* experimentId3 = @"3";
  [originalDict setObject:[NSMutableArray arrayWithObject:firstNoti] forKey:experimentId1];
  [originalDict setObject:[NSMutableArray arrayWithObject:secondNoti] forKey:experimentId3];
  self.testManager.notificationDict = originalDict;
  
  //allNotifications:
  //id:1, fireDate:date4
  //id:2, fireDate:date3
  //id:1, fireDate:date1
  //id:2, fireDate:date2
  [self.testManager addNotifications:allNotifications];

  NSMutableDictionary* expect = [NSMutableDictionary dictionaryWithCapacity:2];
  NSMutableArray* notifications1 = [NSMutableArray arrayWithObjects:firstNoti, notification3, notification1, nil];
  NSMutableArray* notifications2 = [NSMutableArray arrayWithObjects:notification4, notification2, nil];
  NSMutableArray* notifications3 = [NSMutableArray arrayWithObjects:secondNoti, nil];
  [expect setObject:notifications1 forKey:experimentId1];
  [expect setObject:notifications2 forKey:experimentId2];
  [expect setObject:notifications3 forKey:experimentId3];
  
  NSMutableDictionary* result = (NSMutableDictionary*)[self.testManager valueForKey:@"notificationDict"];
  STAssertEqualObjects(result, expect,
                       @"add notifications should work correctly");
}



@end
