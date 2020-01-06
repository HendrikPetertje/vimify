" vimify.vim:     Spotify integration for vim!
" Maintainer:     Peter van der Meulen <http://github.com/hendrikpetertje>
" Original idea:  Mustafa Ansari <http://github.com/MuAnsari96>


" *************************************************************************** "
" ***************************    Initialization    ************************** "
" *************************************************************************** "

if exists('g:vimifyInited')
    finish
endif
let g:vimifyInited = 0

python3 << endpython
import subprocess
import os
import platform
import urllib.request, urllib.error, urllib.parse
import json
from os.path import expanduser

osSystem = platform.system()

IDs = []
ListedElements = []

def generate_access_token():
    import vim
    refresh_token = ''
    home = expanduser("~")

    with open(home + '/.config/vimify/vimify_config.json') as json_file:
        data = json.load(json_file)
        refresh_token = data['tokens']['refresh_token']

    auth_url = "https://accounts.spotify.com/api/token"
    auth_req = urllib.request.Request(auth_url,
      "grant_type=refresh_token&refresh_token={}".format(refresh_token).encode('ascii'),)
    auth_req.add_header('Authorization', "Basic {}".format(vim.eval("g:spotify_token")))
    auth_req.add_header('content-type', 'application/x-www-form-urlencoded')
    auth_resp = urllib.request.urlopen(auth_req)
    raw_data = auth_resp.read()
    access_token = json.loads(raw_data)["access_token"]
    return access_token

def populate_track(track, albumName=None, albumIDNumber=None):
    name = track["name"].replace("'", "")
    uri = track["uri"][14:]

    artist = track["artists"][0]["name"].replace("'", "")
    artistID = track["artists"][0]["id"]

    album, albumID = albumName, albumIDNumber
    if album is None or albumID is None:
        album = track["album"]["name"].replace("'", "")
        albumID = track["album"]["id"]

    info = {"track": name, "artist": artist, "album": album}
    ListedElements.append(info)

    info = {"uri": uri, "artistID": artistID, "albumID": albumID}
    IDs.append(info)

def populate_playlist(playlist):
    name = playlist["name"].replace("'", "")
    uri = playlist["uri"]

    info = {"track": name}
    ListedElements.append(info)

    info = {"uri": uri}
    IDs.append(info)

endpython

" *************************************************************************** "
" ***********************     Spotfy dbus wrappers     ********************** "
" *************************************************************************** "

function! s:Play()
python3 << endpython
if osSystem == 'Darwin':
  subprocess.call(['osascript',
                   '-e'
                   'tell app "Spotify" to play'],
                   stdout=open(os.devnull, 'wb'))
elif osSystem == 'Linux' or osSystem == "Linux2":
  subprocess.call(['dbus-send',
                   '--print-reply',
                   '--dest=org.mpris.MediaPlayer2.spotify',
                   '/org/mpris/MediaPlayer2',
                   'org.mpris.MediaPlayer2.Player.Play'],
                   stdout=open(os.devnull, 'wb'))
endpython
endfunction

function! s:Pause()
python3 << endpython
if osSystem == 'Darwin':
  subprocess.call(['osascript',
                   '-e'
                   'tell app "Spotify" to pause'],
                   stdout=open(os.devnull, 'wb'))
elif osSystem == 'Linux' or osSystem == "Linux2":
  subprocess.call(['dbus-send',
                   '--print-reply',
                   '--dest=org.mpris.MediaPlayer2.spotify',
                   '/org/mpris/MediaPlayer2',
                   'org.mpris.MediaPlayer2.Player.Pause'],
                   stdout=open(os.devnull, 'wb'))
endpython
endfunction

function! s:Toggle()
python3 << endpython
if osSystem == 'Darwin':
  subprocess.call(['osascript',
                   '-e'
                   'tell app "Spotify" to playpause'],
                   stdout=open(os.devnull, 'wb'))
elif osSystem == 'Linux' or osSystem == "Linux2":
  subprocess.call(['dbus-send',
                   '--print-reply',
                   '--dest=org.mpris.MediaPlayer2.spotify',
                   '/org/mpris/MediaPlayer2',
                   'org.mpris.MediaPlayer2.Player.PlayPause'],
                   stdout=open(os.devnull, 'wb'))
endpython
endfunction


function! s:Next()
python3 << endpython
if osSystem == 'Darwin':
  subprocess.call(['osascript',
                   '-e'
                   'tell app "Spotify" to next track'],
                   stdout=open(os.devnull, 'wb'))
