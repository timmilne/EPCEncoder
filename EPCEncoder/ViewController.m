//
//  ViewController.m
//  EPCEncoder
//
//  Created by Tim.Milne on 4/27/15.
//  Copyright (c) 2015 Tim.Milne. All rights reserved.
//
//  A simple ViewController to grab inputs: Depmartment, Class, Item and Serialn Number
//  Then leverages the EPCEncoder object to encode and display them in GS1 SGTIN, GIAI,
//  and GID in both URI and Hex formats.
//

#import "ViewController.h"
#import "Ugi.h"             // uGrokit tools

// EPCEncoder
#import "EPCEncoder.h"

@interface ViewController ()<UgiInventoryDelegate>
{
    UgiRfidConfiguration *_config;
    NSMutableString *_oldEPC;
    NSMutableString *_newEPC;
}

@property (weak, nonatomic) IBOutlet UITextField *Dpt_fld;
@property (weak, nonatomic) IBOutlet UITextField *Cls_fld;
@property (weak, nonatomic) IBOutlet UITextField *Itm_fld;
@property (weak, nonatomic) IBOutlet UITextField *Ser_fld;
@property (weak, nonatomic) IBOutlet UITextField *SGTIN_URI_fld;
@property (weak, nonatomic) IBOutlet UITextField *SGTIN_Hex_fld;
@property (weak, nonatomic) IBOutlet UITextField *GIAI_URI_fld;
@property (weak, nonatomic) IBOutlet UITextField *GIAI_Hex_fld;
@property (weak, nonatomic) IBOutlet UITextField *GID_URI_fld;
@property (weak, nonatomic) IBOutlet UITextField *GID_Hex_fld;

@end

