# ffmpeg-lambda-build

This is a few build scripts that create a fairly feature-rich
dynamic build of ffmpeg intended to run in AWS Lambda.
The intended use of this is in combination with youtube-dl, so
it also produces binaries for ffprobe, mplayer, and rtmpdump as
those are dependencies for some plugins.

I've tested this on amzn-ami-hvm-2016.03.3.x86_64-gp2, and it
should be run on the current AWS Lambda AMI base, as
specified in the documentation:
http://docs.aws.amazon.com/lambda/latest/dg/current-supported-versions.html

You should run build.sh to retrieve and build all of the libraries,
then prepare.sh to generate a stripped-down bundle for use in Lambda.
The final output should be in ~/build/ffmpeg-lambda.zip.

