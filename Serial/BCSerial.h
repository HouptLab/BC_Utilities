/*
 *  BCSerial.h
 *  Blink
 *
 *  Created by Tom Houpt on Wed Oct 06 2004.
 *  Copyright (c) 2004 Behavioral Cybernetics. All rights reserved.
 *
 */


//NOTE do we really need to include ALL of these header files?
// committed 2014-10-22 -- but doesn't work?


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

// see: http://www.easysw.com/~mike/serial/serial.html
// Serial Programming Guide for POSIX Operating Systems
// 5th Edition, 6th Revision
// Copyright 1994-2005 by Michael R. Sweet

#define kKeyspanSerialDevice1 "/dev/cu.USA28X*P1.1"
#define kKeyspanSerialDevice2 "/dev/cu.USA28X*P2.2"

#define READ_BUFFER_SIZE ((ssize_t)1024) // size of read buffer in bytes

enum kParity {	kNoParity = 0, kOddParity, kEvenParity};

#define kSerialErrReturn -1
// error if serial port cannot be opened

int OpenSerialPort(const char *deviceFilePath, int numDataBits, int parity, int numStopBits) ;
// opens the serial port at deviceFilePath and returns a file descriptor
// note that deviceFilePath is not the same as targetFilePath --
// usually targetFilePath has to be matched with internal representation of deviceFilePath
// (e.g. match the wildcard * characters in targetFilePath name)
// returns -1 on error
// numDataBits = 5 -8
// parity = kNoParity, kOddParity, or KEvenParity
// numStopBits = 1 or 2
// baudrate is always set to 9600....


int FindAndOpenSerialPort(char *targetFilePath, Boolean *serialPortFound, Boolean *deviceFound, int numDataBits, int parity, int numStopBits);
// tries to match the given target file path with a serial port
// if successful, it opens the serial port and returns a file descriptor
// otherwise returns -1 kMyErrReturn if no file descriptor found
// returns serialPortFound = FALSE if no serial ports are located
// returns deviceFound = FALSE is requested device at targetFilePath is not found
// numDataBits = 5 -8
// parity = kNoParity, kOddParity, or KEvenParity
// numStopBits = 1 or 2
// baudrate is always set to 9600....


void CloseSerialPort(int fileDescriptor);


//Boolean SendCommandToSerialPortWithResponse (int fileDescriptor, const char *outString, const char *response,size_t maxResponseLength);
// sends the given outString command to the serial port at fileDescriptor
// returns TRUE if the serial port returns a string that matches the expected response

Boolean SendCommandToSerialPort (int fileDescriptor, const char *outString);
// send a command, and ignore any response from the serial device

Boolean SendCommandToSerialPortWithExpectedResponse (int fileDescriptor, const char *outString, const char *expectedResponseString, const char *actualResponseString, size_t maxResponseLength);

Boolean SendQueryToSerialPort (int fileDescriptor, const char *outString, const char *responseString,size_t maxResponseLength);
// sends the given outString command to the serial port at fileDescriptor
// returns TRUE if the serial port returns characters that are put into the responseString buffer
// responseString has maximum size maxResponseLength
// responseString is NULL terminated

Boolean TestSendQueryToSerialPort (int fileDescriptor, const char *outString, const char *responseString,size_t maxResponseLength);

/*
 For sartorius:
 c_cflag:
 The c_cflag member contains two options that should always be enabled, CLOCAL and CREAD
 B9600 = 9600 baud
 CS7 = 7 data bits
 PARENB	Enable parity bit
 PARODD	Use odd parity instead of even
 1 stop bit (~STOPB)
 */







