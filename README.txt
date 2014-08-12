# Brief
	
	There are two added inputs to this patch, `Playlist Index` and `Song Index`.  These are used to get information about the iTunesTrack stored at these locations.  You can find the playlist and song information by using the `All Playlists` output port, which provides a structure with all available playlists and their corresponding index value.  Ex output:
	
		NSDictionary<Playlist Name, Playlist Index>
		{
			[ "Library", "0" ],
			[ "My Playlist", "1" ],
			[ "Recently Played", "2" ]
		}

	So to get the file artwork for the third song in the "Library" playlist, simply use the member value of the "Library" entry to set the input port 'Playlist Index' and set input port 'Song Index' to 3.  Now all 'at index' output ports will correspond to these indices.

# Description of added ports:

## Input
	- Playlist Index
		Which playlist to use.  See also: output All Playlists

	- Song Index
		Which song to query.  See also: output Playlist at index track count

## Output
	- Playlist at index track count
		How many tracks are available in the currently indexed playlist.

	- Track name at index
		The track name at the provided playlist/song index.

	- Artwork at index
		The track artwork at the provided playlist/song index.

	- Track URL at index
		The file url for the song at provided playlist/song index.