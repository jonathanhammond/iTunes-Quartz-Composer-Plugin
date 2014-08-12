//  Helper.m
//  iTunesQuartzComposerPlugin
//
//  Created by chris on 29/03/2013.
//  Copyright (c) 2013 Chris Birch. All rights reserved.
//

#import "Helper.h"
#import "iTunes.h"

#define PROFILE_TIMES 0

#if PROFILE_TIMES || DEBUG
#define logv(txt,...) NSLog( (@"line: %d ->" txt), __LINE__, ##__VA_ARGS__ );
#endif


@implementation Helper
@synthesize previousTrackName=_previousTrackName;
@synthesize trackImage=_trackImage;
@synthesize trackName=_trackName;

@synthesize trackDuration=_trackDuration;
@synthesize artistName=_artistName;
@synthesize trackURL = _trackURL;
@synthesize trackRating=_trackRating;
@synthesize playerPosition=_playerPosition;
@synthesize playlistName=_playlistName;
@synthesize volume=_volume;
@synthesize bpm=_bpm;
@synthesize currentTrackName = _currentTrackName;

@synthesize playing=_playing;
@synthesize isConnectedToiTunes=_isConnectedToiTunes;

@synthesize allPlaylists = _allPlaylists;
@synthesize playlistAtIndexTrackCount = _playlistAtIndexTrackCount;
@synthesize trackNameAtIndex = _trackNameAtIndex;
@synthesize trackURLAtIndex = _trackURLAtIndex;
@synthesize artworkAtIndex = _artworkAtIndex;
@synthesize artworkPreview = _artworkPreview;

@synthesize memberLock;

static __strong iTunesApplication *iTunesApp;

-(id)init
{
    if (self = [super init])
    {
        self.trackName = @"";
        self.playlistName = @"";
        self.previousTrackName = @"";
        self.trackNameAtIndex = @"";
        self.trackURLAtIndex = @"";
        
        // set playlist and song index values to -1 so that the plugin will force update
        // preview artwork
        _previousPlaylistIndex = 42;
        _previousSongIndex = 24;
        _songIndex = -1;
        _playlistIndex = -1;
		
		memberLock = [[NSLock alloc] init];
	}
    
	return self;
}

-(BOOL)isConnectedToiTunes
{
    return iTunesApp != nil;
}

-(iTunesSource*)iTunesLibrary
{
    [self connectToiTunes];
    if (iTunesApp)
    {
        NSArray *iTunesSources = [[iTunesApp sources] get];
		
        iTunesSource *library;
        for (iTunesSource *thisSource in iTunesSources)
        {
            if ([thisSource kind] == iTunesESrcLibrary)
            {
                library = thisSource;
                return library;
            }
        }
    }
    
    return nil;
}


#pragma mark -
#pragma mark Query itunes


