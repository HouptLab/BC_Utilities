/*
 *  BCSerial.h
 *  Blink
 *
 *  Created by Tom Houpt on Wed Oct 06 2004.
 *  Copyright (c) 2004 Behavioral Cybernetics. All rights reserved.
 *
 */


//NOTE do we really need to include ALL of these header files?

#include <Carbon/Carbon.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <paths.h>
#include <termios.h>
#include <sysexits.h>
#include <sys/param.h>
#include <sys/select.h>
#include <sys/time.h>
#include <time.h>

#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>

// NOTE: for Blink and Bartender applications:
// I assume the Keyspan devices will be "/dev/cu.USA28X*P1.1" or "/dev/cu.USA28X*P2.2"
// could just OpenSerialPort with that name, 
// or, more safely, use FindAndOpenSerialPort to make sure that given device is actually present

// code based on:
// http://www.easysw.com/~mike/serial/serial.html
// Serial Programming Guide for POSIX Operating Systems
// 5th Edition, 6th Revision 
// Copyright 1994-2005 by Michael R. Sweet

#define kKeyspanSerialDevice1 "/dev/cu.USA28X*P1.1" 
#define kKeyspanSerialDevice2 "/dev/cu.USA28X*P2.2"

#define READ_BUFFER_SIZE ((ssize_t)1024) // size of read buffer in bytes

enum kParity {	kNoParity = 0, kOddParity, kEvenParity};

#define kSerialErrReturn -1 
// error if serial port cannot be opened

#define kNoSerialPort -1

/** opens the serial port at deviceFilePath and returns a file descriptor
 
    baudrate is always set to 9600....
 
    note that deviceFilePath is not the same as targetFilePath --
    usually targetFilePath has to be matched with internal
    (e.g. match the wildcard * characters in targetFilePath name)
 
    @param const char *deviceFilePath
    @param int numDataBits = 5 - 8
    @param int parity = kNoParity, kOddParity, or KEvenParity
    @param int numStopBits = 1 or 2
 
 
 @return int fileDescriptor for open serial port, or  kNoSerialPort (-1) on error or no serial port found

*/
int OpenSerialPort(const char *deviceFilePath, int numDataBits, int parity, int numStopBits) ;

/** tries to match the given target file path with a serial port
 if successful, it opens the serial port and returns a file descriptor
 
  baudrate is always set to 9600....
 
    @param const char *deviceFilePath; for example, "/dev/cu.USA28X*P1.1" for the first port of a keyspan serial interface
    @param int numDataBits = 5 - 8
    @param int parity = kNoParity, kOddParity, or KEvenParity
    @param int numStopBits = 1 or 2
    @params serialPortFound returns FALSE if no serial ports are located
    @params deviceFound returns FALSE if requested device at targetFilePath is not found

    @returns kMyErrReturn (-1) if no file descriptor found

 
*/

int FindAndOpenSerialPort(const char *targetFilePath, Boolean *serialPortFound, Boolean *deviceFound, int numDataBits, int parity, int numStopBits);

/** close the serial port identified by the given file descriptor
 
    @param int fileDescriptor pointing to the serial port (okay to be kNoSerialPort (-1) if trying to close a failed port)
*/
void CloseSerialPort(int fileDescriptor);

/** send a command, and ignore any response from the serial device

     @param int fileDescriptor pointing to the serial port
     @param char *outString null-terminated C string with command or query to be sent out the serial port
 
*/

Boolean SendCommandToSerialPort (int fileDescriptor, const char *outString);

/**  send a query to the serial port at fileDescriptor, wait for a CR or LF terminated response
     
    only processes a response the same length or less than the  length of expectedResponseString
    
     @param int fileDescriptor pointing to the serial port
     @param char *outString null-terminated C string with command or query to be sent out the serial port
     @param char *expectedResponseString should be NULL or be /0 terminated
     @param int fileDescriptor pointer to the serial port
     @param char *outString null-terminated C string with command to be sent
     
     @return BOOLEAN TRUE if the  response received from the serial port matches the expectedResponseString
         return FALSE if the response doesn't match the expected string
 

*/
Boolean SendCommandToSerialPortWithExpectedResponse (int fileDescriptor, const char *outString, const char *expectedResponseString);

/**
 sends the given outString command to the serial port at fileDescriptor
 
 @param int fileDescriptor pointing to the serial port
 @param char *outString null-terminated C string with command or query to be sent out the serial port
 @param  char *responseString a buffer with maximum size maxResponseLength (allocated by caller); upon return,  responseString will contain the NULL-terminated response received by the serial port
 @param size_t maxResponseLength the size of the responseString buffer
 
 @return BOOLEAN  TRUE if the serial port receives characters that are put into the responseString buffer

*/
Boolean SendQueryToSerialPort (int fileDescriptor, const char *outString, char *responseString,size_t maxResponseLength);