elif osSystem == 'Linux' or osSystem == "Linux2":
  subprocess.call(['dbus-send',
                   '--print-reply',
                   '--dest=org.mpris.MediaPlayer2.spotify',
                   '/org/mpris/MediaPlayer2',
                   'org.mpris.MediaPlayer2.Player.Next'],
                   stdout=open(os.devnull, 'wb'))
endpython
endfunction

function! s:Previous()
python3 << endpython
if osSystem == 'Darwin':
  subprocess.call(['osascript',
                   '-e'
                   'tell app "Spotify" to previous track'],
                   stdout=open(os.devnull, 'wb'))
elif osSystem == 'Linux' or osSystem == "Linux2":
  subprocess.call(['dbus-send',
                   '--print-reply',
                   '--dest=org.mpris.MediaPlayer2.spotify',
                   '/org/mpris/MediaPlayer2',
                   'org.mpris.MediaPlayer2.Player.Previous'],
                   stdout=open(os.devnull, 'wb'))
endpython
endfunction

function! s:LoadTrack(track)
call s:Pause()
python3 << endpython
import vim
if osSystem == 'Darwin':
  subprocess.call(['osascript',
                   '-e'
                   'tell app "spotify" to play track "spotify:track:'+vim.eval("a:track")+'"'],
                   stdout=open(os.devnull, 'wb'))
elif osSystem == 'Linux' or osSystem == "Linux2":
  subprocess.call(['dbus-send',
                   '--print-reply',
                   '--dest=org.mpris.MediaPlayer2.spotify',
                   '/org/mpris/MediaPlayer2',
                   'org.mpris.MediaPlayer2.Player.OpenUri',
                   'string:spotify:track:'+vim.eval("a:track")],
                   stdout=open(os.devnull, 'wb'))
endpython
endfunction

function! s:LoadAlbum(album)
call s:Pause()
python3 << endpython
import vim
if osSystem == 'Darwin':
  subprocess.call(['osascript',
                   '-e'
                   'tell app "spotify" to play track "spotify:album:'+vim.eval("a:album")+'"'],
                   stdout=open(os.devnull, 'wb'))
elif osSystem == 'Linux' or osSystem == "Linux2":
  subprocess.call(['dbus-send',
                   '--print-reply',
                   '--dest=org.mpris.MediaPlayer2.spotify',
                   '/org/mpris/MediaPlayer2',
                   'org.mpris.MediaPlayer2.Player.OpenUri',
                   'string:spotify:album:'+vim.eval("a:album")],
                   stdout=open(os.devnull, 'wb'))
endpython
endfunction

function! s:LoadArtist(artist)
call s:Pause()
python3 << endpython
import vim
if osSystem == 'Darwin':
  subprocess.call(['osascript',
                   '-e'
                   'tell app "spotify" to play track "spotify:artist:'+vim.eval("a:artist")+'"'],
                   stdout=open(os.devnull, 'wb'))
elif osSystem == 'Linux' or osSystem == "Linux2":
  subprocess.call(['dbus-send',
                   '--print-reply',
                   '--dest=org.mpris.MediaPlayer2.spotify',
                   '/org/mpris/MediaPlayer2',
                   'org.mpris.MediaPlayer2.Player.OpenUri',
                   'string:spotify:artist:'+vim.eval("a:artist")],
                   stdout=open(os.devnull, 'wb'))
endpython
endfunction

function! s:LoadPlaylist(uri)
call s:Pause()
python3 << endpython
import vim
if osSystem == 'Darwin':
  subprocess.call(['osascript',
                   '-e'
                   'tell app "spotify" to play track "'+vim.eval("a:uri")+'"'],
                   stdout=open(os.devnull, 'wb'))
elif osSystem == 'Linux' or osSystem == "Linux2":
  subprocess.call(['dbus-send',
                   '--print-reply',
                   '--dest=org.mpris.MediaPlayer2.spotify',
                   '/org/mpris/MediaPlayer2',
                   'org.mpris.MediaPlayer2.Player.OpenUri',
                   'string:'+vim.eval("a:uri")],
                   stdout=open(os.devnull, 'wb'))
endpython
endfunction

" *************************************************************************** "
" ***********************      SpotfyAPI wrappers      ********************** "
" *************************************************************************** "

function! s:SearchTrack(query)
python3 << endpython
import vim

search_query = vim.eval("a:query").replace(' ', '+')
url = "https://api.spotify.com/v1/search?q={}&type=track".format(search_query)
req = urllib.request.Request(url,)
req.add_header('Authorization', "Bearer {}".format(generate_access_token()))
resp = urllib.request.urlopen(req)
j = json.loads(resp.read())["tracks"]["items"]
if len(j) is not 0:
  IDs = []
  ListedElements = []
  for track in j[:min(20, len(j))]:
    populate_track(track)
    vim.command('call s:VimifySearchBuffer(a:query, "Search")')
