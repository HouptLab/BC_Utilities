/*
 * 2013-3-4 from BRF iMAC -- use this one, not uniDisk version
 *  BCSerial.c
 *  Blink
 *
 *  Created by Tom Houpt on Wed Oct 06 2004.
 *  Copyright (c) 2004 Behavioral Cybernetics. All rights reserved.
 
 *  Reviewed 2012-8-20 by TAH
 *
 */

//
// this code taken pretty much verbatim from the Apple example code SerialPortSample
// and the Apple document "Device File Access Guide for Serial Devices"
//
// originally used in Blink, responses from the serial port were ignored
// for Bartender, we'll want to get a response back....
//

// Note: The serial ports and the USB Keyspan adapter in particular has problems dealing with sleep mode
// so make sure that Power Manager callbacks close serial port before sleep, and re-open serial port upon wakening.
// this should probably be handled by the object using these serial routines
// http://elecraft.365791.n2.nabble.com/USB-Serial-adapters-and-sleep-mode-on-OS-X-td5501652.html
// power manager:  http://developer.apple.com/mac/library/qa/qa2004/qa1340.html

// Sartorius Balance notes:
// Is this relevant? I don't think so. http://stackoverflow.com/questions/12143603/ewcom-protocol-communication-over-rs232-hardware

// committed 2014-10-22 -- but doesn't work?

#include "BCSerial.h"



static kern_return_t FindRS232Port(io_iterator_t *matchingServices);
static kern_return_t GetSerialPath(io_iterator_t serialPortIterator, char *deviceFilePath, char * targetPath, CFIndex maxPathSize);


// static char *MyLogString(char *str);
short wildstrncmp(char *subject,char *query,size_t q_length);



enum {
    kNumRetries = 3
};

// Hold the original termios attributes so we can reset them
static struct termios gOriginalTTYAttrs;


int FindAndOpenSerialPort(char *targetFilePath, Boolean *serialPortFound, Boolean *deviceFound, int numDataBits, int parity, int numStopBits) {
    
    // tries to match the given target file path with a serial port
    // if successful, it opens the serial port and returns a file descriptor
    // otherwise returns -1 kSerialErrReturn if no file descriptor found
    // returns serialPortFound = FALSE if no serial ports are located
    // returns deviceFound = FALSE is requested device at targetFilePath is not found
    
    int fileDescriptor = kSerialErrReturn;
    kern_return_t result;
    char deviceFilePath[256];
    io_iterator_t serialPortIterator;
    
    (*serialPortFound) = FALSE;
    (*deviceFound) = FALSE;
    
    result = FindRS232Port(&serialPortIterator);
    if (result != KERN_SUCCESS) return(fileDescriptor);
    
    (*serialPortFound) = TRUE;
    result = GetSerialPath(serialPortIterator, deviceFilePath, targetFilePath,256);
    if (result != KERN_SUCCESS) return(fileDescriptor);
    
    (*deviceFound) = TRUE;
    fileDescriptor = OpenSerialPort(deviceFilePath, numDataBits, parity, numStopBits);
    return(fileDescriptor);
    
}

static kern_return_t FindRS232Port(io_iterator_t *matchingServices) {
    
    kern_return_t       kernResult;
    mach_port_t         masterPort;
    CFMutableDictionaryRef  classesToMatch;
    
    kernResult = IOMasterPort(MACH_PORT_NULL, &masterPort);
    
    if (KERN_SUCCESS != kernResult) {
        // printf("IOMasterPort returned %d\n", kernResult);
        goto exit;
    }
    
    // Serial devices are instances of class IOSerialBSDClient.
    
    classesToMatch = IOServiceMatching(kIOSerialBSDServiceValue);
    
    if (classesToMatch == NULL) {
        printf("Error: IOServiceMatching returned a NULL dictionary.\n");
    }
    else {
        
        CFDictionarySetValue(classesToMatch,
                             CFSTR(kIOSerialBSDTypeKey),
                             CFSTR(kIOSerialBSDAllTypes));
        
        //		// type could be one of the following:
        //		CFSTR(kIOSerialBSDModemType) -- 12/8/20 -- only returns BSD path: /dev/cu.Bluetooth-Modem
        //		CFSTR(kIOSerialBSDRS232Type) -- 12/8/20 -- only returns BSD path: /dev/cu.Bluetooth-PDA-Sync
        //		CFSTR(kIOSerialBSDAllTypes) -- returns both!
        
        //		"/dev/cu.USA28Xfd432P1.1"
        //		"/dev/cu.USA28Xfd432P2.2"
        //		"/dev/cu.KeySerial1"
        
        
        
        // Each serial device object has a property with key
        // kIOSerialBSDTypeKey and a value that is one of
        // kIOSerialBSDAllTypes, kIOSerialBSDModemType,
        // or kIOSerialBSDRS232Type. You can experiment with the
        // matching by changing the last parameter in the above call
        // to CFDictionarySetValue.
        
    }
    
    kernResult = IOServiceGetMatchingServices(masterPort, classesToMatch, matchingServices);
    
    if (KERN_SUCCESS != kernResult) {
        printf("Error: IOServiceGetMatchingServices returned %d\n", kernResult);
        goto exit;
    }
    
    
exit:
    
    return kernResult;
    
}

