# iOS-FFmpeg-processor

<h3>About</h3>
Hudl's `iOS-FFmpeg-processor` project aims to provide a simple way to obtain a `AVCaptureVideoPreviewLayer`, and then from the devices camera and microphone, create 8 second `.ts` segments.
Using Kickflip's strategy of writing video only rolling 50MB `.mp4`s using `AVFoundation` and then passing the bytestream into FFmpeg for processing, while at the same time taking the bytestream from the microphone, adding ADTS headers, and then passing that into FFmpeg as well, muxing the 2 streams together.

<h3>How To Use</h3>

<h3>Resources Used in Development</h3>
<ul>
<li>https://github.com/kewlbear/FFmpeg-iOS-build-script</li>
<li>https://github.com/FFmpeg/FFmpeg</li>
<li>https://github.com/Kickflip/kickflip-ios-sdk</li>
<li>https://github.com/chrisballinger/FFmpeg-iOS</li>
<li>https://github.com/OpenWatch/FFmpegWrapper</li>
</ul>
Huge thanks to all the repos above. Probably couldn't have done it without their work.

<h3>Licenses Included</h3>
<ul>
<li>Apache - https://github.com/hudl/iOS-FFmpeg-processor/blob/master/LICENSE</li>
<li>GDCL - https://github.com/hudl/iOS-FFmpeg-processor/blob/master/LICENSE.markdown</li>
</ul>
