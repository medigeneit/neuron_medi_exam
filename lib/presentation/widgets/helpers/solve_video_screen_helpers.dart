// lib/presentation/screens/solve_video_screen.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/widgets/fancy_card_background.dart';

import 'package:medi_exam/data/models/video_link_model.dart';
import 'package:medi_exam/data/services/video_link_service.dart';

// Alias to avoid name collisions
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as yti;
import 'package:webview_flutter/webview_flutter.dart';

class HeaderCard extends StatelessWidget {
  const HeaderCard({required this.videoTitle});
  final String? videoTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FancyBackground(
      gradient: AppColor.secondaryGradient,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.ondemand_video_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              videoTitle ?? '',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerArea extends StatelessWidget {
  const PlayerArea({
    required this.loading,
    required this.error,
    required this.video,
    required this.yt,
    required this.webController,
    required this.isMobile,
    required this.isPlaying,
    required this.onTogglePlay,
  });

  final bool loading;
  final String? error;
  final VideoLinkModel? video;
  final yti.YoutubePlayerController? yt;
  final WebViewController? webController;
  final bool isMobile;
  final bool isPlaying;
  final Future<void> Function() onTogglePlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loading) {
      return CardShell(
        child: const SizedBox(
          height: 200,
          child: Center(child: LoadingWidget()),
        ),
      );
    }

    if (error != null && error!.isNotEmpty) {
      return CardShell(
        child: SizedBox(
          height: 180,
          child: Center(
            child: Text(
              error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
          ),
        ),
      );
    }

    final v = video;
    if (v == null || !v.isPlayable) {
      return CardShell(
        child: SizedBox(
          height: 180,
          child: Center(
            child: Text('No playable video found.',
                style: theme.textTheme.bodyMedium),
          ),
        ),
      );
    }

    // Android/iOS: iframe player with NO pointer events + our overlay controls
    if (v.isYouTube && isMobile && yt != null) {
      return CardShell(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                yti.YoutubePlayerScaffold(
                  controller: yt!,
                  aspectRatio: 16 / 9,
                  builder: (context, player) => player,
                ),
                OverlayControls(isPlaying: isPlaying, onTogglePlay: onTogglePlay),
              ],
            ),
          ),
        ),
      );
    }

    // Windows / others: WebView with our HTML (no clicks) + overlay controls
    if (webController != null) {
      return CardShell(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                WebViewWidget(controller: webController!),
                OverlayControls(isPlaying: isPlaying, onTogglePlay: onTogglePlay),
              ],
            ),
          ),
        ),
      );
    }

    return CardShell(
      child: SizedBox(
        height: 180,
        child: Center(
          child: Text('Unable to initialize player.',
              style: theme.textTheme.bodyMedium),
        ),
      ),
    );
  }
}

class OverlayControls extends StatelessWidget {
  const OverlayControls({
    required this.isPlaying,
    required this.onTogglePlay,
  });

  final bool isPlaying;
  final Future<void> Function() onTogglePlay;

  @override
  Widget build(BuildContext context) {
    // Simple centered play/pause; you can extend with scrubber/time if needed.
    return IgnorePointer(
      ignoring: false, // we need to capture taps (iframe below is non-interactive)
      child: Center(
        child: GestureDetector(
          onTap: onTogglePlay,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                )
              ],
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
      ),
    );
  }
}

class CardShell extends StatelessWidget {
  const CardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: child,
    );
  }
}