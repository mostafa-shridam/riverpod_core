/// Optional text overrides of the player controls; each falls back to its
/// `ds_media.*` translation.
class AppVideoLabels {
  const AppVideoLabels({
    this.play,
    this.pause,
    this.replay,
    this.mute,
    this.unmute,
    this.speed,
    this.fullscreen,
    this.exitFullscreen,
    this.rewind,
    this.forward,
    this.seekBar,
    this.buffering,
    this.error,
    this.retry,
  });

  final String? play;
  final String? pause;
  final String? replay;
  final String? mute;
  final String? unmute;
  final String? speed;
  final String? fullscreen;
  final String? exitFullscreen;
  final String? rewind;
  final String? forward;
  final String? seekBar;
  final String? buffering;
  final String? error;
  final String? retry;
}
