//
//  iTunesQuartzComposerPluginPlugIn.m
//  iTunesQuartzComposerPlugin
//
//  Created by chris on 29/03/2013.
//  Copyright (c) 2013 Chris Birch. All rights reserved.
//

// It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering
#import <OpenGL/CGLMacro.h>
#import "Helper.h"

#import "iTunesQuartzComposerPluginPlugIn.h"

#define	kQCPlugIn_Name				@"iTunesController"
#define	kQCPlugIn_Description		@"Version: 0.13\nAllows QC compositions to access data and control playback of iTunes"
#define kQCPlugIn_AuthorDescription @"© 2013 by Chris Birch, all rights reserved."

#define PROFILE_TIMES 0

@implementation iTunesQuartzComposerPluginPlugIn


//Port Synthesizes

@dynamic outputTrackImage;
@dynamic outputTrackURL;
@dynamic outputArtist;

@dynamic outputPlaying;
@dynamic outputCurrentTrack;
@dynamic outputTrackDuration;
@dynamic outputTrackRating;
@dynamic outputPlaylistName;
@dynamic outputVolume;
@dynamic outputBPM;
@dynamic outputPlayerPosition;
@dynamic inputSetPlayerPosition;
@dynamic inputSetTrackName;
@dynamic inputPlaying;
@dynamic inputPlayNextTrack;
@dynamic inputPlayPreviousTrack;
@dynamic inputSetVolume;
@dynamic inputUpdateInterval;
@dynamic inputUpdateUsingInterval;
@dynamic inputForceUpdate;

@dynamic inputPlaylistIndex;
@dynamic inputSongIndex;
@dynamic outputPlaylistAtIndexTrackCount;
@dynamic outputTrackNameAtIndex;
@dynamic outputTrackURLAtIndex;
@dynamic outputArtworkAtIndex;

@dynamic outputAvailablePlaylists;
@dynamic outputPreviewArtwork;
@dynamic inputMaxPreviewImages;

// Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
//@dynamic inputFoo, outputBar;

