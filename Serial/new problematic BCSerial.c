/* 
 * 2013-3-4 from BRF iMAC -- use this one, not uniDisk version
 *  BCSerial.c
 *  Blink
 *
 *  Created by Tom Houpt on Wed Oct 06 2004.
 *  Copyright (c) 2004 Behavioral Cybernetics LLC. All rights reserved.
 
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
// for Prior stage controller: 8 bits, no parity, 1 stop bit, no flow control
// for Sartorius balance: 7 data bits, odd parity, 1 stop bit



// some notes on termios: http://www.lafn.org/~dave/linux/terminalIO.html

// Note: The serial ports and the USB Keyspan adapter in particular has problems dealing with sleep mode
// so make sure that Power Manager callbacks close serial port before sleep, and re-open serial port upon wakening.
// this should probably be handled by the object using these serial routines
// http://elecraft.365791.n2.nabble.com/USB-Serial-adapters-and-sleep-mode-on-OS-X-td5501652.html
// power manager:  http://developer.apple.com/mac/library/qa/qa2004/qa1340.html
/*
 
 from: http://elecraft.365791.n2.nabble.com/USB-Serial-adapters-and-sleep-mode-on-OS-X-td5501652.html
 
 David Fleming-2
 Sep 05, 2010; 8:21pm USB/Serial adapters and sleep mode on OS X
 
 After doing lots of testing, I've come up with some interesting observations.
 When OS X goes to sleep, either from an idle timeout or a forced sleep (selecting 'Sleep' from the Apple menu), *some* USB to Serial adapters can end up in an unresponsive state after OS X wakes up. I've tested this with the three most common adapters, Keyspan, FTDI and Prolific. The Prolific adapters seem to tolerate a sleep cycle just fine without any untoward side effects. But the Keyspan and FTDI adapters get very grumpy when they wake up after being put to sleep. In the case of the Keyspan, all open connections are closed when it goes to sleep. Upon awakening, the Keyspan port remains closed until the app re-opens it. But.. I found that if an app is actively polling the serial port at the time it is put to sleep, for example while W2.exe is running and polling the port very rapidly, the adapter can wake up in an unresponsive, or unreliable state. The Keyspan adapter must be unplugged and replugged to recover. This happens every time with the
 Keyspan adapter IF it is being actively polled at the time it goes to sleep. If it is not being polled at the time the OS goes to sleep, for example while the W2 Utility is connected but idle, the Keyspan will wake up healthy and responsive. It's not necessary to unplug and replug to get it back, but the port still remains closed until it is re-opened by the app. In the case of the FTDI adapter, the port is not closed when it goes to sleep. If it is not being actively polled at the time it goes to sleep, then it wakes up healthy and all is well. But if it IS being polled when it goes to sleep, for example by W2.exe, then it wakes up totally messed up and must be unplugged and replugged to regain consciousness.
 Thanks, Dale, for pointing this out. I'm surprised this hasn't come up before. I've been writing serial port apps for the Mac for many years. This is the first time I've had someone point out this problem when an app is running when the Mac goes to sleep.
 I will be adding code to all my apps to close the serial port whenever the computer is going to sleep and to reopen the port upon awakening. In the mean time, users of the Keyspan and FTDI USB/Serial adapters should close all apps that use the serial port before putting the Mac to sleep (W2.exe, W2 Utility, K3 Utility, and P3 Utility) .
 David, W4SMT
 
*/


// Sartorius Balance notes:
// Is this relevant? I don't think so. http://stackoverflow.com/questions/12143603/ewcom-protocol-communication-over-rs232-hardware


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

/* 
to view connected USB devices
In a Terminal window, type or paste the following command:
system_profiler SPUSBDataType
When you press Return, you'll see a descriptive list of all USB devices connected to the host. It's the same information you get from System Profiler by selecting Hardware » USB.
*/

