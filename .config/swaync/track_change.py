#!/usr/bin/env python3

import gi
gi.require_version('Playerctl', '2.0')
from gi.repository import Playerctl, GLib
import subprocess
import urllib.request
import tempfile

_art_cache = {}

def get_art_path(url):
    if not url:
        return None
    if url in _art_cache:
        return _art_cache[url]
    try:
        tmp = tempfile.NamedTemporaryFile(suffix='.jpg', delete=False)
        urllib.request.urlretrieve(url, tmp.name)
        _art_cache[url] = tmp.name
        return tmp.name
    except Exception:
        return None

def on_track_change(player, metadata):
    artist = player.get_artist() or 'Unknown Artist'
    title  = player.get_title()  or 'Unknown Title'
    album  = player.get_album()  or ''

    art_url  = metadata['mpris:artUrl'] if 'mpris:artUrl' in metadata.keys() else None
    art_path = get_art_path(art_url)

    body = f'{artist}\n{album}' if album else artist
    cmd  = ['notify-send', '--app-name=Spotify', title, body]
    if art_path:
        cmd += ['--icon', art_path]

    subprocess.Popen(cmd)

def on_player_appeared(manager, player):
    if player.props.player_name == 'spotify':
        player.connect('metadata', on_track_change)

def on_player_vanished(manager, player):
    print(f"Player vanished: {player.props.player_name}")

manager = Playerctl.PlayerManager()
manager.connect('player-appeared', on_player_appeared)
manager.connect('player-vanished', on_player_vanished)

for name in manager.props.player_names:
    print(f"Found existing player: {name.name}")
    player = Playerctl.Player.new_from_name(name)
    manager.manage_player(player)

GLib.MainLoop().run()
