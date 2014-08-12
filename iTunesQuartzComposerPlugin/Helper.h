//
//  Helper.h
//  iTunesQuartzComposerPlugin
//
//  Created by chris on 29/03/2013.
//  Copyright (c) 2013 Chris Birch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iTunes.h"
#import <Cocoa/Cocoa.h>

const static int kUpdateTrack = 1;
const static int kUpdateIndex = 2;
const static int kUpdateTrackAndIndex = 4;

@interface Helper : NSObject
{
	int _playlistIndex;
	int _songIndex;
    
    int _previousPlaylistIndex;
    int _previousSongIndex;
	
	// how many preview images to load up
	int _maxPreviewImages;

    //Holds the last track name so we know when to process the image
    NSString* _previousTrackName;

    NSImage *_trackImage;
    NSString *_trackURL;
    NSString *_artistName;
    NSString *_trackName;
	NSString *_currentTrackName;

    double _trackDuration;
    NSInteger _trackRating;
    NSInteger _playerPosition;
    NSString *_playlistName;
    NSInteger _volume;
    NSInteger _bpm;
    BOOL _playing;
    BOOL _isConnectedToiTunes;
    NSString *_trackNameAtIndex;
    NSImage *_artworkAtIndex;
    NSUInteger _playlistAtIndexTrackCount;
    NSString *_trackURLAtIndex;
    NSDictionary *_allPlaylists;
    NSDictionary *_artworkPreview;
    NSLock *memberLock;
}

@property(nonatomic,retain) NSString* previousTrackName;
@property(nonatomic,retain) NSImage* trackImage;
@property(nonatomic,retain) NSString* trackURL;
@property(nonatomic,retain) NSString* artistName;

@property(nonatomic,retain) NSString* trackName;
@property(nonatomic,retain) NSString* currentTrackName;
@property(nonatomic,assign) double trackDuration;
@property(nonatomic,assign) NSInteger trackRating;
@property(nonatomic,assign) NSInteger playerPosition;
@property(nonatomic,retain) NSString* playlistName;
@property(nonatomic,assign) NSInteger volume;
@property(nonatomic,assign) NSInteger bpm;

@property(nonatomic,assign) BOOL playing;
@property(nonatomic,assign) BOOL isConnectedToiTunes;

@property(nonatomic,retain) NSString *trackNameAtIndex;
@property(nonatomic,retain) NSImage *artworkAtIndex;
@property(nonatomic,assign) NSUInteger playlistAtIndexTrackCount;
@property(nonatomic,retain) NSString *trackURLAtIndex;
@property(nonatomic,retain) NSDictionary *allPlaylists;

@property(nonatomic,retain) NSDictionary *artworkPreview;

@property(atomic, retain) NSLock *memberLock;

#pragma mark -
#pragma mark Methods

/**
 * Attempts to connect to itunes
 */
-(BOOL)connectToiTunes;

/**
 * Plays the next track
 */
-(void)playNextTrack;


/**
 * Plays the previous track
 */
-(void)playPreviousTrack;

#pragma mark -
#pragma mark Query itunes

/**
 * Queries all values from iTunes and stores them locally.
 */
-(int)queryiTunes;
- (NSDictionary*) playlists:(iTunesSource*)library;

-(void)setPlaylistIndex:(int)playlist songIndex:(int)song;
-(void)setMaxPreviewImages:(int)maxPreviewImages;
+ (NSString*) getTrackURL:(iTunesTrack*)track;
+ (int*) clampArrayIndices:(int)startIndex withSize:(int)count arrayLength:(int)length;

-(void) sanityCheck;

@end