+ (NSDictionary *)attributes
{
	// Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
    return @{
                QCPlugInAttributeNameKey:kQCPlugIn_Name,
                QCPlugInAttributeDescriptionKey:kQCPlugIn_Description,
                QCPlugInAttributeCopyrightKey: kQCPlugIn_AuthorDescription
    
            };
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
    //Port Attributes
    
    //An image representing the current track
    if([key isEqualToString:OUTPUT_TRACKIMAGE])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Track Image", QCPortAttributeNameKey,
                nil];
    //String describing the URL of the currenly playing track
    else if([key isEqualToString:OUTPUT_TRACKURL])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Track URL", QCPortAttributeNameKey,
                nil];
    //String describing the name of the current artist
    else if([key isEqualToString:OUTPUT_ARTIST])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Artist", QCPortAttributeNameKey,
                nil];    
    else if([key isEqualToString:OUTPUT_PLAYING])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Is Playing", QCPortAttributeNameKey,
                nil];
    //String describing the name of the current track
    else if([key isEqualToString:OUTPUT_CURRENTTRACK])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Current Track", QCPortAttributeNameKey,
                nil];
    //the length of the track in seconds
    else if([key isEqualToString:OUTPUT_TRACKDURATION])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Track Duration", QCPortAttributeNameKey,
                nil];
    //Describes the rating of the current track
    else if([key isEqualToString:OUTPUT_TRACKRATING])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Track Rating", QCPortAttributeNameKey,
                nil];
    //int describing the position of the current track in seconds
    else if([key isEqualToString:OUTPUT_TRACKLOCATION])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Track Location", QCPortAttributeNameKey,
                nil];
    //String describing the name of the current playlist
    else if([key isEqualToString:OUTPUT_PLAYLISTNAME])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Playlist Name", QCPortAttributeNameKey,
                nil];
    //Describes the volume
    else if([key isEqualToString:OUTPUT_VOLUME])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Volume", QCPortAttributeNameKey,
                nil];
    //Describes the BPM of the current track
    else if([key isEqualToString:OUTPUT_BPM])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Beats Per Minute", QCPortAttributeNameKey,
                nil];
    //the player’s position within the currently playing track in seconds.
    else if([key isEqualToString:OUTPUT_PLAYERPOSITION])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Player Position", QCPortAttributeNameKey,
                nil];
    //Sets the position of the player
    else if([key isEqualToString:INPUT_SETPLAYERPOSITION])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Set Player Position", QCPortAttributeNameKey,
                @"0", QCPortAttributeDefaultValueKey,
                nil];
    //Sets the name of the track to play
    else if([key isEqualToString:INPUT_SETTRACKNAME])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Set Track Name", QCPortAttributeNameKey,
                nil];
    //Yes if iTunes should play
    else if([key isEqualToString:INPUT_PLAYING])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Playing", QCPortAttributeNameKey,
                [NSNumber numberWithBool:NO], QCPortAttributeDefaultValueKey,
                nil];
    //Pulse to play next track
    else if([key isEqualToString:INPUT_PLAYNEXTTRACK])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Play Next Track", QCPortAttributeNameKey,
                [NSNumber numberWithBool:NO], QCPortAttributeDefaultValueKey,
                nil];
    //Pulse to play previous track
    else if([key isEqualToString:INPUT_PLAYPREVIOUSTRACK])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Play Previous Track", QCPortAttributeNameKey,
                [NSNumber numberWithBool:NO], QCPortAttributeDefaultValueKey,
                nil];
    //Sets the volume of the track. max = 100
    else if([key isEqualToString:INPUT_SETVOLUME])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Set Volume", QCPortAttributeNameKey,
                @"100", QCPortAttributeDefaultValueKey,
                nil];
    //The number of seconds that should elapse before causing an update of iTunes info
    else if([key isEqualToString:INPUT_UPDATEINTERVAL])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Update Interval Seconds", QCPortAttributeNameKey,
                @"0.1", QCPortAttributeDefaultValueKey,
                nil];
    //Should automatically update or should update on request
    else if([key isEqualToString:INPUT_UPDATEUSINGINTERVAL])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Update using interval", QCPortAttributeNameKey,
                [NSNumber numberWithBool:YES], QCPortAttributeDefaultValueKey,
                nil];
    //causes an update of iTunes info
    else if([key isEqualToString:INPUT_FORCEUPDATE])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Force Update", QCPortAttributeNameKey,
                [NSNumber numberWithBool:NO], QCPortAttributeDefaultValueKey,
                nil];
	else if([key isEqualToString:OUTPUT_AVAILABLEPLAYLISTS])
		return [NSDictionary dictionaryWithObjectsAndKeys:
			@"All Playlists", QCPortAttributeNameKey,
			nil, QCPortAttributeDefaultValueKey,
			nil];
	else if([key isEqualToString:OUTPUT_PLAYLISTATINDEXTRACKCOUNT])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Playlist at index track count", QCPortAttributeNameKey,
				nil, QCPortAttributeDefaultValueKey,
				nil];
	else if([key isEqualToString:OUTPUT_TRACKNAMEATINDEX])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Track name at index", QCPortAttributeNameKey,
				nil, QCPortAttributeDefaultValueKey,
				nil];
	else if([key isEqualToString:OUTPUT_ARTWORKATINDEX])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Artwork at index", QCPortAttributeNameKey,
				nil, QCPortAttributeDefaultValueKey,
				nil];
	else if([key isEqualToString:INPUT_PLAYLISTINDEX])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Playlist Index", QCPortAttributeNameKey,
				nil, QCPortAttributeDefaultValueKey,
				nil];
	else if([key isEqualToString:INPUT_SONGINDEX])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Song Index", QCPortAttributeNameKey,
				nil, QCPortAttributeDefaultValueKey,
				nil];
	else if([key isEqualToString:OUTPUT_TRACKURLATINDEX])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Track URL at index", QCPortAttributeNameKey,
				nil, QCPortAttributeDefaultValueKey,
				nil];
	else if([key isEqualToString:INPUT_MAXARTWORKPREVIEWIMAGES])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Max Preview Images", QCPortAttributeNameKey,
				nil, QCPortAttributeDefaultValueKey,
				nil];
	else if([key isEqualToString:OUTPUT_PREVIEWARTWORK])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Preview Artwork", QCPortAttributeNameKey,
				nil, QCPortAttributeDefaultValueKey,
				nil];
	
	// Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
	return nil;
}

+ (QCPlugInExecutionMode)executionMode
{
	// Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
	return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode)timeMode
{
	// Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
	return kQCPlugInTimeModeTimeBase;
}

- (id)init
{
	self = [super init];
	if (self)
    {
		// Allocate any permanent resource required by the plug-in.
	}
	
	return self;
}


@end

#define ME @"com.itunesqcbridge"

@implementation iTunesQuartzComposerPluginPlugIn (Execution)

