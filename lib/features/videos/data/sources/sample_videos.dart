import 'package:riverpod_core/features/videos/data/models/video.dart';

/// The demo catalogue (D-029): public test media verified with HTTP 200 on
/// 2026-10-16. Replace the URLs here and nowhere else. No thumbnail URLs: the
/// UI paints a placeholder.
const sampleVideos = <Video>[
  Video(
    id: 'butterfly',
    title: 'Butterfly in the garden',
    description:
        'A short clip of a butterfly resting on a flower. A small MP4 file '
        'that loads quickly on any connection.',
    url:
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    durationSeconds: 7,
  ),
  Video(
    id: 'bee',
    title: 'Bee at work',
    description:
        'A close look at a bee collecting pollen. Handy for testing seeking '
        'and looping on a short video.',
    url: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    durationSeconds: 8,
  ),
  Video(
    id: 'big-buck-bunny',
    title: 'The big rabbit',
    description:
        'Ten seconds of an animated short in 720p H.264. Good for checking '
        'picture quality and buffering.',
    url:
        'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_5MB.mp4',
    durationSeconds: 10,
  ),
  Video(
    id: 'sintel',
    title: 'The dragon quest',
    description:
        'An animated fantasy trailer cut to ten seconds, in 720p H.264. '
        'Useful for the speed and mute controls.',
    url:
        'https://test-videos.co.uk/vids/sintel/mp4/h264/720/Sintel_720_10s_5MB.mp4',
    durationSeconds: 10,
  ),
  Video(
    id: 'jellyfish',
    title: 'Jellyfish drifting',
    description:
        'Jellyfish floating in dark water, ten seconds in 720p H.264. '
        'Dark scenes help check the controls overlay contrast.',
    url:
        'https://test-videos.co.uk/vids/jellyfish/mp4/h264/720/Jellyfish_720_10s_5MB.mp4',
    durationSeconds: 10,
  ),
  Video(
    id: 'bipbop-basic',
    title: 'Streaming test card (basic)',
    description:
        'An HLS stream with several quality variants. Shows adaptive '
        'streaming and a longer timeline.',
    url:
        'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8',
    durationSeconds: 1800,
  ),
  Video(
    id: 'bipbop-advanced',
    title: 'Streaming test card (advanced)',
    description:
        'An HLS master playlist with audio and subtitle groups. A heavier '
        'stream for testing slow starts.',
    url:
        'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8',
    durationSeconds: 1800,
  ),
];
