
//
//  BCRelativePath.m
//  MindsEye
//
//  Created by Tom Houpt on 11/5/7.
//  Copyright 2011 BehavioralCybernetics. All rights reserved.
//


#import "BCFileUtilities.h"

NSString *RelativePathFromAbsoluteFilePath(NSString *filePath, NSString *baseFilePath) {


	NSInteger level_of_base_directory;
	NSInteger deepest_common_directory_level;
	NSInteger number_of_doubledots;
	NSInteger i;
	
	NSArray *baseFilePathComponents = [baseFilePath pathComponents];
	NSArray *filePathComponents = [filePath pathComponents];
	


	// [baseFilePathComponents count] - 1 == the base file 
	// [baseFilePathComponents count] - 2 == the base directory 

	level_of_base_directory = [baseFilePathComponents count] - 2;

	#define BASEPATHDIRECTORY ((NSString *)[baseFilePathComponents objectAtIndex:deepest_common_directory_level])
	#define	FILEPATHDIRECTORY ((NSString *)[filePathComponents objectAtIndex:deepest_common_directory_level])

	deepest_common_directory_level = 0; // start at top of paths

	while ([BASEPATHDIRECTORY isEqualToString:FILEPATHDIRECTORY]) {

		   deepest_common_directory_level++;
			
			if (deepest_common_directory_level == [baseFilePathComponents count]) break;
			if (deepest_common_directory_level == [filePathComponents count]) break;
		
	}
	
	deepest_common_directory_level--; // need to substract 1 to correct for 0 indexing
	
	
	NSString *relativePath = [[NSString alloc] init];
	
	if (deepest_common_directory_level == level_of_base_directory) {

		// if (deepest_common_directory_level == level_of_base_directory)
		// then the rest of the pathDirectory is inside the basePathDirectory, so add a single dot
		
		// append @"." (single dot) to relative path
		relativePath = [relativePath stringByAppendingPathComponent:@"."];
		
	}
	
	else if (deepest_common_directory_level < level_of_base_directory) {
		
		// if (deepest_common_directory_level < level_of_base_directory)
		// then we need to add double-dots to get up to the common_directory from the base_directoy
		
		number_of_doubledots = level_of_base_directory - deepest_common_directory_level;
		
		for (i=0; i< number_of_doubledots; i++) {
			// append @".." (double dot) to relative path
			relativePath = [relativePath stringByAppendingPathComponent:@".."];
		}
		

	}

	//  append all the remaining path components from (deepest_common_directory_level+1) thru ([filepathComponents count] -1);
	
	for (i= (deepest_common_directory_level+1); i < [filePathComponents count]; i++) {
		
		// append [filepathComponents objectAtIndex:i] to relativePath
		relativePath = [relativePath stringByAppendingPathComponent:(NSString *)[filePathComponents objectAtIndex:i]];
		
	}
	
	return relativePath;

}

NSString *AbsolutePathFromRelativeFilePath(NSString *relativePath, NSString *baseFilePath) { 

	// get the path to the directory which contains the baseFile
	NSString *basePathDirectory = [baseFilePath stringByDeletingLastPathComponent];
	
	// the absolute path is the base directory + the relative path
	NSString *absoluteFilePath = [basePathDirectory stringByAppendingPathComponent:relativePath];
	
	// resolve any double-dots with the standardizing path method
	absoluteFilePath = [absoluteFilePath stringByStandardizingPath];
	
	return absoluteFilePath;
}




NSSavePanel *SavePanelForFilenameAndType(NSString *currentFilename, NSString *typeUTI) {
    

    // Build a new name for the file using the current name and
    // the filename extension associated with the specified UTI.
    // if the specificed UTI is "nil", then assume that name already has its extension
    
    NSString* newName ;
    
    if (nil != typeUTI) {
        CFStringRef newExtension = UTTypeCopyPreferredTagWithClass((CFStringRef)CFBridgingRetain(typeUTI),
                                                                   kUTTagClassFilenameExtension);
        newName = [[currentFilename stringByDeletingPathExtension]
                             stringByAppendingPathExtension:(NSString*)CFBridgingRelease(newExtension)];
    }
    else {
        
        newName = [currentFilename copy];
    }
   // CFRelease(newExtension); // already released in newName declaration
    
    // Set the default name for the file and show the panel.
    NSSavePanel*    panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:newName];
    
    return panel;

}


void MakeTemporaryBackupCopyOfFileAtURL(NSURL *srcURL, NSError **error) {
    
    // given at file at srcURL, make a copy named "Backup of ..."
    // calls NSFileManager copyItemAtURL:toURL:error:
    
      
    if ([[NSFileManager defaultManager] fileExistsAtPath:[srcURL path]]) {
        
        NSString *backupFileName = [NSString stringWithFormat: @"Temporary Backup of %@", [srcURL lastPathComponent]];
        
        NSURL *dstURL = [[srcURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:backupFileName];
        
        [[NSFileManager defaultManager] copyItemAtURL:srcURL toURL:dstURL error:error ];
            
    }

    
    
}

void FinalizeTemporaryBackup(NSURL *srcURL, NSError **error) {
    
    // given at temporary backup of the file at srcURL, rename the temporary backup to "Backup of ..."
    // calls NSFileManager moveItemAtURL:toURL:error:
            
        NSString *tempBackupFileName = [NSString stringWithFormat: @"Temporary Backup of %@", [srcURL lastPathComponent]];
        NSString *backupFileName = [NSString stringWithFormat: @"Backup of %@", [srcURL lastPathComponent]];

        
        NSURL *tempURL = [[srcURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:tempBackupFileName];
    
        if ([[NSFileManager defaultManager] fileExistsAtPath:[tempURL path]]) {

            NSURL *finalURL = [[srcURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:backupFileName];
        
            [[NSFileManager defaultManager] moveItemAtURL:tempURL toURL:finalURL error:error ];
        
        }
    
    
    
}

void RestoreFromTemporaryBackup(NSURL *srcURL, NSError **error) {
    
    // given at temporary backup of the file at srcURL, rename the temporary backup to the original filename
    // calls NSFileManager moveItemAtURL:toURL:error:
    
    NSString *tempBackupFileName = [NSString stringWithFormat: @"Temporary Backup of %@", [srcURL lastPathComponent]];
        
    
    NSURL *tempURL = [[srcURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:tempBackupFileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[tempURL path]]) {
                
        [[NSFileManager defaultManager] moveItemAtURL:tempURL toURL:srcURL error:error ];
        
    }
    
}

 NSString *GenerateUniqueFileNameAtPath(NSString *path, NSString *basename, NSString *extension) {
    NSString *filename = [NSString stringWithFormat:@"%@.%@", basename, extension];
    NSString *result = [path stringByAppendingPathComponent:filename];
    NSInteger i = 1;
    while ([[NSFileManager defaultManager] fileExistsAtPath:result]) {
        filename = [NSString stringWithFormat:@"%@ %ld.%@", basename, (long)i, extension];
        result = [path stringByAppendingPathComponent:filename];
        i++;
    }
    return result;
}

NSArray *ArrayOfMissingDataLabels(void) {
// @"<none>", @"--", @"nd", @"n.d.", @"n.a.", @".", @"null", @"nil", @"nan"
    
    return ( [NSArray arrayWithObjects:@"<none>", @"--", @"nd", @"n.d.", @"n.a.", @".", @"null", @"nil",@"nan", nil]);
    
    
}