-(int)queryiTunes
{
#if PROFILE_TIMES
	double t = CFAbsoluteTimeGetCurrent();
#endif
	
	NSImage* trackImage_temp = nil;
	NSString* trackURL_temp = @"";
	NSString* artistName_temp = @"";
	NSString* trackName_temp = @"";
	double trackDuration_temp = 0;
	NSInteger trackRating_temp = 0;
	NSInteger playerPosition_temp = 0;
	NSString* playlistName_temp = @"";
	NSInteger bpm_temp = 0;
	BOOL playing_temp = false;
//	BOOL isConnectedToiTunes_temp = false;
	NSString *trackNameAtIndex_temp = @"";
	NSImage *artworkAtIndex_temp = nil;
	NSUInteger playlistAtIndexTrackCount_temp = 0;
	NSString *trackURLAtIndex_temp = @"";
	NSDictionary *allPlaylists_temp = nil;
	NSMutableDictionary *artworkPreview_temp = nil;
	
	int changed = 0;
    if([self connectToiTunes])
    {
#if PROFILE_TIMES
		double n = CFAbsoluteTimeGetCurrent();
#endif
		iTunesSource *library;
		
		[memberLock lock];
        
        //get current track and playlist
        iTunesTrack* track = [[iTunesApp currentTrack] get];
        iTunesPlaylist* playlist = [[iTunesApp currentPlaylist] get];   // forcibly grab the itunes data, preventing lazy evaluation
        library = [self iTunesLibrary];
		playerPosition_temp = iTunesApp.playerPosition;
        playing_temp = iTunesApp.playerState == iTunesEPlSPlaying;
        
        //FinallY! this is the magic that makes this file track business work!
        //thankyou: http://www.cocoabuilder.com/archive/cocoa/200195-problems-with-scriptingbridge-and-itunes.html
        id track__ = (iTunesFileTrack*)[track get];

        [memberLock unlock];
        
#if PROFILE_TIMES
		logv(@"get itunes info took: %f", CFAbsoluteTimeGetCurrent()-n);
		n = CFAbsoluteTimeGetCurrent();
#endif
		
        NSString* className = [track__ className];
        if ([className isEqualToString:@"ITunesFileTrack"])
        {
            iTunesFileTrack* fileTrack = (iTunesFileTrack*)track__;
            
			trackURL_temp = fileTrack.location.absoluteString;
        }
        else if ([className isEqualToString:@"iTunesURLTrack"])
        {
            iTunesURLTrack* urlTrack = (iTunesURLTrack*)track__;
            trackURL_temp = urlTrack.address;
        }
        else
            trackURL_temp = @"Unknown";
        
#if PROFILE_TIMES
		logv(@"get trackURL : %f", CFAbsoluteTimeGetCurrent()-n);
#endif
		
        //Trackname
        if (track.name)
        {
            trackName_temp = track.name;
        }
        else
            trackName_temp = @"";
#if PROFILE_TIMES
		n = CFAbsoluteTimeGetCurrent();
#endif
        
        if (![self.previousTrackName isEqualToString:trackName_temp])
        {
            //Track has changed so we need to process the artwork again
            
            NSArray* artworks = [track.artworks get];
            
            if (artworks != nil)
            {
                //Try and get the artwork
                iTunesArtwork* artwork =  [artworks lastObject];
                //NSImage* image = artwork.data;
                
                trackImage_temp = [[NSImage alloc] initWithData:[artwork rawData]];
				if([artwork rawData] == nil || self.trackImage == nil)
					NSLog(@"track image is nil in Helper");
				
                //[[image TIFFRepresentation] writeToFile:@"/Users/chris/helloa.tiff" atomically:YES];
                //NSLog(@"%@",image);
                
				changed |= kUpdateTrack;
            }
			
        }
#if PROFILE_TIMES
		logv(@"get current track art: %f", CFAbsoluteTimeGetCurrent()-n);
#endif
        
        self.previousTrackName = trackName_temp;
        
        if (playlist && playlist.name)
            playlistName_temp = playlist.name;
        else
            playlistName_temp = @"";
        
        //track duration
        trackDuration_temp = track.duration;
        
        //track rating
        trackRating_temp = track.rating;
        
        artistName_temp = track.artist;
        
        allPlaylists_temp = [self playlists:library];
	
        bpm_temp = track.bpm;
#if PROFILE_TIMES
		double y = CFAbsoluteTimeGetCurrent();
#endif
		
        SBElementArray *libraryPlaylists = [library playlists];
        iTunesLibraryPlaylist *lib = [libraryPlaylists objectAtIndex:_playlistIndex];
        iTunesTrack* indexTrack = [[lib tracks] objectAtIndex:_songIndex];
        
        playlistAtIndexTrackCount_temp = [[lib tracks] count];
        trackURLAtIndex_temp  = [Helper getTrackURL:indexTrack];
        trackNameAtIndex_temp = [indexTrack name];

#if PROFILE_TIMES
		logv(@"get tracks : %f", CFAbsoluteTimeGetCurrent()-y);
		
		double u = CFAbsoluteTimeGetCurrent();
#endif

		// only update preview images when necessary
        if(_previousPlaylistIndex != _playlistIndex || _previousSongIndex != _songIndex)
        {
            iTunesArtwork *artwork = [[indexTrack artworks] lastObject];
            artworkAtIndex_temp = [[NSImage alloc] initWithData:[artwork rawData]];
            
            if(playlistAtIndexTrackCount_temp > 0)
            {
                int artworkPreviewCount = (_maxPreviewImages > playlistAtIndexTrackCount_temp) ? (int)playlistAtIndexTrackCount_temp : _maxPreviewImages;
				int middleIndex = _songIndex - (artworkPreviewCount/2);	// have preview tracks ready to go in either forward or backwards direction
                int *artworkPreviewIndices = [Helper clampArrayIndices:middleIndex withSize:artworkPreviewCount arrayLength:(int)playlistAtIndexTrackCount_temp];
                
                artworkPreview_temp = [[NSMutableDictionary alloc] initWithCapacity:artworkPreviewCount];

                for(int i = 0; i < artworkPreviewCount; i++)
                {
                    iTunesTrack *tr = [[lib tracks] objectAtIndex:artworkPreviewIndices[i]];
                    iTunesArtwork *art = [[tr artworks] lastObject];
                    NSImage *timg = [[NSImage alloc] initWithData:[art rawData]];
                    long index =  [tr index];
                    if(timg != nil)
                        [artworkPreview_temp setObject:timg forKey: [NSString stringWithFormat:@"%ld",index]];
                }
            }
            
            _previousSongIndex = _songIndex;
            _previousPlaylistIndex = _playlistIndex;
            
            changed |= kUpdateIndex;
        }
#if PROFILE_TIMES
		logv(@"populate preview art: %f", CFAbsoluteTimeGetCurrent()-u);
#endif
    
	}
    else
    {
        NSLog(@"Unable to connect to iTunes");
        _previousPlaylistIndex = _playlistIndex + 23;
        _previousSongIndex = _songIndex + 32 ;
		changed = kUpdateTrack | kUpdateTrackAndIndex;
    }
	
#if PROFILE_TIMES
	double y = CFAbsoluteTimeGetCurrent();
#endif
	[memberLock lock];
	
	self.trackImage = trackImage_temp;
	self.trackURL = trackURL_temp;
	self.artistName = artistName_temp;
	self.currentTrackName = trackName_temp;
	self.trackDuration = trackDuration_temp;
	_trackRating = trackRating_temp;
	_playerPosition = playerPosition_temp;
	self.playlistName = playlistName_temp;
	self.bpm = bpm_temp;
	_playing = playing_temp;
	self.trackNameAtIndex = trackNameAtIndex_temp == nil ? @"" : trackNameAtIndex_temp;
	self.artworkAtIndex = artworkAtIndex_temp;
	self.playlistAtIndexTrackCount = playlistAtIndexTrackCount_temp;
	self.trackURLAtIndex = trackURLAtIndex_temp;
	self.allPlaylists = allPlaylists_temp;
	self.artworkPreview = artworkPreview_temp;
	
    [memberLock unlock];
	
#if PROFILE_TIMES
	logv(@"assign local members : %f", CFAbsoluteTimeGetCurrent()-y);
	logv(@"query itunes total : %f seconds", CFAbsoluteTimeGetCurrent() - t);
#endif
	
	return changed;
}

