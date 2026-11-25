//
//  AXConstants.h
//  aXTimes
//
//  Created by fuesec on 5/24/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

#define RGB(r, g, b, a) [UIColor colorWithRed : r / 255.0 green : g / 255.0 blue : b / 255.0 alpha : a]

// General
#define COPYRIGHT_YEAR                   @"2018"
#define APPLICATIONNAME                  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]
#define APPLICATIONVERSION               [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define APPLICATIONBUILDVERSION          [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define APPLICATIONFULLVERSION           [NSString stringWithFormat:@"%@_%@", APPLICATIONVERSION, APPLICATIONBUILDVERSION]
#define CHEERS                           [NSString stringWithFormat:@"%@ (%@),\nCopyright © %@ aXimilate Technology GmbH", APPLICATIONNAME, APPLICATIONFULLVERSION, COPYRIGHT_YEAR]
#define BOTTOM_INFOSCREEN                [NSString stringWithFormat:@"Copyright © %@ aXimilate. All rights reserved.", COPYRIGHT_YEAR]
#define SUPPORTSITE                      @"http://support.axtimes.com/"
#define SUPPORTMAIL                      @"support@aximilate.com"

// app id as seen in itunes connect. used for UAAppReviewManager //FIXME
#define APPID                            @ "1341474620"

#define NULLSTRING                       @ "-"

#define ANIMATIONDURATION                0.25
#define COUNTERFONTSIZE                  77.0
#define TICKERFONTNAME                   @ "HelveticaNeue-UltraLight"
#define GLOBALFONTNAME2                  @ "HelveticaNeue-Light"

// emacs color scheme
#define GLOBALBACKGROUNDCOLOR            [UIColor whiteColor]
//#define GLOBALBACKGROUNDCOLOR2           RGB(230, 230, 230, 1.0)    // mercury
#define GLOBALBACKGROUNDCOLOR2           RGB(240, 240, 240, 1.0)
#define GLOBALFONTCOLOR                  RGB(0, 0, 0, 1.0) // schwarz
#define GLOBALDETAILFONTCOLOR            RGB(0, 0, 0, 1.0) // schwarz
#define GREENCOLOR                       RGB(108, 162, 21, 1) // #6ca215
#define NOTWORKINGCELLCOLOR              RGB(143, 188, 143, 0.3) // dark sea green mit alpha
#define REDCOLOR                         RGB(205, 38, 38, 1) // firebrick3
#define LIGHTGREYCOLOR                   RGB(240, 240, 240, 1) // light grey
#define TIMEZONECOLOR                    RGB(162, 21, 108, 1) // #a2156c
#define NOTHIGHLIGHTED                   RGB(0, 0, 0, 0.1)

// crayons ColorPicker
#define C_CANTALOUPE                     RGB(255, 204, 102, 1.0)
#define C_CLOVER                         RGB(0, 128, 0, 1.0)
#define C_SALMON                         RGB(255, 102, 102, 1.0)
#define C_FERN                           RGB(64, 128, 0, 1.0)
#define C_SKY                            RGB(102, 204, 255, 1.0)
#define C_MOCHA                          RGB(128, 84, 0, 1.0)
#define C_MAROON                         RGB(128, 0, 64, 1.0)


#define C_SYSTEM_GREEN                   [UIColor greenColor]
#define C_SYSTEM_RED                     [UIColor redColor]

// von Max
#define SELECTIONCOLOR                   RGB(53, 155, 165, 1) // Signature Color
#define C_SICKNESS                       RGB(165, 63, 22, 1.0)
#define C_HOLIDAY                        RGB(115, 191, 113, 1.0)
#define C_VACATION                       RGB(165, 145, 53, 1.0)
#define C_DAYOFF                         RGB(51, 111, 51, 1.0)
#define C_TODAY                          RGB(37, 30, 49, 1.0)
#define C_NEXTMONTH                      RGB(238, 238, 238, 1.0)
#define C_WEEKEND                        RGB(158, 158, 158, 1.0)
#define C_SELECTEDDATE                   RGB(66, 66, 66, 1.0)

//// #359BA5
//static let signature = UIColor(red: 53/255, green: 155/255, blue: 165/255, alpha: 1)
//static let systemRed = UIColor.red
//static let systemGreen = UIColor.green
//
//// #A53F16
//static let sickness = UIColor(red: 165/255, green: 63/255, blue: 22/255, alpha: 1.0)
//// #73BF71
//static let holiday = UIColor(red: 115/255, green: 191/255, blue: 113/255, alpha: 1.0)
//// #A59135
//static let vacation = UIColor(red: 165/255, green: 145/255, blue: 53/255, alpha: 1.0)
//// #336F33
//static let dayOff = UIColor(red: 51/255, green: 111/255, blue: 51/255, alpha: 1.0)
//// #251E31
//static let today = UIColor(red: 37/255, green: 30/255, blue: 49/255, alpha: 1.0)
//static let nextMonth = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
//static let weekend = UIColor(red: 158/255, green: 158/255, blue: 158/255, alpha: 1.0)
//static let selectedDate = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1.0)

#define NOTIFICATION_JUMP_TO_DATE               @ "jumpToDate"
#define NOTIFICATION_OUTSIDECHANGE_OCCURED      @ "outsidechangeOccured"
#define NOTIFICATION_IMPORTDATAFINISHED         @"notification_importDataFinished"

#define DATEFORMATTERDAYDETAILHEADER     @ "EEE, d. MMMM yyyy"
#define DATEFORMATTERDAYMAIN             @ "EEE, d. MMM yyyy"

#define DATEFORMATTERHOURMINUTE          @ "HH:mm"

#define CALENDARUNITCOMPONENTS           (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitTimeZone | NSCalendarUnitWeekday)

#define CALENDARUNITCOMPONENTS_FULL      (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitNanosecond | NSCalendarUnitTimeZone)


#define AXParagraphSeparatorCharacter    0x2029
#define AXLineSeparatorCharacter         0x2028
#define AXNewlineCharacter               0x000a


// Settings
#define SETTINGS_SHOWWELCOMEPOPUP        @ "settings_showwelcomepopup"
#define SETTINGS_SHOWTUTORIAL            @ "settings_showtutorial"

#define TABBAR_FIRST_START               @ "TABBAR_FIRST_START"

#define BASIC_GLOBAL_PROJECT_NAME        @ "__basic__global__axtimes__project__"


// TODO release preparation
// always add languages
// check debug mode UAAppReviewManager
// app group: group.com.aximilate.axtimes

// wird auf dem projekt level gesetzt
#define WORKTIMEUNITS                    @[@1, @5, @10, @15, @30]

// http://stackoverflow.com/questions/7848766/how-can-we-programmatically-detect-which-ios-version-is-device-running-on

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

