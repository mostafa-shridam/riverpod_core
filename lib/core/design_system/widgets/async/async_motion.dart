import 'package:flutter/widgets.dart';

/// [duration], or one millisecond when the system asks for no animations.
/// Not zero: `AnimatedSize` re-dirties its own layout with a zero duration.
Duration motionDuration(BuildContext context, Duration duration) =>
    MediaQuery.disableAnimationsOf(context)
    ? const Duration(milliseconds: 1)
    : duration;