#pragma mark PLAYLIST

+ (int*) clampArrayIndices:(int)startIndex withSize:(int)count arrayLength:(int)length
{
	int *indices = malloc(sizeof(int)*count);
	for(int i = 0; i < count; i++)
	{
		int n = startIndex+i;
		indices[i] = (n >= length) ? (n % length) : n;
	}
	return indices;
}

- (NSDictionary*) playlists:(iTunesSource*)library
{
	NSArray *libraryPlaylists = [library playlists];
	
	NSMutableDictionary *playlists = [[NSMutableDictionary alloc] initWithCapacity: [libraryPlaylists count]];
	
#if PROFILE_TIMES
	double time = CFAbsoluteTimeGetCurrent();
#endif
	
	for(iTunesPlaylist *lib in libraryPlaylists)
	{
		// subtract 1 because the index is assuming you're calling objectAtIndex for some list that isn't available to us and includes
		// some other playlist.  phew.  that took way too long to figure out.
		[playlists setObject:[NSNumber numberWithLong:[lib index]-1] forKey:[lib name]];
	}
	
#if PROFILE_TIMES
	NSLog(@"playlist population took: %f", CFAbsoluteTimeGetCurrent()-time);
#endif
	
	return playlists;
}

+ (NSString*) getTrackURL:(iTunesTrack*)track
{
	id track__ = (iTunesFileTrack*)[track get];
	NSString *_trackurl;
	NSString* className = [track__ className];
	
	if ([className isEqualToString:@"ITunesFileTrack"])
	{
		iTunesFileTrack* fileTrack = (iTunesFileTrack*)track__;
		
		_trackurl = fileTrack.location.absoluteString;
		
	}
	else if ([className isEqualToString:@"iTunesURLTrack"])
	{
		iTunesURLTrack* urlTrack = (iTunesURLTrack*)track__;
		_trackurl = urlTrack.address;
	}
	else
		_trackurl = @"Unknown";
	
	return _trackurl;
}