- (BOOL)startExecution:(id <QCPlugInContext>)context
{
	trackChanged = false;
    
	updateIndexPhoto = false;
	
	helperQueue = dispatch_queue_create("helperQueue", DISPATCH_QUEUE_SERIAL);
	
    /* Make sure there is not already a running instance in this Quartz Composer environment */
    if([[[context userInfo] objectForKey:ME] boolValue])
        return NO;
    
	// Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	// Return NO in case of fatal failure (this will prevent rendering of the composition to start).
    helper = [[Helper alloc] init];

    //set to -1 so we cause an update to happen immediately
    //on first execution
    timeAtLastUpdate = -1;
    
    /* Remember there's a running instance in the current Quartz Composer environment */
    [[context userInfo] setObject:[NSNumber numberWithBool:YES] forKey:ME];
    
    return YES;

}

- (void)enableExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
}

static void _BufferReleaseCallback(const void* address, void* context)
{
    /* Destroy the CGContext and its backing */
    free((void*)address);
}

-(id)processImage:(NSImage*)img withContext:(id <QCPlugInContext>)context
{
#if PROFILE_TIMES
	double t = CFAbsoluteTimeGetCurrent();
#endif
	
    CGContextRef                bitmapContext;
    CGImageSourceRef            source;
    CGImageRef                  image=NULL;
    void*                       baseAddress;
    size_t                      rowBytes;
    CGRect                      bounds;
    
    id<QCPlugInOutputImageProvider> provider=NULL;
    
    if (img == nil)
    {
        return nil;
    }
 
    source = CGImageSourceCreateWithData((CFDataRef)[img TIFFRepresentation],NULL);
    image = CGImageSourceCreateImageAtIndex(source, 0, NULL);

    
    /* Create CGContext backing */
    rowBytes = CGImageGetWidth(image) * 4;
    if(rowBytes % 16)
        rowBytes = ((rowBytes / 16) + 1) * 16;
    baseAddress = valloc(CGImageGetHeight(image) * rowBytes);
    if(baseAddress == NULL)
    {
        CGImageRelease(image);
        return nil;
    }
    
    /* Create CGContext and draw image into it */
    bitmapContext = CGBitmapContextCreate(baseAddress, CGImageGetWidth(image), CGImageGetHeight(image), 8, rowBytes, [context colorSpace], kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);
    if(bitmapContext == NULL)
    {
        free(baseAddress);
        CGImageRelease(image);
        return nil;
    }
    bounds = CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image));
    CGContextClearRect(bitmapContext, bounds);
    CGContextDrawImage(bitmapContext, bounds, image);
    
    /* We don't need the image and context anymore */
    CGImageRelease(image);
    CGContextRelease(bitmapContext);
    
    /* Create image provider from backing */
#if __BIG_ENDIAN__
    provider = [context outputImageProviderFromBufferWithPixelFormat:QCPlugInPixelFormatARGB8 pixelsWide:CGImageGetWidth(image) pixelsHigh:CGImageGetHeight(image) baseAddress:baseAddress bytesPerRow:rowBytes releaseCallback:_BufferReleaseCallback releaseContext:NULL colorSpace:[context colorSpace] shouldColorMatch:YES];
#else
    provider = [context outputImageProviderFromBufferWithPixelFormat:QCPlugInPixelFormatBGRA8 pixelsWide:CGImageGetWidth(image) pixelsHigh:CGImageGetHeight(image) baseAddress:baseAddress bytesPerRow:rowBytes releaseCallback:_BufferReleaseCallback releaseContext:NULL colorSpace:[context colorSpace] shouldColorMatch:YES];
#endif
    if(provider == nil)
    {
        free(baseAddress);
        return nil;
    }
    
#if PROFILE_TIMES
	NSLog(@"Process Image took %f", CFAbsoluteTimeGetCurrent() - t);
#endif
	
	return provider;
}

