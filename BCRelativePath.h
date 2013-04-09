
//
//  BCRelativePath.h
//  MindsEye
//
//  Created by Tom Houpt on 11/5/7.
//  Copyright 2011 BehavioralCybernetics. All rights reserved.
//


#import <Cocoa/Cocoa.h>

NSString *RelativePathFromAbsoluteFilePath(NSString *filePath, NSString *baseFilePath);
NSString *AbsolutePathFromRelativeFilePath(NSString *relativePath, NSString *baseFilePath); 


NSSavePanel *SavePanelForFilenameAndType(NSString *currentFilename, NSString *typeUTI);
