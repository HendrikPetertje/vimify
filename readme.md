## About

![Vimify](https://raw.githubusercontent.com/HendrikPetertje/vimify/master/example.png)

[vimify](https://github.com/Hendrikpetertje/vimify) is a plugin for [Vim](https://github.com/vim/vim) 
origionally inspired by [MuAnsari96](https://github.com/MuAnsari96/vimify).
It provides a simple Spotify integration within Vim to search and play music on
OSX and Linux. This version of vimify uses AppleScript to talk with spotify on
Mac and Dbus on linux. If you managed to open vim and load this plugin, your
system will have the right one installed.

Just make sure you have Spotify installed somewhere and the plugin should work.
You will need to have built vim with Python3 support or load python3 in neovim
for this plugin to work.

Big thanks to [Mattpenney89](https://github.com/mattpenney89) for writing the
linux bits and updating the scripts to python 3

For the search functions you will need to follow the new instructions in the setup
part of this readme. Linux support trough Dbus / some code cleaning is underway,
as well as looking for albums and artist.

## Features and Usage
vimify is designed to interface with a running desktop instance of Spotify. Currently, the following features are supported:

* `:SpPlay` will play the current track
* `:SpPause` will pause the current track
* `:SpPrevious` will move to the previous track
* `:SpNext` will move to the next track
* `:Spotify` or `:SpToggle` will toggle play/pause
* `:SpSearch <query>` will search spotify for 'query' and return the results in a new buffer. While working in the Vimify buffer, the name, artist and album of all pertinent tracks will be displayed. Vimify's behavior in this buffer is described as follows::
    * `<Enter>`: If the cursor is over the name of the track, Spotify will begin playback of that track
    * `<Enter>`: If the cursor is over the name of the artist, Spotify will begin playback of all songs by artist, starting with popular
    * `<Enter>`: If the cursor is over the name of the album, Spotify will begin playback of the entire album
    * `<Space>`: Is bound to `:SpToggle` when working in the Vimify buffer
* `:SpPlaylists` will fetch a list of your playlists and return the results in a new buffer
    * `<Enter>`: If the cursor is over the name of the playlist, Spotify will begin playback of that playlist

## Installation
#### Pathogen
The preferred way to install vimify is to use [pathogen](https://github.com/tpope/vim-pathogen). With pathogen installed, simply run
```bash
cd ~/.vim/bundle
git clone https://github.com/HendrikPetertje/vimify
```

#### Vim Plug
[vim-plug](https://github.com/junegunn/vim-plug):

`Plug 'HendrikPetertje/vimify'`

### Authorization
This plugin uses Spotify 'Authorization Code Flow' tokens which allow you
access your private data such as private playlists via Vimify.

Currently Vimify requires that you manually generate a 'refresh token' as part of
the installation process. This token is then used to automatically generate
access tokens when they are needed.

#### Register Spotify API Client
The Spotify API client gives you auth credentials (client id + secret) needed to generate tokens.

##### Setup Steps
1. Register a Spotify API client via [Spotify Developer Dashboard](https://developer.spotify.com/dashboard/applications)

2. Edit the settings for the client and add `http://localhost:4815/callback` to the list of Redirect URIs.

3. Grab the Client Id and Client Secret of your brand new Spotify API client

#### Generate Refresh Token
1. Install [spotify-auth-code-flow](https://www.npmjs.com/package/spotify-auth-code-flow-cli)

`npm install -g spotify-auth-code-flow-cli`

2. Generate tokens using the client id and client secret from your Spotify API client
```
$ spotify-tokens --clientId "your-client-id" --clientSecret "your-client-secret"
```

#### Save Tokens
1. Create the following file and save at `~/.config/vimify/vimify_config.json`:

```json
{
  "tokens": {
    "refresh_token": "your-refresh-token"
  }
}
```

2. Save client auth token from `spotify_tokens` output to your `.vimrc`/`init.vim`

```
let g:spotify_token='your-client-auth-token'
```

##### Encrypting Credentials on Mac
Tip: If you're on Mac and want to avoid saving credentials in plaintext config
files you can save them to your keychain, then assign them to environment
variables when your shell is loaded:

###### Saving Token to Keychain
(Use lowercase name to avoid issues with `find-generic-password` not finding it)

`security add-generic-password -a "$USER" -s 'spotify-client-token' -w 'CLIENTAUTHTOKEN'`

###### Assigning Keychain contents to Env Var at Login
To assign to environment variable, add this to your `.zshrc`/`.bashrc`/`.bash_profile`:

`export VIMIFY_SPOTIFY_TOKEN=$(security find-generic-password -s 'spotify-client-token' -w)`

###### Assigning env var to vimify variable

```
let g:spotify_token=$VIMIFY_SPOTIFY_TOKEN
```

And you'll be good to go! Once help tags are generated, you can just run `:help vimify` in vim to see the manual.

## Roadmap
- Clean up the code and break things apart to their own sections / files
- Instead of making a file that opens as an interface, 
  push the whole thing to `:copen` (need to dig in some literature for that).
- Make a setup interface that helps new users create a `Authorisation: Basic`
  token without having to read this readme or visiting shady encoding sites.
- Your ideas and wishes.
