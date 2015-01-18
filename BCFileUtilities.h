
//
//  BCFileUtilities.h
//  MindsEye
//
//  Created by Tom Houpt on 11/5/7.
//  Copyright 2011 BehavioralCybernetics LLC. All rights reserved.
//


#import <Cocoa/Cocoa.h>

NSString *RelativePathFromAbsoluteFilePath(NSString *filePath, NSString *baseFilePath);
NSString *AbsolutePathFromRelativeFilePath(NSString *relativePath, NSString *baseFilePath); 


NSSavePanel *SavePanelForFilenameAndType(NSString *currentFilename, NSString *typeUTI);


void MakeTemporaryBackupCopyOfFileAtURL(NSURL *srcURL, NSError **error) __deprecated_msg("best to upgrade to autosave-versioning.");
// given at file at srcURL, make a copy named "Backup of ..."
// calls NSFileManager copyItemAtURL:toURL:error:

void FinalizeTemporaryBackup(NSURL *srcURL, NSError **error) __deprecated_msg("best to upgrade to autosave-versioning.");
    // given at temporary backup of the file at srcURL, rename the temporary backup to "Backup of ..."
    // calls NSFileManager moveItemAtURL:toURL:error:

void RestoreFromTemporaryBackup(NSURL *srcURL, NSError **error) __deprecated_msg("best to upgrade to autosave-versioning.");
    // given at temporary backup of the file at srcURL, rename the temporary backup to the original filename
    // calls NSFileManager moveItemAtURL:toURL:error:

NSString *GenerateUniqueFileNameAtPath(NSString *path, NSString *basename, NSString *extension);

    // given a path, get a file name based on "/path/basename.extension",
    // but 1,2,3, etc appended if earlier files already exist

NSArray *ArrayOfMissingDataLabels(void);
    // @”<none>”, @”--”, @”nd”, @”n.d.”, @”n.a.”, @”.”, @”null”, @”nil”

