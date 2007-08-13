//
//  main.m
//  seed
//
//  Created by Martin Ott on 3/12/07.
//  Copyright 2007 TheCodingMonkeys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sasl.h"

#import "SDAppController.h"
#import "SDDocumentManager.h"
#import "TCMMillionMonkeys.h"
#import "HandshakeProfile.h"
#import "SessionProfile.h"
#import "FileManagementProfile.h"
#import "BacktracingException.h"


static int sasl_getopt_callback(void *context, const char *plugin_name, const char *option, const char **result, unsigned *len);
static int sasl_log_callback(void *context, int level, const char *message);
static int sasl_verifyfile_callback(void *context, const char *file, sasl_verify_type_t type);

static sasl_callback_t callbacks[] = {
    {SASL_CB_GETOPT, &sasl_getopt_callback, NULL},
    //{SASL_CB_VERIFYFILE, &sasl_verifyfile_callback, NULL},
    {SASL_CB_LOG, &sasl_log_callback, NULL},
    {SASL_CB_LIST_END, NULL, NULL}
};

#pragma mark -

static int sasl_getopt_callback(void *context, const char *plugin_name, const char *option, const char **result, unsigned *len)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
    DEBUGLOG(@"SASLLogDomain", SimpleLogLevel, @"plugin_name: %s, option: %s", plugin_name, option);

    if (!strcmp(option, "reauth_timeout")) {
        DEBUGLOG(@"SASLLogDomain", AllLogLevel, @"setting reauth_timeout");
        *result = "0";
        if (len) *len = 1;
    }

    [pool release];
    return SASL_OK;
}

static int sasl_log_callback(void *context, int level, const char *message)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
    DEBUGLOG(@"SASLLogDomain", SimpleLogLevel, @"level: %d, message: %s", level, message);

    [pool release];
    return SASL_OK;
}

static int sasl_verifyfile_callback(void *context, const char *file, sasl_verify_type_t type)
{
    DEBUGLOG(@"SASLLogDomain", SimpleLogLevel, @"verifyfile: %s", file);

    return SASL_OK;
}

#pragma mark -

// 
// Signal handler
//
void catch_signal(int sig_num) {
    write(fd, &sig_num, sizeof(sig_num));
}

#pragma mark -

int main(int argc, const char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BOOL isRunning = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:6942] forKey:DefaultPortNumber];
    [defaults setBool:NO forKey:@"EnableTLS"];
    [defaults setBool:YES forKey:@"LogConnections"];
    [defaults setBool:NO forKey:@"EnableBEEPLogging"];
    [defaults setInteger:0 forKey:@"MillionMonkeysLogDomain"];
    [defaults setInteger:0 forKey:@"BEEPLogDomain"];
    [defaults setInteger:0 forKey:@"SASLLogDomain"];
    [defaults setObject:BASE_LOCATION forKey:@"base_location"];
    
    NSString *shortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSLog(@"seed %@ (%@)", shortVersion, bundleVersion);
    
    endRunLoop = NO;


    const char *implementation;
    const char *version_string;
    int version_major;
    int version_minor;
    int version_step;
    int version_patch;
    sasl_version_info(&implementation, &version_string, &version_major, &version_minor, &version_step, &version_patch);
    NSLog(@"%s %s (%d.%d.%d.%d)", implementation, version_string, version_major, version_minor, version_step, version_patch);

    int result;
    result = sasl_server_init(callbacks, "seed");
    if (result != SASL_OK) {
        DEBUGLOG(@"SASLLogDomain", SimpleLogLevel, @"sasl_server_init failed");
    }
    
    NSMutableString *mechanisms = [[NSMutableString alloc] init];
    [mechanisms appendString:@"SASL mechanisms:\n"];
    const char **mech_list = sasl_global_listmech();
    const char *mech;
    int i = 0;
    while ((mech = mech_list[i++])) {
        [mechanisms appendFormat:@"\t%s\n", mech];
    }
    DEBUGLOG(@"SASLLogDomain", DetailedLogLevel, mechanisms);

    
    [BacktracingException install];
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];

    SDAppController *appController = [[SDAppController alloc] init];

    
    
    // Setup user with ID and name, w/o you can't establish connections
    TCMMMUser *me = [[TCMMMUser alloc] init];
    [me setUserID:[NSString UUIDString]];
    NSString *myName = [defaults stringForKey:@"user_name"];
    if (!myName) myName = @"King Kong";
    [me setName:myName];
    
    NSString *imagePath = [defaults stringForKey:@"image"];
    if (imagePath) {
        NSData *imageData = [NSData dataWithContentsOfFile:[imagePath stringByExpandingTildeInPath]];
        if (imageData) {
            [[me properties] setObject:imageData forKey:@"ImageAsPNG"];
        }
    }
    
    [me setUserHue:[NSNumber numberWithInt:5]];
    [[me properties] setObject:@"monkeys@codingmonkeys.de" forKey:@"Email"];
    [[me properties] setObject:@"" forKey:@"AIM"];
    [[TCMMMUserManager sharedInstance] setMe:me];
    [me release];
    
    
    [TCMBEEPChannel setClass:[HandshakeProfile class] forProfileURI:@"http://www.codingmonkeys.de/BEEP/SubEthaEditHandshake"];    
    [TCMBEEPChannel setClass:[TCMMMStatusProfile class] forProfileURI:@"http://www.codingmonkeys.de/BEEP/TCMMMStatus"];
    [TCMBEEPChannel setClass:[SessionProfile class] forProfileURI:@"http://www.codingmonkeys.de/BEEP/SubEthaEditSession"];
    [TCMBEEPChannel setClass:[FileManagementProfile class] forProfileURI:@"http://www.codingmonkeys.de/BEEP/SeedFileManagement"];

    TCMMMBEEPSessionManager *sm = [TCMMMBEEPSessionManager sharedInstance];
    [sm registerProfileURI:@"http://www.codingmonkeys.de/BEEP/SubEthaEditHandshake" forGreetingInMode:kTCMMMBEEPSessionManagerDefaultMode];
    [sm registerProfileURI:@"http://www.codingmonkeys.de/BEEP/TCMMMStatus" forGreetingInMode:kTCMMMBEEPSessionManagerDefaultMode];
    [sm registerProfileURI:@"http://www.codingmonkeys.de/BEEP/SubEthaEditSession" forGreetingInMode:kTCMMMBEEPSessionManagerDefaultMode];
    [sm registerProfileURI:@"http://www.codingmonkeys.de/BEEP/SeedFileManagement" forGreetingInMode:kTCMMMBEEPSessionManagerDefaultMode];

    [sm listen];
    [[TCMMMPresenceManager sharedInstance] setVisible:YES];
    // [[TCMMMPresenceManager sharedInstance] startRendezvousBrowsing];
    

    // set the TERM signal handler to 'catch_term' 
    signal(SIGTERM, catch_signal);
    signal(SIGINT, catch_signal);
    signal(SIGINFO, catch_signal);
    
    
    NSString *configFile = [defaults stringForKey:@"config"];
    if (!configFile) {
        configFile = [[defaults stringForKey:@"base_location"] stringByAppendingPathComponent:@"config.plist"];
    }
    [appController readConfig:configFile];
    
    do {
        NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
        isRunning = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                             beforeDate:[NSDate distantFuture]];
        [subPool release];
    } while (isRunning && !endRunLoop);


    [appController release];
    
    sasl_done();
    
    NSLog(@"Bye bye!");

    [pool release];
    return 0;
}