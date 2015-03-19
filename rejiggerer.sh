#!/bin/bash

@() {
	echo ">" "$*"
	"$@"
}

set -u
set -e

if [[ "${1:-}" == "--help" ]]; then
	echo "Usage : $0 <filename>"
	echo "Will forcibly rejigger that image."
	exit 0
fi

if [[ -z "${1:-}" || ! -f "${1:-}" ]]; then
	echo "You need to pass an image to rejigger."
	echo
	"$0" "--help"
	exit 1
fi

INPUT="$1"
TEMP_IMAGE="${INPUT}_temp.png"

# THIS MIGHT NOT WORK 100%.
# THIS WILL BE ENOUGH FOR PROTOTYPES.

# We will need a more proper script, simply copying over the opacity
# of the other image does not seem to work.
#
# We should instead layer the jiggered image under, at 1% opacity max,
# Then layer the original over.
#
# Still, this is way better than what we had.

# In order : 
#   - "jigger" the image. Get a copy of everything moved around in 
#     all directions. Corners first, then the sides.
#     ( first parenthesis )
#   - Uses that generated image and compose by copying opacity of the
#     "second image", which is also the input.
#

@ convert \
	\(  \
		"$INPUT" \
		-draw "image over -1,-1 0,0 '$INPUT'" \
		-draw "image over   1,1 0,0 '$INPUT'" \
		-draw "image over  -1,1 0,0 '$INPUT'" \
		-draw "image over  1,-1 0,0 '$INPUT'" \
		-draw "image over   1,0 0,0 '$INPUT'" \
		-draw "image over   0,1 0,0 '$INPUT'" \
		-draw "image over  -1,0 0,0 '$INPUT'" \
		-draw "image over  0,-1 0,0 '$INPUT'" \
	\)  \
	"$INPUT"                   \
	 -compose over             \
	 -compose copy_opacity     \
	 -composite                \
	"$INPUT"


# Check this later.
## Then, set the opacity WAY down.
#@ convert \
#	"$INPUT" -channel a -evaluate min 1% \
#	out.png


# Documentation :
#  - ImageMagick and image asides.
#    https://stackoverflow.com/questions/26408022/imagemagick-color-to-alpha-like-the-gimp