@implementation ViewController {
    EPCEncoder *_encode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Set the status bar to white (iOS bug)
    // Also had to add the statusBarStyle entry to info.plist
    self.navigationController.navigationBar.BarStyle = UIStatusBarStyleLightContent;

// TPM Not needed
/*
    // Register with the default NotificationCenter
    // TPM there was a typo in the online documentation fixed here
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionStateChanged:)
                                                 name:[Ugi singleton].NOTIFICAION_NAME_CONNECTION_STATE_CHANGED
                                               object:nil];
*/
    
    // Set scanner configuration used in startInventory
//    _config = [UgiRfidConfiguration configWithInventoryType:UGI_INVENTORY_TYPE_LOCATE_DISTANCE];
    _config = [UgiRfidConfiguration configWithInventoryType:UGI_INVENTORY_TYPE_INVENTORY_SHORT_RANGE];
    [_config setVolume:.2];
    
    // Set the variables
    _oldEPC = [[NSMutableString alloc] init];
    _newEPC = [[NSMutableString alloc] init];
    [_oldEPC setString:@""];
    [_newEPC setString:@""];
    
    // Update the encoder
    [self updateAll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Delegate to dimiss keyboard after return
// Set the delegate of any input text field to the ViewController class
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

// All the edit fields point here, after you end the edit and hit return
- (IBAction)update:(id)sender {
    [self updateAll];
}

- (void)updateAll {
    NSString *dpt = [self.Dpt_fld text];
    NSString *cls = [self.Cls_fld text];
    NSString *itm = [self.Itm_fld text];
    NSString *ser = [self.Ser_fld text];
    
    // Make sure the inputs are not too long (especially the Serial Number)
    if ([dpt length] > 3) {
        dpt = [dpt substringToIndex:3];
        [self.Dpt_fld setText:dpt];
    }
    if ([cls length] > 2) {
        cls = [cls substringToIndex:2];
        [self.Cls_fld setText:cls];
    }
    if ([itm length] > 4) {
        itm = [itm substringToIndex:4];
        [self.Itm_fld setText:itm];
    }
    if ([ser length] > 10) {
        // SGTIN serial number max = 11
        // GIAI serial number max = 18
        // GID serial number max = 10
        // Shorten to the least common denominator for now
        ser = [ser substringToIndex:10];
        [self.Ser_fld setText:ser];
    }
    
    // Have we done this before
    if (_encode == nil) _encode = [EPCEncoder alloc];
    
    // Update the EPCEncoder object
    [_encode withDpt:dpt cls:cls itm:itm ser:ser];

    // Set the new encodings in the interface
    [self.SGTIN_URI_fld setText:[_encode sgtin_uri]];
    [self.SGTIN_Hex_fld setText:[_encode sgtin_hex]];
    [self.GIAI_URI_fld setText:[_encode giai_uri]];
    [self.GIAI_Hex_fld setText:[_encode giai_hex]];
    [self.GID_URI_fld setText:[_encode gid_uri]];
    [self.GID_Hex_fld setText:[_encode gid_hex]];
}

- (IBAction)encodeSGTIN:(id)sender {
    [self beginEncode:[_encode sgtin_hex]];
}

- (IBAction)encodeGIAI:(id)sender {
    [self beginEncode:[_encode giai_hex]];
}

- (IBAction)encodeGID:(id)sender {
    [self beginEncode:[_encode gid_hex]];
}

- (void)beginEncode:(NSString *)hex {
    [_newEPC setString:hex];
    
    if ([_oldEPC length] == 0) {
        // No reader, no encoding
        if (![[Ugi singleton] isAnythingPluggedIntoAudioJack]) return;
        if (![[Ugi singleton] inOpenConnection]) return;
    
        // Start scanning for RFID tags - when a tag is found, the inventoryTagFound delegate will be called
        [[Ugi singleton] startInventory:self withConfiguration:_config];
    }
    else {
        [self endEncode:_oldEPC];
    }
}

-(void)endEncode:(NSString *)hex {
    [_oldEPC setString:hex];
    
    if ([_newEPC length] == 0) return;

    // Use the old tag number
    UgiEpc *oldEpc = [UgiEpc epcFromString:_oldEPC];

// TPM only test this when you are ready
/*
    // Encode it with the new number
    UgiEpc *newEpc = [UgiEpc epcFromString:[_encode sgtin_hex]];
    [[Ugi singleton].activeInventory programTag:oldEpc
                                          toEpc:newEpc
                                   withPassword:UGI_NO_PASSWORD
                                  whenCompleted:^(UgiTag *tag, UgiTagAccessReturnValues result) {
                                      if (result == UGI_TAG_ACCESS_OK) {
                                          // tag programmed successfully
                                      } else {
                                          // tag programming was unsuccessful
                                      }
                                  }];
 */
    // Our work is done
    [_oldEPC setString:@""];
}

// Implemented uGrokit delegates

// New tag found
- (void) inventoryTagFound:(UgiTag *)tag
   withDetailedPerReadData:(NSArray *)detailedPerReadData {
    // Tag was found for the first time
    
    // Stop the RFID reader
    [[Ugi singleton].activeInventory stopInventory];
    
    // Begin encoding with old RFID tag
    [self endEncode:[tag.epc toString]];
}

// TPM Not needed
/*
// State changed method
- (void)connectionStateChanged:(NSNotification *) notification {
    // Listen for one of the following:
    //    UGI_CONNECTION_STATE_NOT_CONNECTED,        //!< Nothing connected to audio port
    //    UGI_CONNECTION_STATE_CONNECTING,           //!< Something connected to audio port, trying to connect
    //    UGI_CONNECTION_STATE_INCOMPATIBLE_READER,  //!< Connected to an reader with incompatible firmware
    //    UGI_CONNECTION_STATE_CONNECTED             //!< Connected to reader
    NSNumber *n = notification.object;
    UgiConnectionStates connectionState = n.intValue;
    if (connectionState == UGI_CONNECTION_STATE_CONNECTED) {
        return;
    }
    if (connectionState == UGI_CONNECTION_STATE_CONNECTING) {
        return;
    }
    if (connectionState == UGI_CONNECTION_STATE_INCOMPATIBLE_READER) {
        return;
    }
    if (connectionState == UGI_CONNECTION_STATE_NOT_CONNECTED ) {
        // This gets called after a tag is read and the connection closed
        return;
    }
}
 */

@end