short wildstrncmp(char *subject,char *query,size_t q_length) {
    
    // compare the subject to the query for the first numChars characters
    // query can contain wildchars '*' that match any number of characters (or zero character)
    // if subject doesn't match return failure (1)
    // otherwise return success (0)
    
    size_t s_length,s_index,q_index;
    char compstring[READ_BUFFER_SIZE];
    
    if ( q_length > READ_BUFFER_SIZE) { return (1); } // comparison is too long
    compstring[0]='\0';
    
    s_length = strlen(subject);
    s_index = 0;
    for (q_index=0;q_index<q_length;q_index++) {
        
        if (subject[s_index] == query[q_index]) {
            compstring[s_index] = subject[s_index];compstring[s_index+1] = '\0';
            s_index++;
            if (s_index >= s_length && q_index < q_length-1) return (1); // subject shorter than query
        }
        else if (query[q_index] == '*') { // character doesn't match, but query is a wildcard
            while (subject[s_index] != query[q_index+1] ) {
                // skip characters until we match the charater after the wildcard
                compstring[s_index] = '*';compstring[s_index+1] = '\0';
                s_index++;
                if (s_index == s_length) return(1); // subject short than query (or wildcard area too long)
            }
        }
        else return(1); // character doesn't match query at all
    }
    
    return(0);
    
    
}


static kern_return_t GetSerialPath(io_iterator_t serialPortIterator, char *deviceFilePath, char * targetPath, CFIndex maxPathSize) {
    
    // given an iterator full of serial devices, get the device file path name as a C string
    // (FindRS232Port will have built the iterator full of RS232 ports)
    // stick code in here to find a specific device...
    // I assume the Keyspan devices will be "/dev/cu.USA28X*P1.1" or "/dev/cu.USA28X*P2.2"
    // middle digits are position in usb tree, matched with wildcard
    
    io_object_t     serialService;
    kern_return_t   kernResult = KERN_FAILURE;
    Boolean     portFound = false;
    
    // Initialize the returned path
    *deviceFilePath = '\0';
    
    // Iterate across all ports found. In this example, we exit after
    // finding the first port.
    
    while ((serialService = IOIteratorNext(serialPortIterator)) && !portFound) {
        
        CFTypeRef   deviceFilePathAsCFString;
        
        // Get the callout device's path (/dev/cu.xxxxx).
        // The callout device should almost always be
        // used. You would use the dialin device (/dev/tty.xxxxx) when
        // monitoring a serial port for
        // incoming calls, for example, a fax listener.
        
        
        
        deviceFilePathAsCFString = IORegistryEntryCreateCFProperty(
                                                                   serialService,
                                                                   CFSTR(kIOCalloutDeviceKey),
                                                                   kCFAllocatorDefault,
                                                                   0);
        
        if (deviceFilePathAsCFString) {
            
            Boolean result;
            
            // Convert the path from a CFString to a NULL-terminated C string
            // for use with the POSIX open() call.
            
            result = CFStringGetCString(	deviceFilePathAsCFString,
                                        deviceFilePath,
                                        maxPathSize,
                                        kCFStringEncodingASCII);
            
            CFRelease(deviceFilePathAsCFString);
            
            if (result) {
                // printf("BSD path: %s", deviceFilePath);
                // we have a C string with the device path, is it the one we want?
                
                
                if (wildstrncmp(deviceFilePath,targetPath,strlen(targetPath)) == 0) {
                    portFound = true;
                    kernResult = KERN_SUCCESS;
                    
                }
            }
            
        }
        
        // printf("\n");
        // Release the io_service_t now that we are done with it.
        
        (void) IOObjectRelease(serialService);
        
    }
    
    return kernResult;
    
}