/*
 2014-2-3
 Currently have a Keyspan USA-28XB connected to Prior Stage (Blink) and to Sartorius scale (BarTender)
 http://www.tripplite.com/en/products/model.cfm?txtModelID=3914
 driver: com.keyspan.iokit.usb.KeyspanUSAdriver(2.6)
 Driver for USA-19HS and USA-28XG(Mac OS X 10.6.x to 10.8.x)

 Device names:
    "/dev/cu.USA28Xfd432P1.1"
    "/dev/cu.USA28Xfd432P2.2"
    "/dev/cu.KeySerial1"
 
 note that "fd432" substring may be cpu dependent, so search with wildcard,
 e.g.  "/dev/cu.USA28X*P1.1"
 
*/

/* debugging kernal panic:
 
 - check malloc calls? [prolonged latency to crash]
 - double check buffers and ptrs into buffers [prolonged latency to crash]
 - try keyspan preference to set to "use as printer port"
 - check if "modem reset on signal drop" is set
 - try output arbitrarily large number of bytes
 - try just reads
 - try just writes
 - try USA-28XG instead of USA-28XB (neither of which are currently available?)
 - try varying stage position timer, e.g. 100/sec vs. 1/min
 - try turning off wifi
 - try removing PS3 controller [prolonged latency to crash]
*/

//#include <Foundation/Foundation.h>
#include "BCSerial.h"



static kern_return_t FindRS232Port(io_iterator_t *matchingServices);
static kern_return_t GetSerialPath(io_iterator_t serialPortIterator, char *deviceFilePath, const char * targetPath, CFIndex maxPathSize);


// static char *MyLogString(char *str);
short wildstrncmp(const char *subject,const char *query,size_t q_length);



enum {
    kNumRetries = 10
};

// Hold the original termios attributes so we can reset them
static struct termios gOriginalTTYAttrs;


int FindAndOpenSerialPort(const char *targetFilePath, Boolean *serialPortFound, Boolean *deviceFound, int numDataBits, int parity, int numStopBits) {

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
        printf("IOMasterPort returned %d\n", kernResult);
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
        // kIOSerialBSDAllTypes, kIOSerialBSDModemType, or kIOSerialBSDRS232Type.
        //You can experiment with the matching by changing the last parameter in the above call
        // to CFDictionarySetValue.

    }

    kernResult = IOServiceGetMatchingServices(masterPort, classesToMatch, matchingServices);    

    if (KERN_SUCCESS != kernResult) {
        //printf("Error: IOServiceGetMatchingServices returned %d\n", kernResult);
		goto exit;
    }
        

exit:

    return kernResult;

}

short wildstrncmp(const char *subject,const char *query,size_t q_length) {

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


static kern_return_t GetSerialPath(io_iterator_t serialPortIterator, char *deviceFilePath, const char * targetPath, CFIndex maxPathSize) {

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
								printf("BSD path: %s\n", deviceFilePath);
								// we have a C string with the device path, is it the one we want? 
								

								if (wildstrncmp(deviceFilePath,targetPath,strlen(targetPath)) == 0) {
									portFound = true;
									kernResult = KERN_SUCCESS;
									
								}
					}

        }

        printf("\n");
        // Release the io_service_t now that we are done with it.

		(void) IOObjectRelease(serialService);

    }
	


    return kernResult;

}

