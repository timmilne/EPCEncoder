//
//  UgiInventory.h
//  UGrokItApi
//
//  Copyright (c) 2012 U Grok It. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UgiEpc.h"
#import "UgiTag.h"
#import "UgiRfidConfiguration.h"
#import "UgiInventoryDelegate.h"

/**
 Data for each tag read, sent if detailedPerReadData is YES in the RFID configuration
 */
@interface UgiDetailedPerReadData : NSObject

@property (readonly, nonatomic) NSDate *timestamp;    //!< When the find happened
@property (readonly, nonatomic) int frequency;        //!< Frequency the find happened at
@property (readonly, nonatomic) double rssiI;         //!< RSSI, I channel
@property (readonly, nonatomic) double rssiQ;         //!< RSSI, Q channel
@property (readonly, nonatomic) int readData1;        //!< first word read (if applicable)
@property (readonly, nonatomic) int readData2;        //!< second word read (if applicable)

@end

/**
 An inventory session
 */
@interface UgiInventory : NSObject

///////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
///////////////////////////////////////////////////////////////////////////////////////

//! Configuration this inventory was run with
@property (readonly, nonatomic) UgiRfidConfiguration *configuration;

//! When the inventory started
@property (readonly, nonatomic) NSDate *startTime;

//! Is inventory temporarily stopped
@property (readonly, nonatomic) BOOL isPaused;

//! Is the Grokker actively scanning
@property (readonly, nonatomic) BOOL isScanning;

//! The number of inventory rounds that the Grokker has run in this inventory
@property (readonly, nonatomic) int numInventoryRounds;

//! After inventory has completed, this is the return value
@property (nonatomic) UgiInventoryCompletedReturnValues completedReturnValue;

///////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Start / stop
///////////////////////////////////////////////////////////////////////////////////////

/**
 Prototype for completion method for stopnventory
 
 @param tag     The tag accessed (possibly not valid if the access failed)
 @param result  Result of the operation
 */
typedef void (^StopInventoryCompletion)(void);

/**
 Stop running inventory
 @param completion  Block to run when inventory is completely finished
 */
- (void) stopInventoryWithCompletion:(StopInventoryCompletion)completion;

/**
 Stop running inventory
 */
- (void) stopInventory;

/**
 Stop running inventory temporarily (such as while a dialog box is displayed)
 */
- (void) pauseInventory;

/**
 Restart inventory after a temporarily stop
 */
- (void) resumeInventory;

/**
 Restart inventory after a temporarily stop, with a changed configuration
 @param configuration  New RFID confifuration
 */
- (void) resumeInventoryWithConfiguration:(UgiRfidConfiguration *)configuration;

///////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Tag access
///////////////////////////////////////////////////////////////////////////////////////

/**
Get the UgiTag for an EPC.

@param epc  EPC to find
@return     UgiTag object if the tag has been found, nil if the tag has not been found.
*/
- (UgiTag *) getTagByEpc:(UgiEpc *)epc;

///@}

///@name Inventory Properties (while running inventory)

//! Array of tags that have been found, elements are UgiTag*
@property (readonly, nonatomic) NSArray *tags;

///////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Modifying tags
///////////////////////////////////////////////////////////////////////////////////////

/**
 Values passed to TagAccessCompletion
 */
typedef enum {
  UGI_TAG_ACCESS_OK=0,                    //!< Access was successful
  UGI_TAG_ACCESS_WRONG_PASSWORD=1,        //!< Incorrect password passed
  UGI_TAG_ACCESS_PASSWORD_REQUIRED=2,     //!< No password passed, but a password is required
  UGI_TAG_ACCESS_MEMORY_OVERRUN=3,        //!< Read/write to a memory locaion that does not exist on tht tag
  UGI_TAG_ACCESS_TAG_NOT_FOUND=4,         //!< Tag not found
  UGI_TAG_ACCESS_GENERAL_ERROR=5          //!< General error
} UgiTagAccessReturnValues;

/**
 Prototype for completion methods for tag access methods
 
 @param tag     The tag accessed (possibly not valid if the access failed)
 @param result  Result of the operation
 */
typedef void (^TagAccessCompletion)(UgiTag *tag, UgiTagAccessReturnValues result);

/////////////////

#define UGI_NO_PASSWORD 0

