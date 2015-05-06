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

// EPCEncoder
#import "EPCEncoder.h"

@interface ViewController ()
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

@end