int OpenSerialPort(const char *deviceFilePath, int numDataBits, int parity, int numStopBits) {
    
    int				fileDescriptor = -1;
    int				handshake;
    struct termios  options;
    
    // Open the serial port read/write (O_RDWR), with no controlling terminal (O_NOCTTY),
    // and don't wait for a connection.
    // The O_NONBLOCK flag also causes subsequent I/O on the device to
    // be non-blocking.
    // See open(2) ("man 2 open") for details.
    
    fileDescriptor = open(deviceFilePath, O_RDWR | O_NOCTTY | O_NONBLOCK);
    
    if (fileDescriptor == -1) {
        printf("Error opening serial port %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
        goto error;
    }
    
    // Note that open() follows POSIX semantics: multiple open() calls to
    // the same file will succeed unless the TIOCEXCL ioctl is issued.
    // This will prevent additional opens except by root-owned processes.
    // See tty(4) ("man 4 tty") and ioctl(2) ("man 2 ioctl") for details.
    
    if (ioctl(fileDescriptor, TIOCEXCL) == kSerialErrReturn) {
        printf("Error setting TIOCEXCL on %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
        goto error;
    }
    
    // Now that the device is open, clear the O_NONBLOCK flag so
    // subsequent I/O will block.
    // See fcntl(2) ("man 2 fcntl") for details.
    
    
    if (fcntl(fileDescriptor, F_SETFL, 0) == kSerialErrReturn) {
        printf("Error clearing O_NONBLOCK %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
        goto error;
    }
    
    // Get the current options and save them so we can restore the
    // default settings later.
    
    if (tcgetattr(fileDescriptor, &gOriginalTTYAttrs) == kSerialErrReturn) {
        printf("Error getting tty attributes %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
        goto error;
    }
    
    // The serial port attributes such as timeouts and baud rate are set by
    // modifying the termios structure and then calling tcsetattr to
    // cause the changes to take effect. Note that the
    // changes will not take effect without the tcsetattr() call.
    // See tcsetattr(4) ("man 4 tcsetattr") for details.
    
    options = gOriginalTTYAttrs;
    
    // Print the current input and output baud rates.
    // See tcsetattr(4) ("man 4 tcsetattr") for details.
    
    printf("Current input baud rate is %d\n", (int) cfgetispeed(&options));
    printf("Current output baud rate is %d\n", (int) cfgetospeed(&options));
    
    // Set raw input (non-canonical) mode, with reads blocking until either
    // a single character has been received or a one second timeout expires.
    // See tcsetattr(4) ("man 4 tcsetattr") and termios(4) ("man 4 termios")
    // for details.
    
    cfmakeraw(&options);
    options.c_cc[VMIN] = 1;
    options.c_cc[VTIME] = 10;
    
    // The baud rate, word length, and handshake options can be set as follows:
    cfsetspeed(&options, B9600);   // Set 9600 baud
    
    // see man termios for bit settings of c_cflag
    
    // for Prior stage controller
    // options.c_cflag = 0;
    
    //	options.c_cflag =   CS8 |		// Use 8 bit words, no parity, 1 stop bit, no flow control
    //						CREAD |		// receiver is enabled
    //						CLOCAL;		// connection does not depend on modem status lines
    //
    //				// no parity because PARENB bit not set
    //				// 1 stop bit because CSTOP bit not set (otherwise would be 2 bits)
    //				// no flow control because CCTS_OFLOW and CRTS_IFLOW not set
    
    
    // sartorius: 7 data bits, odd parity, 1 stop bit
    // options.c_cflag = 0;					// maybe should not do this, in case any default options that need to be preserved
    options.c_cflag |=   	CREAD;		// always enabled: receiver is enabled
    options.c_cflag |=   	CLOCAL;		// always enabled: connection does not depend on modem status lines
    
    
    // set the data bits
    options.c_cflag &=   	~CSIZE;		// mask the character size bits
    
    switch (numDataBits) {
            
        case 5:
            options.c_cflag |=   	CS5;		// Use 7 data bits
            break;
            
        case 6:
            options.c_cflag |=   	CS6;		// Use 7 data bits
            break;
            
        case 7:
            options.c_cflag |=   	CS7;		// Use 7 data bits
            break;
            
        case 8:
            options.c_cflag |=   	CS8;		// Use 7 data bits
            break;
            
            
    }
    
    // set the parity
    options.c_cflag &=   	~PARENB;		// disable parity bit
    
    switch (parity) {
            
        case kNoParity:
            break;
            
        case kEvenParity:
            options.c_cflag |=   	PARENB;		// enable parity bit
            break;
            
        case kOddParity:
            options.c_cflag |=   	PARENB;		// enable parity bit
            options.c_cflag |=   	PARODD;     // use odd parity instead of even
            break;
            
    }
    
    // set number of stop bits
    options.c_cflag &=   	~CSTOPB;	// one stop bit
    if (2 == numStopBits) {
        options.c_cflag |=   	CSTOPB;	// 2 stop bits
    }
    
    
    // Print the new input and output baud rates.
    
    // printf("Input baud rate changed to %d\n", (int) cfgetispeed(&options));
    // printf("Output baud rate changed to %d\n", (int) cfgetospeed(&options));
    
    // Cause the new options to take effect immediately.
    
    if (tcsetattr(fileDescriptor, TCSANOW, &options) == kSerialErrReturn) {
        printf("Error setting tty attributes %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
        goto error;
    }
    
    
    // 2012-8-21 do we need to set the modem handshake lines for sartorius?
    
    // To set the modem handshake lines, use the following ioctls.
    // See tty(4) ("man 4 tty") and ioctl(2) ("man 2 ioctl") for details.
    
    if (ioctl(fileDescriptor, TIOCSDTR) == kSerialErrReturn) {
        // Assert Data Terminal Ready (DTR)
        printf("Error asserting DTR %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
    }
    
    if (ioctl(fileDescriptor, TIOCCDTR) == kSerialErrReturn) {
        // Clear Data Terminal Ready (DTR)
        printf("Error clearing DTR %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
    }
    
    handshake = TIOCM_DTR | TIOCM_RTS | TIOCM_CTS | TIOCM_DSR;

    
    // Set the modem lines depending on the bits set in handshake.
    if (ioctl(fileDescriptor, TIOCMSET, &handshake) == kSerialErrReturn) {
        printf("Error setting handshake lines %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
    }
    
    
    // To read the state of the modem lines, use the following ioctl.
    // See tty(4) ("man 4 tty") and ioctl(2) ("man 2 ioctl") for details.
    
    if (ioctl(fileDescriptor, TIOCMGET, &handshake) == kSerialErrReturn) {
        // Store the state of the modem lines in handshake.
        printf("Error getting handshake lines %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
    }
    
    // printf("Handshake lines currently set to %d\n", handshake);
    
    // Success:
    return fileDescriptor;
    
    // Failure:
    
error:
    
    if (fileDescriptor != kSerialErrReturn) {
        close(fileDescriptor);
    }
    return -1;
    
}

void CloseSerialPort(int fileDescriptor) {
    
    // Block until all written output has been sent from the device.
    // Note that this call is simply passed on to the serial device driver.
    // See tcsendbreak(3) ("man 3 tcsendbreak") for details.
    
    if (tcdrain(fileDescriptor) == kSerialErrReturn) {
        printf("Error waiting for drain - %s(%d).\n", strerror(errno), errno);
    }
    
    // It is good practice to reset a serial port back to the state in
    // which you found it. This is why we saved the original termios struct
    // The constant TCSANOW (defined in termios.h) indicates that
    // the change should take effect immediately.
    
    if (tcsetattr(fileDescriptor, TCSANOW, &gOriginalTTYAttrs) ==  kSerialErrReturn) {
        printf("Error resetting tty attributes - %s(%d).\n", strerror(errno), errno);
    }
    
    close(fileDescriptor);
    
}

Boolean SendCommandToSerialPort (int fileDescriptor, const char *outString) {
    
    // send a command to serial port at fileDescriptor, and ignore any response from the serial device
    
    ssize_t numBytesWritten;       // Number of bytes read or written
    size_t numBytesForOutput;	// Number of bytes that should be written
    int     tries;          // Number of tries so far
    
    numBytesForOutput = strlen(outString);
    
    Boolean result = FALSE;
    
    for (tries = 1; tries <= kNumRetries; tries++) {
        
        // Send the output command to the serial port
        numBytesWritten = write(fileDescriptor, outString, numBytesForOutput);
        
        if ( numBytesWritten == kSerialErrReturn ) {
            printf("Error writing to modem - %s(%d).\n", strerror(errno), errno);
            // try again
            continue;
        }
        // else { // printf("Wrote %ld bytes \"%s\" (of %ld bytes) \n", numBytes, MyLogString(outString), numBytesForOutput); }
        
        if ( numBytesWritten >= (ssize_t) numBytesForOutput ) {
            // wrote out all data, can stop trying to write out
            result = TRUE;
            break;
        }
    }
	 	 
    return result;
    
}

Boolean SendCommandToSerialPortWithExpectedResponse (int fileDescriptor, const char *outString, const char *expectedResponseString, const char *actualResponseString, size_t maxResponseLength) {
    
    // send a query to the serial port at fileDescriptor, wait for a CR or LF terminated response
    // return TRUE if the  response received from the serial port matches the expectedResponseString
    // return FALSE if the response doesn't match the expected string
    // only processes a response the same length or less than the  length of expectedResponseString
    // expectedResponseString should be NULL or be /0 terminated
    
    printf("output string = %s ", outString);
    Boolean returnFlag = FALSE;
    
    Boolean noResponseNeeded = FALSE;
    if (expectedResponseString == NULL) { noResponseNeeded = TRUE; }
    // size_t maxResponseLength = strlen(expectedResponseString);
    if (strlen(expectedResponseString) == 0)  { noResponseNeeded = TRUE; }
    if (strlen(expectedResponseString) > READ_BUFFER_SIZE)  { return (FALSE); } // can't get a response bigger than the allocated input buffer

    
    if (noResponseNeeded) {
        // just send the command, ignore any response
        returnFlag = SendCommandToSerialPort (fileDescriptor,outString);
        
    }
    
    else {
        // allocate a response string,
        // then send the command, get a response,
        // compare it to the expectedResponseString
        
        char *responseString = malloc(maxResponseLength * sizeof(char));
        
        if ( SendQueryToSerialPort(fileDescriptor,outString, responseString, maxResponseLength)) {
            
            
            printf("response string = %s \n", responseString);
            
            if (strncmp(responseString, expectedResponseString,maxResponseLength) == 0) {
                
                // response matches expected response
                returnFlag = TRUE;
                
            }
            
        }
        else {
            
            strlcpy(actualResponseString, responseString, maxResponseLength);
            
            printf("no response\n");
            
        }
        free(responseString);
    }
    
    return returnFlag;
    
}



Boolean SendQueryToSerialPort (int fileDescriptor, const char *outString, const char *responseString,size_t maxResponseLength) {
    
    // send a query to the serial port at fileDescriptor, wait for a CR or LF terminated response
    // put the response into responseString buffer (of maximum byte length maxResponseLength)
    
    char    buffer[READ_BUFFER_SIZE];    // Input buffer
    char    *bufPtr;        // Current char in buffer

    size_t  numBytesForOutput;	// Number of bytes that should be written
    ssize_t numBytesWritten;       // Number of bytes read or written in a single read/write call
    ssize_t numBytesRead;
    size_t bytesReadIntoBuffer; // number of bytes accumulated into buffer with multiple read calls
    size_t maxBytesForInput; // macimum number of bytes that can be read into our input buffer
    int     tries;          // Number of tries so far
    
    Boolean result = FALSE;
    
    printf("outstring = %s ", outString);
    
    if (maxResponseLength > READ_BUFFER_SIZE)  { return (FALSE); } // can't get a response bigger than the allocated input buffer
    
    numBytesForOutput = strlen(outString);
    
    // try sending the output string kNumRetries, or until all the bytes have been output
    for (tries = 1; tries <= kNumRetries; tries++) {
        
        // Send the output command to the serial port
        numBytesWritten = write(fileDescriptor, outString,numBytesForOutput);
        
        if ( numBytesWritten == kSerialErrReturn ) {
            printf("Error writing to modem - %s(%d).\n", strerror(errno), errno);
            continue;
        }
        // else { printf("Wrote %ld bytes \"%s\" (of %ld bytes)\n", numBytes, MyLogString(outString),numBytesForOutput ); }
        
        if ( numBytesWritten >= (ssize_t)numBytesForOutput ) {
            
            // succeeding, do don't have to try writing anymore
            
            break;
        }
    }
    
    if (numBytesWritten < (ssize_t)numBytesForOutput) return FALSE; // failed to write out
    
    
    // sometimes looking for a specific response,like "OK" -- but not here.
    // // printf("Looking for \"%s\"\n", MyLogString(responseString));
    
    // But in this case, for the response, we read characters into our buffer until we get a CR or LF.
    
    bufPtr = buffer;
    maxBytesForInput = READ_BUFFER_SIZE -1;
    bytesReadIntoBuffer = 0;
    
    do {
        maxBytesForInput = READ_BUFFER_SIZE - 1 - bytesReadIntoBuffer;
        
        numBytesRead = read(fileDescriptor, bufPtr, maxBytesForInput  );
        
        if (numBytesRead == kSerialErrReturn) {
            printf("Error reading from modem - %s(%d).\n", strerror(errno), errno);
        }
        else if (numBytesRead > 0) {
            bytesReadIntoBuffer += (size_t)numBytesRead;
            bufPtr += numBytesRead;
            if (*(bufPtr - 1) == '\n' || *(bufPtr - 1) == '\r')  {
                break;
            }
        }
        // else { printf("Nothing read.\n"); }
        
    } while (numBytesRead > 0); // repeat read
    
    // NULL terminate the string and see if we got a response longer than 0 bytes.
    *bufPtr = '\0';
    // printf("Read in: \"%s\"\n", MyLogString(buffer));
    
    if (strlen(buffer) > 0) {
        
        strlcpy(responseString,buffer,maxResponseLength);
        
        printf("responseString = %s\n", responseString);
        
        
        result = TRUE;
    }
    else {
        
        
        printf("response failed\n");
    }
    
    
    return result;
}

//Boolean TestSendQueryToSerialPort (int fileDescriptor, const char *outString, const char *responseString,size_t maxResponseLength) {
//    
//    // send a query to the serial port at fileDescriptor, wait for a CR or LF terminated response
//    // put the response into responseString buffer (of maximum byte length maxResponseLength)
//    
//    char    buffer[READ_BUFFER_SIZE];    // Input buffer
//    char    *bufPtr;        // Current char in buffer
//    ssize_t numBytes, numBytesRead;       // Number of bytes read or written in a single read/write call
//    size_t  numBytesForOutput;	// Number of bytes that should be written
//    size_t bytesReadIntoBuffer; // number of bytes accumulated into buffer with multiple read calls
//    size_t maxBytesForInput; // macimum number of bytes that can be read into our input buffer
//    int     tries;          // Number of tries so far
//    
//    Boolean result = FALSE;
//    
//    // Send the output command to the serial port
//    char txString[256];
//    txString[0] = 'P';
//    txString[1] = '\r';
//    txString[2] = 0;
//    char outText[] = "P";
//    sprintf(txString,"%s\r",outText);
//    
//    numBytes = write(fileDescriptor,txString,strlen(txString));
//
//    char inString[256];
//    numBytesRead = read(fileDescriptor,inString, 255  );
//        
//        
//    
//    
//    return NULL;
//}


//static char *MyLogString(char *str) {
//// print unprintable characters
//	static char	 buf[2048];
//	char			*ptr = buf;
//	int			 i;
//
//	*ptr = '\0';
//
//	while (*str)
//	{
//		if (isprint(*str))
//		{
//			*ptr++ = *str++;
//		}
//		else {
//			switch(*str)
//			{
//			case ' ':
//				*ptr++ = *str;
//				break;
//
//			case 27:
//				*ptr++ = '\\';
//				*ptr++ = 'e';
//				break;
//
//			case '\t':
//				*ptr++ = '\\';
//				*ptr++ = 't';
//				break;
//
//			case '\n':
//				*ptr++ = '\\';
//				*ptr++ = 'n';
//				break;
//
//			case '\r':
//				*ptr++ = '\\';
//				*ptr++ = 'r';
//				break;
//
//			default:
//				i = *str;
//				(void)sprintf(ptr, "\\%03o", i);
//				ptr += 4;
//				break;
//			}
//
//			str++;
//		}
//		*ptr = '\0';
//	}
//	return buf;
//}
//

//int setSerialPortSettings(c_cflag, int dataBits, int parity, int stopBits) {
//
//}
//SerialPortSettings(struct termios  options) {
//	
//	
//if (options.c_cflag & CS5 )		// Use 5 bit words
//if (options.c_cflag & CS6 )		// Use 6 bit words
//if (options.c_cflag & CS7 )		// Use 7 bit words
//if (options.c_cflag & CS8 ) 	// Use 8 bit words
//
//if (options.c_cflag & CSTOPB )	// 2 stop bits
//if (options.c_cflag & CREAD )	// always enabled: receiver is enabled
//
//if (options.c_cflag & PARENB )	// enable parity bit
//if (options.c_cflag & PARODD )  // use odd parity instead of even
//if (options.c_cflag & HUPCL )	// hangup (drop dtr) on last close
//if (options.c_cflag & CLOCAL )	// always enabled: local line - do not change owner of port
//if (options.c_cflag & CRTSCTS ) // endable hardware flow control
//		
//	
//}