/**
 Program a tag (change its EPC)
 
 This must be called while inventory is running. This method call returns immediately,
 the completion is called when the operation is finished.
 
 @param oldEpc      EPC of tag to change
 @param newEpc      EPC to write to the tag
 @param password    Password to use (UGI_NO_PASSWORD for not password protected)
 @param completion  Completion code after tag is programmed
 */
- (void) programTag:(UgiEpc *)oldEpc
              toEpc:(UgiEpc *)newEpc
       withPassword:(int)password
      whenCompleted:(TagAccessCompletion)completion;

/**
 Write a tag's memory
 
 This must be called while inventory is running. This method call returns immediately,
 the completion is called when the operation is finished
 
 @param epc           EPC of tag to write to
 @param memoryBank    Memory bank to write to
 @param offset        Byte offset to write at (must be a multiple of 2)
 @param data          Data to write
 @param previousData  Previous value for this data (nil if unknown or not available)
 @param password      Password to use (UGI_NO_PASSWORD for not password protected)
 @param completion    Completion code after tag is written
 */
- (void) writeTag:(UgiEpc *)epc
       memoryBank:(UgiMemoryBank)memoryBank
           offset:(int)offset
             data:(NSData *)data
     previousData:(NSData *)previousData
     withPassword:(int)password
    whenCompleted:(TagAccessCompletion)completion;

/**
 Set a tag's access password
 
 This must be called while inventory is running. This method call returns immediately,
 the completion is called when the operation is finished
 
 @param epc               EPC of tag to set the password for
 @param currentPassword   Current password (UGI_NO_PASSWORD if not password protected)
 @param newPassword       Password to set (UGI_NO_PASSWORD for not password protected)
 @param completion        Completion code after password is set
 */
- (void) setTagAccessPassword:(UgiEpc *)epc
              currentPassword:(int)currentPassword
                  newPassword:(int)newPassword
                whenCompleted:(TagAccessCompletion)completion;

/**
 Set a tag's kill password
 
 This must be called while inventory is running. This method call returns immediately,
 the completion is called when the operation is finished
 
 @param epc               EPC of tag to set the password for
 @param currentPassword   Current password (UGI_NO_PASSWORD if not password protected)
 @param killPassword      Password to set (UGI_NO_PASSWORD for not password protected)
 @param completion        Completion code after password is set
 */
- (void) setTagKillPassword:(UgiEpc *)epc
            currentPassword:(int)currentPassword
               killPassword:(int)killPassword
              whenCompleted:(TagAccessCompletion)completion;

/**
 * Definitions for value passed to lockUnlockTag choosing what banks to change the locked status for and what to change them to
 */
typedef enum {
  //
  // Masks -- these define which bits to change
  //
  UGI_ACCESS_KILL_PASSWORD_MASK_BIT_OFFSET = 18,    //!< Offset for mask bits for kill password
  UGI_ACCESS_ACCESS_PASSWORD_MASK_BIT_OFFSET = 16,  //!< Offset for mask bits for access password
  UGI_ACCESS_EPC_MASK_BIT_OFFSET = 14,              //!< Offset for mask bits for EPC memory bank
  UGI_ACCESS_TID_MASK_BIT_OFFSET = 12,              //!< Offset for mask bits for TID memory bank
  UGI_ACCESS_USER_MASK_BIT_OFFSET = 10,             //!< Offset for mask bits for USER memory bank
  //
  // Actions -- these define what to change to
  //
  UGI_ACCESS_KILL_PASSWORD_ACTION_BIT_OFFSET = 8,     //!< Offset for action bits for kill password
  UGI_ACCESS_ACCESS_PASSWORD_ACTION_BIT_OFFSET = 6,   //!< Offset for action bits for access password
  UGI_ACCESS_EPC_ACTION_BIT_OFFSET = 4,               //!< Offset for action bits for EPC memory bank
  UGI_ACCESS_TID_ACTION_BIT_OFFSET = 2,               //!< Offset for action bits for TID memory bank
  UGI_ACCESS_USER_ACTION_BIT_OFFSET = 0,              //!< Offset for action bits for USER memory bank
  //
  // Access values
  //
  UGI_ACCESS_MASK_CHANGE_NONE = 0,                    //!< Mask: don't change
  UGI_ACCESS_MASK_CHANGE_PERMALOCK = 1,               //!< Mask: change permlock bit
  UGI_ACCESS_MASK_CHANGE_WRITABLE = 2,                //!< Mask: change writable bit
  UGI_ACCESS_MASK_CHANGE_WRITABLE_AND_PERMALOCK = 3,  //!< Mask: change permlock and writable bits
  //
  // Action values
  //
  UGI_ACCESS_ACTION_WRITABLE = 0,                     //!< Action: writable
  UGI_ACCESS_ACTION_PERMANENTLY_WRITABLE = 1,         //!< Action: permanently writable
  UGI_ACCESS_ACTION_WRITE_RESTRICTED = 2,             //!< Action: write restricted (password required)
  UGI_ACCESS_ACTION_PERMANENTLY_NOT_WRITABLE = 3      //!< Action: permanently not writable
} UgiLockUnlockMaskAndAction;


