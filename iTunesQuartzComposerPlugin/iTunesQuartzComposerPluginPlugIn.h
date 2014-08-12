//
//  iTunesQuartzComposerPluginPlugIn.h
//  iTunesQuartzComposerPlugin
//
//  Created by chris on 29/03/2013.
//  Copyright (c) 2013 Chris Birch. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface iTunesQuartzComposerPluginPlugIn : QCPlugIn
{
	dispatch_queue_t helperQueue;

	bool updateIndexPhoto;

    bool trackChanged;


    Helper* helper;
    /**
     * The number of seconds that need to elapse before we call [helper queryiTunes] to
     * refresh the iTunes data
     */
    NSTimeInterval _updateFrequency;
    /**
     * Stores the time at the last update.
     */
    NSTimeInterval timeAtLastUpdate;
    
    /**
     * If YES then updates are requested from iTunes at the specified time intervals
     */
    BOOL _updateOnInterval;
}

//Port Defines
//An image representing the current track
#define OUTPUT_TRACKIMAGE @"outputTrackImage"
//String describing the URL of the currenly playing track
#define OUTPUT_TRACKURL @"outputTrackURL"
//String describing the name of the current artist
#define OUTPUT_ARTIST @"outputArtist"

//Describes whether or not the track is playing
#define OUTPUT_PLAYING @"outputPlaying"
//String describing the name of the current track
#define OUTPUT_CURRENTTRACK @"outputCurrentTrack"
//the length of the track in seconds
#define OUTPUT_TRACKDURATION @"outputTrackDuration"
//Describes the rating of the current track
#define OUTPUT_TRACKRATING @"outputTrackRating"
//int describing the position of the current track in seconds
#define OUTPUT_TRACKLOCATION @"outputTrackLocation"
//String describing the name of the current playlist
#define OUTPUT_PLAYLISTNAME @"outputPlaylistName"
//Describes the volume
#define OUTPUT_VOLUME @"outputVolume"
//Describes the BPM of the current track
#define OUTPUT_BPM @"outputBPM"
//the player’s position within the currently playing track in seconds.
#define OUTPUT_PLAYERPOSITION @"outputPlayerPosition"
//Sets the position of the player
#define INPUT_SETPLAYERPOSITION @"inputSetPlayerPosition"
//Sets the name of the track to play
#define INPUT_SETTRACKNAME @"inputSetTrackName"
//Yes if iTunes should play
#define INPUT_PLAYING @"inputPlaying"
//Pulse to play next track
#define INPUT_PLAYNEXTTRACK @"inputPlayNextTrack"
//Pulse to play previous track
#define INPUT_PLAYPREVIOUSTRACK @"inputPlayPreviousTrack"
//Sets the volume of the track. max = 100
#define INPUT_SETVOLUME @"inputSetVolume"
//The number of seconds that should elapse before causing an update of iTunes info
#define INPUT_UPDATEINTERVAL @"inputUpdateInterval"
//Should automatically update or should update on request
#define INPUT_UPDATEUSINGINTERVAL @"inputUpdateUsingInterval"
//causes an update of iTunes info
#define INPUT_FORCEUPDATE @"inputForceUpdate"

#define OUTPUT_AVAILABLEPLAYLISTS @"outputAvailablePlaylists"
#define OUTPUT_TRACKURLATINDEX @"outputTrackURLAtIndex"
#define INPUT_PLAYLISTINDEX @"inputPlaylistIndex"
#define INPUT_SONGINDEX @"inputSongIndex"

#define OUTPUT_PLAYLISTATINDEXTRACKCOUNT @"outputPlaylistAtIndexTrackCount"
#define OUTPUT_TRACKNAMEATINDEX @"outputTrackNameAtIndex"
#define OUTPUT_ARTWORKATINDEX @"outputArtworkAtIndex"
#define INPUT_MAXARTWORKPREVIEWIMAGES @"inputMaxPreviewImages"
#define OUTPUT_PREVIEWARTWORK @"outputPreviewArtwork"

@property (assign) NSUInteger inputMaxPreviewImages;

//Port Properties
@property (assign) id<QCPlugInOutputImageProvider> outputTrackImage;

@property (assign) NSDictionary *outputPreviewArtwork;

// playlist . song index info
@property (assign) NSUInteger inputPlaylistIndex;
@property (assign) NSUInteger inputSongIndex;
@property (assign) NSUInteger outputPlaylistAtIndexTrackCount;
@property (assign) NSString *outputTrackNameAtIndex;
@property (assign) NSString *outputTrackURLAtIndex;
//@property (assign) NSDictionary *outputTrackDictionaryAtIndex;
@property (assign) id<QCPlugInOutputImageProvider> outputArtworkAtIndex;
//

@property (assign) NSString* outputTrackURL;
@property (assign) NSString* outputArtist;

@property (assign) BOOL outputPlaying;
@property (assign) NSString* outputCurrentTrack;
@property (assign) double outputTrackDuration;
@property (assign) NSUInteger outputTrackRating;
@property (assign) NSString* outputPlaylistName;
@property (assign) NSUInteger outputVolume;
@property (assign) NSUInteger outputBPM;
@property (assign) double outputPlayerPosition;
@property (assign) double inputSetPlayerPosition;
@property (assign) NSString* inputSetTrackName;
@property (assign) BOOL inputPlaying;
@property (assign) BOOL inputPlayNextTrack;
@property (assign) BOOL inputPlayPreviousTrack;
@property (assign) NSUInteger inputSetVolume;
@property (assign) double inputUpdateInterval;
@property (assign) BOOL inputUpdateUsingInterval;
@property (assign) BOOL inputForceUpdate;

@property (assign) NSDictionary *outputAvailablePlaylists;

@end