else:
    vim.command("echo 'No tracks found'")
endpython
endfunction

function! s:ListPlaylists()
python3 << endpython
import vim

url = "https://api.spotify.com/v1/me/playlists?limit=50"
req = urllib.request.Request(url,)
req.add_header('Authorization', "Bearer {}".format(generate_access_token()))
resp = urllib.request.urlopen(req)
j = json.loads(resp.read())["items"]
if len(j) is not 0:
  IDs = []
  ListedElements = []
  for playlist in j[:min(20, len(j))]:
    populate_playlist(playlist)
    vim.command('call s:VimifyPlaylistBuffer()')
else:
    vim.command("echo 'No playlists found'")
endpython
endfunction

" *************************************************************************** "
" ***************************      Interface       ************************** "
" *************************************************************************** "
function! s:VimifyPlaylistBuffer()
    if buflisted('Vimify')
        bd Vimify
    endif
    below new Vimify
    call append(0, 'Spotify Playlists:')
    call append(line('$'), "--------------------------------------------------
                           \------------------------------------------------")

python3 << endpython
import vim
for element in ListedElements:
    row = "{:<45}              ".format(element["track"][:45])
    vim.command('call append(line("$"), \'{}\')'.format(row))
endpython
    resize 14
    normal! gg
    5
    setlocal nonumber
    setlocal nowrap
    setlocal buftype=nofile
    map <buffer> <Enter> <esc>:SpSelectPlaylist<CR>
    map <buffer> <Space> <esc>:SpToggle<CR>

endfunction

function! s:VimifySearchBuffer(query, type)
    if buflisted('Vimify')
        bd Vimify
    endif
    below new Vimify
    call append(0, 'Spotify ' . a:type . ' Results For: ' . a:query)
    call append(line('$'), "Song                                           Artist                Album")
    call append(line('$'), "--------------------------------------------------
                           \------------------------------------------------")

python3 << endpython
import vim
for element in ListedElements:
    row = "{:<45}  {:<20}  {:<}".format(element["track"][:45], element["artist"][:20], element["album"])
    vim.command('call append(line("$"), \'{}\')'.format(row))
endpython
    resize 14
    normal! gg
    5
    setlocal nonumber
    setlocal nowrap
    setlocal buftype=nofile
    map <buffer> <Enter> <esc>:SpSelect<CR>
    map <buffer> <Space> <esc>:SpToggle<CR>

endfunction

function! s:SelectSong()
   let l:row = getpos('.')[1]-5
   let l:col = getpos('.')[2]
python3 << endpython
import vim
row = int(vim.eval("l:row"))
col = int(vim.eval("l:col"))
if row >= 0:
    if col < 48:
        uri = str(IDs[row]["uri"])
        vim.command('call s:LoadTrack("{}")'.format(uri))
        vim.command("echo 'Playing Track'")
    elif col < 70:
        artistID = str(IDs[row]["artistID"])
        artist = str(ListedElements[row]["artist"])
        vim.command('call s:LoadArtist("{}")'.format(artistID))
        vim.command("echo 'Playing Artist'")
    else:
        albumID = str(IDs[row]["albumID"])
        album = str(ListedElements[row]["album"])
        vim.command('call s:LoadAlbum("{}")'.format(albumID))
        vim.command("echo 'Playing Album'")
endpython
endfunction

function! s:SelectPlaylist()
   let l:row = getpos('.')[1]-5
   let l:col = getpos('.')[2]
python3 << endpython
import vim
row = int(vim.eval("l:row"))
uri = str(IDs[row]["uri"])
vim.command('call s:LoadPlaylist("{}")'.format(uri))
vim.command("echo 'Playing Playlist'")
endpython
endfunction
" *************************************************************************** "
" ***************************   Command Bindngs   *************************** "
" *************************************************************************** "
command!            Spotify          call s:Toggle()
command!            SpToggle         call s:Toggle()
command!            SpPause          call s:Pause()
command!            SpPlay           call s:Play()
command!            SpNext           call s:Next()
command!            SpPrevious       call s:Previous()
command!            SpSelect         call s:SelectSong()
command!            SpSelectPlaylist call s:SelectPlaylist()
command!            SpPlaylists      call s:ListPlaylists()
command! -nargs=1   SpSearch         call s:SearchTrack(<f-args>)