/**
 Lock/unlock a tag
 
 This must be called while inventory is running. This method call returns immediately,
 the completion is called when the operation is finished
 
 @param epc           EPC of tag to lock/unlock
 @param maskAndAction Description for which protection bits to change and what to change them to (UgiLockUnlockMaskAndAction)
 @param password      Password to use (UGI_NO_PASSWORD for not password protected)
 @param completion    Completion code after tag is locked/unlocked
 */
- (void) lockUnlockTag:(UgiEpc *)epc
         maskAndAction:(UgiLockUnlockMaskAndAction)maskAndAction
          withPassword:(int)password
         whenCompleted:(TagAccessCompletion)completion;

/**
 Prototype for completion methods for tag access methods
 
 @param tag     The tag accessed
 @param result  Result of the operation
 */
typedef void (^TagReadCompletion)(UgiTag *tag, NSData *data, UgiTagAccessReturnValues result);

/**
 Read a tag's memory
 
 This must be called while inventory is running. This method call returns immediately,
 the completion is called when the operation is finished
 
 @param epc           EPC of tag to read
 @param memoryBank    Memory bank to read
 @param offset        Byte offset to read at (must be a multiple of 2)
 @param minNumBytes   Minimum number of bytes to read (must be a multiple of 2)
 @param maxNumBytes   Maximum number of bytes to read (must be a multiple of 2)
 @param completion    Completion code after tag is read
 */
- (void) readTag:(UgiEpc *)epc
      memoryBank:(UgiMemoryBank)memoryBank
          offset:(int)offset
     minNumBytes:(int)minNumBytes
     maxNumBytes:(int)maxNumBytes
   whenCompleted:(TagReadCompletion)completion;

/**
 Prototype for completion method for custom command
 
 @param tag         The tag accessed
 @param headerBit   YES if the header bit was set in the response (usually used to indicate an error)
 @param response    Tag's response to the custom command
 @param result      Result of the operation
 */
typedef void (^TagCustomCommandCompletion)(UgiTag *tag, BOOL headerBit, NSData *response,
                                           UgiTagAccessReturnValues result);

/**
 Do a custom command to a tag
 
 This must be called while inventory is running. This method call returns immediately,
 the completion is called when the operation is finished
 
 @param epc           EPC of tag to read
 @param command       Command bytes to send
 @param commandBits   Number of command bits to send
 @param responseBitLengthNoHeaderBit   Number of response bits to expect, if header bit
                                       is not set in the response
 @param responseBitLengthWithHeaderBit   Number of response bits to expect, if header bit is
                                         set in the response (if 0 then do not expect a header bit at all)
 @param receiveTimeoutUsec   Response timeout in uSec (some tags require more than the standard
                             for custom commands)
 @param completion    Completion code after the custom command is executed
 */
- (void) customCommandToTag:(UgiEpc *)epc
                    command:(NSData *)command
                commandBits:(int)commandBits
responseBitLengthNoHeaderBit:(int)responseBitLengthNoHeaderBit
responseBitLengthWithHeaderBit:(int)responseBitLengthWithHeaderBit
         receiveTimeoutUsec:(int)receiveTimeoutUsec
              whenCompleted:(TagCustomCommandCompletion)completion;

/**
 Prototype for completion methods for tag access methods
 
 @param success      YES if successful
 */
typedef void (^ChangePowerCompletion)(BOOL success);

/**
 Change power
 
 This must be called while inventory is running. This method call returns immediately,
 the completion is called when the operation is finished
 
 @param initialPowerLevel   Initial power level
 @param minPowerLevel       Minimum power level
 @param maxPowerLevel       Maximum power level
 @param completion    Completion code after the power change is executed
 */
- (void) changePowerInitial:(double)initialPowerLevel
                        min:(double)minPowerLevel
                        max:(double)maxPowerLevel
              whenCompleted:(ChangePowerCompletion)completion;

///@}

@end
