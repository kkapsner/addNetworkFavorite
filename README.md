# addNetworkFavorite
Adds a network share to Finder favorites list

First tries to mount the share and then tries to add the favorite.
If the share is already mounted the mount path is guessed.

# usage
```shell
ddNetworkFavorite SHARE_URL PATH_IN_SHARE (optional) DISPLAY_NAME
```

# examples
```shell
addnetworkFavorite smb://example.org/share ""
addnetworkFavorite smb://example.org/share "" "display name"
addnetworkFavorite smb://example.org/share folder/
addnetworkFavorite smb://example.org/share folder/ "display name"
```