int OpenSerialPort(const char *deviceFilePath, int numDataBits, int parity, int numStopBits) {

    int				fileDescriptor = kNoSerialPort;
    int				handshake;
    struct termios  options;

    // Open the serial port read/write (O_RDWR), with no controlling terminal (O_NOCTTY), 
    // and don't wait for a connection.
    // The O_NONBLOCK flag also causes subsequent I/O on the device to 
    // be non-blocking.
    // See open(2) ("man 2 open") for details.

    fileDescriptor = open(deviceFilePath, O_RDWR | O_NOCTTY | O_NONBLOCK);

    if (fileDescriptor == kNoSerialPort) {
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
    
    // 2014-10-20 actually, we want the O_NONBLOCK flag set to that:
/*    Another dependency is whether the O_NONBLOCK flag is set by open() or
    fcntl().  If the O_NONBLOCK flag is clear, then the read request is
    blocked until data is available or a signal has been received.  If the
    O_NONBLOCK flag is set, then the read request is completed, without
    blocking, in one of three ways:
    
    1.   If there is enough data available to satisfy the entire
    request, and the read completes successfully the number of
    bytes read is returned.
    
    2.   If there is not enough data available to satisfy the entire
    request, and the read completes successfully, having read as
    much data as possible, the number of bytes read is returned.
    
    3.   If there is no data available, the read returns -1, with errno
    set to EAGAIN.
    
    When data is available depends on whether the input processing mode is
    canonical or noncanonical.
*/


    //2014-10-20 try setting F_SETFL -> O_NONBLOCK (used to be F_SETFL -> 0)
    
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
    
//    the correct method is for an application to snapshot the current terminal state using the function tcgetattr(),
//    setting raw mode with cfmakeraw() and the subsequent tcsetattr(),
//    and then using another tcsetattr() with the saved state to revert to the previous terminal state.

    // The serial port attributes such as timeouts and baud rate are set by 
    // modifying the termios structure and then calling tcsetattr to
    // cause the changes to take effect. Note that the
    // changes will not take effect without the tcsetattr() call.
    // See tcsetattr(4) ("man 4 tcsetattr") for details.
    
    // Print the current input and output baud rates.
    // See tcsetattr(4) ("man 4 tcsetattr") for details.    

    // printf("Current input baud rate is %d\n", (int) cfgetispeed(&options));
    // printf("Current output baud rate is %d\n", (int) cfgetospeed(&options));

	// Set raw input (non-canonical) mode, with reads blocking until either 
    // a single character has been received or a one second timeout expires.
    // See tcsetattr(4) ("man 4 tcsetattr") and termios(4) ("man 4 termios") 
    // for details.


	
    options = gOriginalTTYAttrs; //*** CHANGED LINE: old present, new deleted
    cfmakeraw(&options);
    
    // if c_cc[VMIN] == 1, then wait for at least 1 byte, then start timer. 
    // if c_cc[VMIN] == 0, then start timer; at least 1 byte must be read before VTIME expires, or 0 bytes are returned... 
    options.c_cc[VMIN] = 1; 
    options.c_cc[VTIME] = 10;

    // The baud rate, word length, and handshake options can be set as follows:
    cfsetspeed(&options, B9600);   // Set 9600 baud 
	
/*
     Basic Terminal Hardware Control Modes (c_cflag)
 
     Values of the c_cflag field describe the basic terminal hardware control, and are composed of the following
     masks.  Not all values specified are supported by all hardware.
     
     CSIZE        character size mask
     CS5          5 bits (pseudo)
     CS6          6 bits
     CS7          7 bits
     CS8          8 bits
     CSTOPB       send 2 stop bits
     CREAD        enable receiver
     PARENB       parity enable
     PARODD       odd parity, else even
     HUPCL        hang up on last close
     CLOCAL       ignore modem status lines
     CCTS_OFLOW   CTS flow control of output
     CRTSCTS      same as CCTS_OFLOW
     CRTS_IFLOW   RTS flow control of input
     MDMBUF       flow control output via Carrier
     
*/
    
    
	// for Prior stage controller: 8 bits, no parity, 1 stop bit, no flow control
    // for Sartorius balance: 7 data bits, odd parity, 1 stop bit

	printf("termios raw options.c_cflag:%lx\n", options.c_cflag);
            options.c_cflag =       0;					// NOTE: maybe should not do this, in case any default options that need to be preserved
    //*** CHANGED LINE: old enabled, new disabled
            options.c_cflag |=   	CREAD;		// always enabled: receiver is enabled
            options.c_cflag |=   	CLOCAL;		// always enabled: connection does not depend on modem status lines
	
	
	// set the data bits
            options.c_cflag &=   	~CSIZE;		// mask the character size bits
	
	switch (numDataBits) {
			
		case 5:
			options.c_cflag |=   	CS5;		// Use 5 data bits
			break;
			
		case 6:
			options.c_cflag |=   	CS6;		// Use 6 data bits
			break;
			
		case 7:
			options.c_cflag |=   	CS7;		// Use 7 data bits
			break;

		case 8:
			options.c_cflag |=   	CS8;		// Use 8 data bits
			break;
			
	}
	
	// set the parity
            options.c_cflag &=   	~PARENB;		// disable parity bit
            options.c_cflag &=   	~PARODD;    // disable odd parity
	
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
	
    
 /*   
    Basic Terminal Input Control Modes (c_iflag)

  Values of the c_iflag field describe the basic terminal input control, and are composed of following
masks:
    
    IGNBRK    ignore BREAK condition 
    BRKINT    map BREAK to SIGINTR 
    IGNPAR    ignore (discard) parity errors 
    PARMRK    mark parity and framing errors 
    INPCK     enable checking of parity errors 
    ISTRIP    strip 8th bit off chars 
    INLCR     map NL into CR 
    IGNCR     ignore CR 
    ICRNL     map CR to NL (ala CRMOD) 
    IXON      enable output flow control 
    IXOFF     enable input flow control 
    IXANY     any char will restart after stop 
    IMAXBEL  ring bell on input queue full
    IUCLC    translate upper case to lower case
    
*/
    //**** CHANGED LINE: old didnt set c_iflag, new we did set c_iflag as follows:
    // attempts to keep queue from overflowing...
 //  options.c_iflag |=      IXOFF;
 //  options.c_iflag &=   	~IMAXBEL; // flush the queue if it gets too full

/*    
    2014-8-8 -- having problems with buffer overflowing on old MacBook Pro running 10.7: 
    "USA 28X Driver Add Bytes To Queue queue full"
 
    Each terminal device file has associated with it an input
    queue, into which incoming data is stored by the system before being read by a process.  The system
    imposes a limit, {MAX_INPUT}, on the number of bytes that may be stored in the input queue.  The behavior
     of the system when this limit is exceeded depends on the setting of the IMAXBEL flag in the termios
    c_iflag.  If this flag is set, the terminal is sent an ASCII BEL character each time a character is
    received while the input queue is full.  Otherwise, the input queue is flushed upon receiving the character.
*/


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

	printf("Handshake lines currently set to %d\n", handshake);
	
    printf("termios as set options.c_cflag:%lx\n", options.c_cflag);
    
	// Success:
    return fileDescriptor;

    // Failure:

error:

    if (fileDescriptor != kSerialErrReturn) {
        close(fileDescriptor);
    }
    return kNoSerialPort;

}

void CloseSerialPort(int fileDescriptor) {

    // just return if this is a bad fileDescriptor
    if (fileDescriptor == kNoSerialPort) { return; }
    
    // Block until all written output has been sent from the device.
    // Note that this call is simply passed on to the serial device driver.
    // See tcsendbreak(3) ("man 3 tcsendbreak") for details.

    if (tcdrain(fileDescriptor) == kSerialErrReturn) {
        printf("CloseSerialPort: Error waiting for drain - %s(%d).\n", strerror(errno), errno);
    }

	// It is good practice to reset a serial port back to the state in
    // which you found it. This is why we saved the original termios struct
    // The constant TCSANOW (defined in termios.h) indicates that
    // the change should take effect immediately.

    if (tcsetattr(fileDescriptor, TCSANOW, &gOriginalTTYAttrs) ==  kSerialErrReturn) {
		printf("CloseSerialPort: Error resetting tty attributes - %s(%d).\n", strerror(errno), errno);
    }

    close(fileDescriptor);

}

unsigned long totalBytesSent = 0;
unsigned long totalBytesReceived = 0;
unsigned long totalReceivedInThousands = 0;


 Boolean SendCommandToSerialPort (int fileDescriptor, const char *outString) {

	// send a command to serial port at fileDescriptor, and ignore any response from the serial device
	 
    ssize_t numBytes;       // Number of bytes read or written
	size_t numBytesForOutput;	// Number of bytes that should be written
    int     tries;          // Number of tries so far

	 numBytesForOutput = strlen(outString);
	 
    Boolean result = FALSE;

    for (tries = 1; tries <= kNumRetries; tries++) {
		
       // Send the output command to the serial port
        numBytes = write(fileDescriptor, outString, numBytesForOutput);
        tcdrain(fileDescriptor);

		if ( numBytes == kSerialErrReturn ) {
            printf("Error writing to modem - %s(%d).\n", strerror(errno), errno);
			// try again
            continue;
        }

		// else { // printf("Wrote %ld bytes \"%s\" (of %ld bytes) \n", numBytes, MyLogString(outString), numBytesForOutput); }

		if ( numBytes >= (ssize_t) numBytesForOutput ) {
			// wrote out all data, can stop trying to write out
            result = TRUE;
            totalBytesSent += numBytes;
			break;
		}
    }
	 	 
     // flush the buffers every so often?
     // will this prevent crash on OSX 10.7?
     if ((totalBytesReceived / 1000) > totalReceivedInThousands) {
         totalReceivedInThousands = totalBytesReceived / 1000;
         printf("total sent: %lu total read: %lu\n",totalBytesSent, totalBytesReceived);
     }
     tcflush(fileDescriptor,TCIOFLUSH);
     
    return result;

}

Boolean SendCommandToSerialPortWithExpectedResponse (int fileDescriptor, const char *outString, const char *expectedResponseString) {
    
    // send a query to the serial port at fileDescriptor, wait for a CR or LF terminated response
    // return TRUE if the  response received from the serial port matches the expectedResponseString
    // return FALSE if the response doesn't match the expected string
    // only processes a response the same length or less than the  length of expectedResponseString
    // expectedResponseString should be NULL or be /0 terminated

    Boolean returnFlag = FALSE;
    
    Boolean noResponseNeeded = FALSE;
    size_t maxResponseLength;
    if (expectedResponseString == NULL) { noResponseNeeded = TRUE; maxResponseLength = 0;}
    else { maxResponseLength = strlen(expectedResponseString); }
    if (maxResponseLength == 0)  { noResponseNeeded = TRUE; }
    if (maxResponseLength > READ_BUFFER_SIZE)  { return (FALSE); } // can't get a response bigger than the allocated input buffer
    
    if (noResponseNeeded) {
        // just send the command, ignore any response
        returnFlag = SendCommandToSerialPort (fileDescriptor,outString);
        
    }

    else {
        // allocate a response string,
        // then send the command, get a response,
        // compare it to the expectedResponseString
        
        char *responseString = malloc(maxResponseLength * sizeof(char));
        if (NULL == responseString) {
            printf("SendCommandToSerialPortWithExpectedResponse: malloc failed.");
            return FALSE;
        }
        
        if ( SendQueryToSerialPort(fileDescriptor,outString, responseString, maxResponseLength)) {
            
            if (strncmp(responseString, expectedResponseString,maxResponseLength) == 0) {
                // response matches expected response
                returnFlag = TRUE;
            }
            else {
                
                printf("SendCommandToSerialPortWithExpectedResponse: response %s did not match expected %s.",responseString,expectedResponseString );
            }
        
        }
        free(responseString);
    }
    
    return returnFlag;
    
}



 Boolean SendQueryToSerialPort (int fileDescriptor, const char *outString, char *responseString,size_t maxResponseLength) {
	 
 // send a query to the serial port at fileDescriptor, wait for a CR or LF terminated response
 // put the response into responseString buffer (of maximum byte length maxResponseLength)

    char    buffer[READ_BUFFER_SIZE];    // Input buffer
    char    *bufPtr;        // Current char in buffer
    ssize_t numBytes;       // Number of bytes read or written in a single read/write call
    size_t  numBytesForOutput;	// Number of bytes that should be written
    size_t bytesReadIntoBuffer; // number of bytes accumulated into buffer with multiple read calls
    size_t maxBytesForInput; // macimum number of bytes that can be read into our input buffer
    int     tries;          // Number of tries so far

    Boolean result = FALSE;

    if (maxResponseLength > READ_BUFFER_SIZE)  { return (FALSE); } // can't get a response bigger than the allocated input buffer

	numBytesForOutput = strlen(outString);
	 
	// try sending the output string kNumRetries, or until all the bytes have been output
    for (tries = 1; tries <= kNumRetries; tries++) {
		
       // Send the output command to the serial port
        numBytes = write(fileDescriptor, outString,numBytesForOutput);
      //  tcdrain(fileDescriptor);

		if ( numBytes == kSerialErrReturn ) {
            printf("SendQueryToSerialPort: Error writing to modem - %s(%d).\n", strerror(errno), errno);
            continue;
        }
		// else { printf("Wrote %ld bytes \"%s\" (of %ld bytes)\n", numBytes, MyLogString(outString),numBytesForOutput ); }

		if ( numBytes >= (ssize_t)numBytesForOutput ) {
			
			// succeeding, do don't have to try writing anymore
            totalBytesSent += numBytes;

			break;
		}
	}
		
     if (numBytes < (ssize_t)numBytesForOutput) {
         
         printf("SendQueryToSerialPort: Error writing to modem - wrote only %lu numByte of %lu numBytesForOutput", numBytes, numBytesForOutput);

         return FALSE; // failed to write out
     }
		
		
	// sometimes looking for a specific response,like "OK" -- but not here.
	// printf("Looking for \"%s\"\n", MyLogString(responseString));

	// But in this case, for the response, we read characters into our buffer until we get a CR or LF.

    bufPtr = buffer;
    bytesReadIntoBuffer = 0;

     tries = 1;

    do {
        maxBytesForInput = READ_BUFFER_SIZE - 1 - bytesReadIntoBuffer;

        numBytes = read(fileDescriptor, bufPtr, maxBytesForInput  );

        if (numBytes == kSerialErrReturn) {
            
            if ( tries > kNumRetries) {
                printf("SendQueryToSerialPort: Error reading from modem - %s(%d).\n", strerror(errno), errno);
                return FALSE;
            }
            tries++;
        }
        else if (numBytes > 0) {
            bytesReadIntoBuffer += (size_t)numBytes;
            bufPtr += numBytes;
            if (*(bufPtr - 1) == '\n' || *(bufPtr - 1) == '\r')  {
                break;
            }
            totalBytesReceived += numBytes;
        }
        // else { printf("Nothing read.\n"); }

    } while ( tries <= kNumRetries); // repeat read

	// NULL terminate the string and see if we got a response longer than 0 bytes.
     // make sure we aren't writing past the end of the buffer
     if ( bufPtr - buffer >= READ_BUFFER_SIZE) {
         
         printf("SendQueryToSerialPort: bufPtr points beyond READ_BUFFER_SIZE");
          return FALSE;
         
     }
	*bufPtr = '\0';
	// printf("Read in: \"%s\"\n", MyLogString(buffer));
	
	if (strlen(buffer) > 0) {
		
        // make sure we aren't writing past the end of the buffer

		strncpy(responseString,buffer,maxResponseLength);
		
		result = TRUE;
	}

     // flush the buffers every so often?
     // will this prevent crash on OSX 10.7? -- NO
     if ((totalBytesReceived / 1000) > totalReceivedInThousands) {
         totalReceivedInThousands = totalBytesReceived / 1000;
         printf("SendQueryToSerialPort: total sent: %lu total read: %lu\n",totalBytesSent, totalBytesReceived);
     }
     tcflush(fileDescriptor,TCIOFLUSH);
    
    return result;
}


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