-(void)setMaxPreviewImages:(int)maxPreviewImages
{
	[memberLock lock];
	_maxPreviewImages = maxPreviewImages;
	[memberLock unlock];
}

-(void)setPlaylistIndex:(int)playlist songIndex:(int)song
{
	[memberLock lock];
	_playlistIndex = playlist;
	_songIndex = song;
	[memberLock unlock];
}

#pragma mark -
#pragma mark Set properties


-(void)setTrackName:(NSString *)trackName
{
    iTunesSource* library = [self iTunesLibrary];
    
    if (library)
    {
        SBElementArray *libraryPlaylists = [library libraryPlaylists];
        iTunesLibraryPlaylist *libraryPlaylist = [libraryPlaylists objectAtIndex:0];
        SBElementArray *musicTracks = [libraryPlaylist fileTracks];
        
        NSArray *tracksWithOurTitle = [musicTracks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"name", trackName]];
      
		// Remember, there might be several tracks with that title; you need to figure out how to find the one you want.
        iTunesTrack *rightTrack = [tracksWithOurTitle objectAtIndex:0];

		//play the file to select it in itunes
        [rightTrack playOnce:YES];

		// i'm not sure why setting the track name was stopping playback, but to re-enable that behavior uncomment this.
//        [memberLock lock];
//        self.playing = NO;
//        [memberLock unlock];
    }
}


-(void)setTrackRating:(NSInteger)trackRating
{
    [self connectToiTunes];
    if (iTunesApp)
    {
        iTunesTrack* track = iTunesApp.currentTrack;
        track.rating = trackRating;
        
    }
}


-(void)setPlayerPosition:(NSInteger)playerPosition
{
    [self connectToiTunes];
    if (iTunesApp)
    {
        iTunesApp.playerPosition = playerPosition;
    }
}

-(void)setVolume:(NSInteger)volume
{
    [self connectToiTunes];
    if (iTunesApp)
    {
        iTunesApp.soundVolume = volume;
    }
}


-(void)setPlaying:(BOOL)playing
{
    [self connectToiTunes];
    if (iTunesApp)
    {
        if (playing)
        {
            [iTunesApp playOnce:YES];
        }
        else
        {
            [iTunesApp pause];
        }
    }
}

#pragma mark -
#pragma mark Methods


-(BOOL)connectToiTunes
{
#if PROFILE_TIMES
	double u = CFAbsoluteTimeGetCurrent();
#endif
    iTunesApp = nil;
    iTunesApp = (iTunesApplication *)[SBApplication applicationWithBundleIdentifier: @"com.apple.iTunes"];
    
#if PROFILE_TIMES
	logv(@"connectToiTunes: %f", CFAbsoluteTimeGetCurrent()-u);
#endif
	
    if(iTunesApp == nil || ![iTunesApp isRunning])
        return NO;
    else
        return YES;
}

/**
 * Plays the next track
 */
-(void)playNextTrack
{
    [self connectToiTunes];
    if (iTunesApp)
    {
        [memberLock lock];
        [iTunesApp nextTrack];
        [memberLock unlock];
    }
}


/**
 * Plays the previous track
 */
-(void)playPreviousTrack
{
    [self connectToiTunes];
    if (iTunesApp)
    {
        [memberLock lock];
        [iTunesApp previousTrack];
        [memberLock unlock];
    }
}


-(void) sanityCheck
{
	NSLog(@"========== begin helper sanity check ==========");
	[memberLock lock];
    if( _trackURL == nil)
        NSLog(@"_trackURL == null");
    if( _artistName == nil)
        NSLog(@"_artistName == null");
	if( _currentTrackName == nil )
		NSLog(@"currentTrackName == nil");
    if( _playlistName == nil)
        NSLog(@"_playlistName == null");
    if( _trackNameAtIndex == nil)
        NSLog(@"_trackNameAtIndex == null");
    if( _trackURLAtIndex == nil)
        NSLog(@"_trackURLAtIndex == null");
    if( _allPlaylists == nil)
        NSLog(@"_allPlaylists == null");
	[memberLock unlock];

	NSLog(@"========== end helper sanity check ==========");
 }

@end
