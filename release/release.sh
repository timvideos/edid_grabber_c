#!/bin/bash


# Check if it's running in Travis and under required circumstances
if [ $TRAVIS != "true" ]
    then
        echo "This script should be run by travis-ci.org only."
        exit 0
fi

if [ $TRAVIS_REPO_SLUG != "timvideos/edid_grabber_c" ]
    then
        echo "This script runs only for timvideos/edid_grabber_c"
        exit 0
fi

if [ $TRAVIS_SECURE_ENV_VARS != "true" ]
    then
        echo "This script requires API key set in secure environment variables."
        exit 0
fi

if [ $TRAVIS_PULL_REQUEST != "false" ]
    then
        echo "This script does not run for pull requests."
        exit 0
fi

if [ $TRAVIS_BRANCH != "master" ]
    then
        echo "This script runs only for master branch."
        exit 0
fi

if [ -o $EDID_GRABBER_UPLOAD_API_KEY ]
    then
        echo "EDID API key should be set in EDID_GRABBER_UPLOAD_API_KEY"
        exit 0
fi

if [ -o $PLATFORM ]
    then
        echo "Build platform should be set in PLATFORM"
        exit 0
fi


# Create package based on platform
if [ $PLATFORM == "linux" ]
    then
        echo "Packing release for Linux."

        RELEASE_FILE="edid-grabber-$PLATFORM-${TRAVIS_COMMIT:0:7}.tar.gz"
        tar -czf $RELEASE_FILE -C bin edid-grabber -C ../release README

        echo "Packed new release for Linux: $RELEASE_FILE"
        echo ""
else [ $PLATFORM == "windows" ]
        echo "Packing release for Windows."

        RELEASE_FILE="edid-grabber-$PLATFORM-${TRAVIS_COMMIT:0:7}.zip"
        zip -qj $RELEASE_FILE bin/edid-grabber.exe release/README.txt

        echo "Packed new release for Windows: $RELEASE_FILE"
        echo ""
fi


# Upload release to EDID.tv
echo "Upload release EDID.tv"
curl -F "platform=$PLATFORM" -F "commit=$TRAVIS_COMMIT" -F "api_key=$EDID_GRABBER_UPLOAD_API_KEY" -F "release_file=@$RELEASE_FILE" http://edid.tv/api/grabber/upload/
echo ""
echo "Release uploaded to EDID.tv"