- (BOOL)execute:(id <QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary *)arguments
{
    bool doUpdate = false;
    
    //Port Value Changed code
        //Sets the position of the player
    if ([self didValueForInputKeyChange:INPUT_SETPLAYERPOSITION])
    {
		[helper setPlayerPosition:self.inputSetPlayerPosition];
        doUpdate = true;
    }
    //Sets the name of the track to play
    if ([self didValueForInputKeyChange:INPUT_SETTRACKNAME])
    {
		NSString *setTrackName = self.inputSetTrackName;
		dispatch_async(helperQueue, ^{
			[[helper memberLock] lock];
			helper.trackName = setTrackName;
			[[helper memberLock] unlock];
		});
		
        doUpdate = true;
    }
    //Yes if iTunes should play
    if ([self didValueForInputKeyChange:INPUT_PLAYING])
    {
        helper.playing = self.inputPlaying;
		doUpdate = true;
    }
    //Pulse to play next track
    if ([self didValueForInputKeyChange:INPUT_PLAYNEXTTRACK])
    {
        [helper playNextTrack];
        doUpdate = true;
    }
    //Pulse to play previous track
    if ([self didValueForInputKeyChange:INPUT_PLAYPREVIOUSTRACK])
    {
        [helper playPreviousTrack];
        doUpdate = true;
    }
    //Sets the volume of the track. max = 100
    if ([self didValueForInputKeyChange:INPUT_SETVOLUME])
    {
        helper.volume = self.inputSetVolume;
    }
    //The number of seconds that should elapse before causing an update of iTunes info
    if ([self didValueForInputKeyChange:INPUT_UPDATEINTERVAL])
    {
        _updateFrequency = self.inputUpdateInterval;
    }
    //Should automatically update or should update on request
    if ([self didValueForInputKeyChange:INPUT_UPDATEUSINGINTERVAL])
    {
        _updateOnInterval = self.inputUpdateUsingInterval;
    }
    
    if( [self didValueForInputKeyChange:INPUT_FORCEUPDATE] ||
        [self didValueForInputKeyChange:INPUT_SONGINDEX] ||
        [self didValueForInputKeyChange:INPUT_PLAYLISTINDEX] ||
        [self didValueForInputKeyChange:INPUT_MAXARTWORKPREVIEWIMAGES])
        doUpdate = true;
    
    //Are we autoupdating info from iTunes?
    if (
		_updateOnInterval ||
		doUpdate
		)
    {
        //check whether the time at last update is greater than the current time, i.e we have overflowed and returned to 0

        BOOL hasOverflowed = timeAtLastUpdate > time;
        NSTimeInterval timeSinceLastUpdate = time - timeAtLastUpdate;

        [helper setPlaylistIndex:(int)self.inputPlaylistIndex songIndex:(int)self.inputSongIndex];
        [helper setMaxPreviewImages:(int)self.inputMaxPreviewImages];
        
        //Should we update
        if ( (timeAtLastUpdate == -1 || hasOverflowed || timeSinceLastUpdate >= _updateFrequency) || [self didValueForInputKeyChange:INPUT_FORCEUPDATE] )
        {
            //reset elasped time and query itunes via scripting bridge
            timeAtLastUpdate = time;
	
			dispatch_async(helperQueue, ^{
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
				
                int changed = [helper queryiTunes]; // changed is bitwise : 0 -> No change
                                                    //                      1 -> kUpdateTrack (new track is playing)
                                                    //                      2 -> kUpdateIndex (playlist or song has changed)
			
//				[helper sanityCheck];

                if( changed & kUpdateTrack )
                    trackChanged = true;
        
                if( changed & kUpdateIndex )
                    updateIndexPhoto = true;
                
                [pool drain];
			});
			
        }
    }
	
    //set outputs

	[[helper memberLock] lock];

	if(trackChanged)
    {
     	self.outputTrackImage = [self processImage:helper.trackImage withContext:context];
        trackChanged = false;
    }
        
	if(updateIndexPhoto)
	{
		self.outputArtworkAtIndex = [self processImage:helper.artworkAtIndex withContext:context];
		self.outputPreviewArtwork = helper.artworkPreview;
		updateIndexPhoto = false;
	}
	
	self.outputTrackNameAtIndex = helper.trackNameAtIndex;
	self.outputTrackURLAtIndex = helper.trackURLAtIndex;
	
    self.outputArtist = helper.artistName;
    self.outputTrackURL = helper.trackURL;
    self.outputBPM = helper.bpm;
    self.outputCurrentTrack = helper.currentTrackName;
    self.outputPlayerPosition = helper.playerPosition;
    self.outputPlaylistName = helper.playlistName;
    self.outputTrackDuration = helper.trackDuration;
    self.outputTrackRating = helper.trackRating;
    self.outputVolume = helper.volume;
    self.outputPlaying = helper.playing;
    self.outputAvailablePlaylists = helper.allPlaylists;
    self.outputPlaylistAtIndexTrackCount = helper.playlistAtIndexTrackCount;
	
	[[helper memberLock] unlock];
	
	return YES;
}

- (void)disableExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
}

- (void)stopExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
    /* Our instance is about to stop running */
    [[context userInfo] removeObjectForKey:ME];
}

@end
