import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/favourite_questions_list_model.dart';
import 'package:medi_exam/data/models/question_analytics_breakdown_model.dart';
import 'package:medi_exam/data/models/unit_video_add_to_cart_model.dart';
import 'package:medi_exam/data/models/unit_video_model.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/services/favourite_questions_list_service.dart';
import 'package:medi_exam/data/services/favourites_toggle_service.dart';
import 'package:medi_exam/data/services/question_analytics_breakdown_service.dart';
import 'package:medi_exam/data/services/unit_video_add_to_cart_service.dart';
import 'package:medi_exam/data/services/unit_video_service.dart';
import 'package:medi_exam/data/utils/urls.dart';
import 'package:medi_exam/presentation/screens/webview_video_screen.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/question_explaination_button.dart';

/// Global favourite cache
class GlobalFavouriteCache {
  static final FavouriteQuestionsListService _listService =
  FavouriteQuestionsListService();

  static final Set<int> _ids = <int>{};
  static bool _loaded = false;
  static Future<void>? _loadingFuture;

  static bool contains(int id) => _ids.contains(id);

  static void setFavourite(int id, bool isFav) {
    if (isFav) {
      _ids.add(id);
    } else {
      _ids.remove(id);
    }
  }

  static void setLoadedIds(Iterable<int> ids) {
    _ids
      ..clear()
      ..addAll(ids);
    _loaded = true;
    _loadingFuture = Future.value();
  }

  static void reset() {
    _ids.clear();
    _loaded = false;
    _loadingFuture = null;
  }

  static Future<void> ensureLoaded() {
    if (_loaded) return Future.value();
    _loadingFuture ??= _loadOnce();
    return _loadingFuture!;
  }

  static Future<void> _loadOnce() async {
    bool success = false;

    try {
      final resp = await _listService.fetchAllFavouriteQuestions();

      if (resp.isSuccess) {
        final model = resp.responseData is FavouriteQuestionsListModel
            ? resp.responseData as FavouriteQuestionsListModel
            : FavouriteQuestionsListModel.parse(resp.responseData);

        final items = model.data ?? const <FavouriteQuestionItem>[];

        _ids
          ..clear()
          ..addAll(items.map((e) => e.id).whereType<int>());

        success = true;
      }
    } catch (_) {
      success = false;
    } finally {
      _loaded = success;

      if (!success) {
        _loadingFuture = null;
      }
    }
  }
}

/// Compact action row:
/// 1) Favourite
/// 2) Stats
/// 3) Video
/// 4) Explanation
class QuestionActionRow extends StatefulWidget {
  final int? questionId;
  final bool initiallyBookmarked;

  /// Notify parent when favourite changes
  final ValueChanged<bool>? onFavouriteChanged;

  const QuestionActionRow({
    super.key,
    required this.questionId,
    this.initiallyBookmarked = false,
    this.onFavouriteChanged,
  });

  @override
  State<QuestionActionRow> createState() => _QuestionActionRowState();
}

class _QuestionActionRowState extends State<QuestionActionRow> {
  static final FavouritesToggleService _toggleService =
  FavouritesToggleService();

  static final QuestionAnalyticsBreakdownService _statsService =
  QuestionAnalyticsBreakdownService();

  static final UnitVideoService _unitVideoService = UnitVideoService();

  static final UnitVideoAddToCartService _unitVideoCartService =
  UnitVideoAddToCartService();

  bool _bookmarked = false;
  bool _favLoading = false;

  UnitVideoModel? _unitVideoModel;
  bool _unitVideoLoading = false;
  bool _unitVideoLoaded = false;

  final Set<int> _addingCartVideoIds = <int>{};

  bool _userOverrode = false;

  @override
  void initState() {
    super.initState();
    _initFavouriteState();
    _loadUnitVideos();
  }

  @override
  void didUpdateWidget(covariant QuestionActionRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.questionId != widget.questionId) {
      _userOverrode = false;

      _unitVideoModel = null;
      _unitVideoLoaded = false;
      _unitVideoLoading = false;
      _addingCartVideoIds.clear();

      _initFavouriteState();
      _loadUnitVideos(forceRefresh: true);
    }
  }

  void _initFavouriteState() {
    final id = widget.questionId;

    _bookmarked = widget.initiallyBookmarked;

    if (id == null) {
      setState(() {});
      return;
    }

    _bookmarked = _bookmarked || GlobalFavouriteCache.contains(id);

    if (_bookmarked) {
      GlobalFavouriteCache.setFavourite(id, true);
      setState(() {});
      return;
    }

    _hydrateFromFavouriteList(id);
  }

  Future<void> _hydrateFromFavouriteList(int id) async {
    await GlobalFavouriteCache.ensureLoaded();

    if (!mounted) return;
    if (_userOverrode) return;

    setState(() {
      _bookmarked =
          widget.initiallyBookmarked || GlobalFavouriteCache.contains(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool canFav = widget.questionId != null;
    final bool hasVideos = _unitVideoModel?.videos.isNotEmpty == true;

    return Row(
      children: [
        _ActionPillButton(
          icon: _bookmarked
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          label: 'Fav',
          selected: _bookmarked,
          loading: _favLoading,
          enabled: canFav && !_favLoading,
          onTap: _toggleFavourite,
        ),
        const SizedBox(width: 8),
        _ActionPillButton(
          icon: Icons.pie_chart_outline_rounded,
          label: 'Stats',
          selected: false,
          loading: false,
          enabled: widget.questionId != null,
          onTap: () => _openStatsDialog(context),
        ),
        if (_unitVideoLoading) ...[
          const SizedBox(width: 8),
          _ActionPillButton(
            icon: Icons.video_library_outlined,
            label: 'Video',
            selected: false,
            loading: true,
            enabled: false,
            onTap: () {},
          ),
        ] else if (_unitVideoLoaded && hasVideos) ...[
          const SizedBox(width: 8),
          _ActionPillButton(
            icon: Icons.play_circle_outline_rounded,
            label: 'Video',
            selected: false,
            loading: false,
            enabled: true,
            onTap: () => _onVideoButtonTap(context),
          ),
        ],
        const Spacer(),
        QuestionExplainationButton(
          questionId: widget.questionId,
          compact: true,
        ),
      ],
    );
  }

  /// Called when user clicks video button.
  /// This always calls unit-video API again before opening the list.
  Future<void> _onVideoButtonTap(BuildContext context) async {
    await _loadUnitVideos(forceRefresh: true);

    if (!mounted) return;

    final videos = _unitVideoModel?.videos ?? const <UnitVideoItemModel>[];

    if (videos.isEmpty) {
      Get.snackbar(
        'No Video',
        'No unit video found for this question.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
      );
      return;
    }

    _openUnitVideoDialog(context);
  }

  Future<void> _loadUnitVideos({bool forceRefresh = false}) async {
    final id = widget.questionId;

    if (id == null) return;
    if (_unitVideoLoading) return;

    if (_unitVideoLoaded && !forceRefresh) return;

    setState(() {
      _unitVideoLoading = true;

      if (forceRefresh) {
        _unitVideoLoaded = false;
      }
    });

    try {
      final resp = await _unitVideoService.fetchUnitVideos(id.toString());

      if (!mounted) return;

      UnitVideoModel? model;

      if (resp.isSuccess && resp.responseData != null) {
        model = resp.responseData is UnitVideoModel
            ? resp.responseData as UnitVideoModel
            : UnitVideoModel.parse(resp.responseData);
      }

      setState(() {
        _unitVideoModel = model;
        _unitVideoLoaded = true;
        _unitVideoLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _unitVideoModel = null;
        _unitVideoLoaded = true;
        _unitVideoLoading = false;
      });
    }
  }

  void _openUnitVideoDialog(BuildContext context) {
    final videos = _unitVideoModel?.videos ?? const <UnitVideoItemModel>[];

    if (videos.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _UnitVideoListSheet(
          videos: videos,
          addingCartVideoIds: _addingCartVideoIds,
          onPlayVideo: (video) {
            Navigator.of(ctx).pop();
            _openWebviewVideoScreen(context, video);
          },
          onAddToCart: (video) async {
            final success = await _addUnitVideoToCart(video);

            if (!success) return;
            if (!mounted) return;

            if (ctx.mounted && Navigator.of(ctx).canPop()) {
              Navigator.of(ctx).pop();
            }

            Future.delayed(const Duration(milliseconds: 140), () {
              if (!mounted) return;

              final updatedVideos =
                  _unitVideoModel?.videos ?? const <UnitVideoItemModel>[];

              if (updatedVideos.isNotEmpty) {
                _openUnitVideoDialog(context);
              }
            });
          },
        );
      },
    );
  }

  /// Adds video to cart.
  /// After success, unit-video API is called again so the Add button updates.
  Future<bool> _addUnitVideoToCart(UnitVideoItemModel video) async {
    final videoLinkId = video.id;

    if (videoLinkId == null) {
      Get.snackbar(
        'Failed',
        'Video id was not found.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return false;
    }

    if (_addingCartVideoIds.contains(videoLinkId)) return false;

    setState(() {
      _addingCartVideoIds.add(videoLinkId);
    });

    try {
      final resp = await _unitVideoCartService.addUnitVideoToCart(
        questionVideoLinkId: videoLinkId,
      );

      if (!mounted) return false;

      if (resp.isSuccess) {
        final model = resp.responseData is UnitVideoAddToCartModel
            ? resp.responseData as UnitVideoAddToCartModel
            : UnitVideoAddToCartModel.parse(resp.responseData);

        Get.snackbar(
          'Success',
          model.message ?? 'Video added to cart successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );

        await _loadUnitVideos(forceRefresh: true);

        return true;
      } else {
        Get.snackbar(
          'Failed',
          resp.errorMessage ?? 'Failed to add video to cart.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );

        return false;
      }
    } catch (e) {
      if (!mounted) return false;

      Get.snackbar(
        'Failed',
        'Failed to add video to cart: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );

      return false;
    } finally {
      if (mounted) {
        setState(() {
          _addingCartVideoIds.remove(videoLinkId);
        });
      }
    }
  }

  void _openWebviewVideoScreen(
      BuildContext context,
      UnitVideoItemModel video,
      ) {
    final rawVideoUrl = video.videoLink?.trim() ?? '';

    if (rawVideoUrl.isEmpty) {
      Get.snackbar(
        'Video unavailable',
        'Video link was not found.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return;
    }

    final playableUrl = _buildPlayableVideoUrl(rawVideoUrl);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WebviewVideoScreen(
          videoUrl: playableUrl,
          title: 'Unit Video',
        ),
      ),
    );
  }

  String _buildPlayableVideoUrl(String rawVideoUrl) {
    final String apiBase = _apiBaseUrl();
    final String base = apiBase.endsWith('/') ? apiBase : '$apiBase/';

    final String path = _isYoutubeVideo(rawVideoUrl)
        ? 'youtube-video-show'
        : 'gumlet-video-show';

    return '$base$path?video_address=${Uri.encodeComponent(rawVideoUrl)}';
  }

  String _apiBaseUrl() {
    final sampleEndpoint = Urls.unitVideo(widget.questionId?.toString() ?? '0');
    const marker = 'doctor/questions/';
    final markerIndex = sampleEndpoint.indexOf(marker);

    if (markerIndex > 0) {
      return sampleEndpoint.substring(0, markerIndex);
    }

    return sampleEndpoint;
  }

  bool _isYoutubeVideo(String url) {
    final uri = Uri.tryParse(url);
    final host = uri?.host.toLowerCase() ?? '';

    return host.contains('youtube.com') ||
        host.contains('youtu.be') ||
        url.toLowerCase().contains('youtube');
  }

  Future<void> _toggleFavourite() async {
    final id = widget.questionId;

    if (id == null) return;
    if (_favLoading) return;

    setState(() => _favLoading = true);

    final NetworkResponse resp =
    await _toggleService.toggleFavourite(questionId: id);

    if (!mounted) return;

    if (!resp.isSuccess) {
      setState(() => _favLoading = false);

      Get.snackbar(
        'Failed',
        resp.errorMessage ?? 'Failed to update favourite',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    final status = _toggleService.extractStatus(resp.responseData);

    bool newState = _bookmarked;

    if (status == 'added') newState = true;
    if (status == 'removed') newState = false;

    GlobalFavouriteCache.setFavourite(id, newState);
    _userOverrode = true;

    setState(() {
      _bookmarked = newState;
      _favLoading = false;
    });

    widget.onFavouriteChanged?.call(newState);
  }

  void _openStatsDialog(BuildContext context) {
    final qid = widget.questionId;

    if (qid == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          child: CustomBlobBackground(
            backgroundColor: Colors.white,
            blobColor: AppColor.indigo,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: FutureBuilder<NetworkResponse>(
                future: _statsService.fetchQuestionAnalyticsBreakdown(
                  qid.toString(),
                ),
                builder: (context, snapshot) {
                  final header = Row(
                    children: [
                      Icon(
                        Icons.pie_chart_rounded,
                        size: 20,
                        color: AppColor.indigo,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Question Stats',
                          style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColor.primaryTextColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded),
                        splashRadius: 20,
                      ),
                    ],
                  );

                  Widget body;

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    body = const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 2.6),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    body = Padding(
                      padding: const EdgeInsets.only(top: 14, bottom: 10),
                      child: Text(
                        'Failed to load stats.',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.red.shade700,
                        ),
                      ),
                    );
                  } else {
                    final resp = snapshot.data;

                    if (resp == null ||
                        !resp.isSuccess ||
                        resp.responseData == null) {
                      body = Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 10),
                        child: Text(
                          resp?.errorMessage ?? 'Failed to load stats.',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.red.shade700,
                          ),
                        ),
                      );
                    } else {
                      final model =
                      resp.responseData is QuestionAnalyticsBreakdownModel
                          ? resp.responseData
                      as QuestionAnalyticsBreakdownModel
                          : QuestionAnalyticsBreakdownModel.parse(
                        resp.responseData,
                      );

                      body = _StatsContent(model: model);
                    }
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      header,
                      const SizedBox(height: 6),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.72,
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: body,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ------------------------------
/// Unit video bottom sheet
/// ------------------------------
class _UnitVideoListSheet extends StatelessWidget {
  final List<UnitVideoItemModel> videos;
  final ValueChanged<UnitVideoItemModel> onPlayVideo;
  final Future<void> Function(UnitVideoItemModel) onAddToCart;
  final Set<int> addingCartVideoIds;

  const _UnitVideoListSheet({
    required this.videos,
    required this.onPlayVideo,
    required this.onAddToCart,
    required this.addingCartVideoIds,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: CustomBlobBackground(
        backgroundColor: Colors.white,
        blobColor: AppColor.indigo,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColor.blue.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.video_library_rounded,
                      color: AppColor.blue,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Unit Videos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColor.primaryTextColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.62,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: videos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final video = videos[index];

                    return _UnitVideoTile(
                      index: index,
                      video: video,
                      onPlayVideo: onPlayVideo,
                      onAddToCart: onAddToCart,
                      isAddingToCart:
                      addingCartVideoIds.contains(video.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitVideoTile extends StatelessWidget {
  final int index;
  final UnitVideoItemModel video;
  final ValueChanged<UnitVideoItemModel> onPlayVideo;
  final Future<void> Function(UnitVideoItemModel) onAddToCart;
  final bool isAddingToCart;

  const _UnitVideoTile({
    required this.index,
    required this.video,
    required this.onPlayVideo,
    required this.onAddToCart,
    required this.isAddingToCart,
  });

  @override
  Widget build(BuildContext context) {
    final String accessStatus = (video.accessStatus ?? '').toLowerCase();

    final bool isFree =
        video.isFree == true || accessStatus == 'free';

    final bool isPurchased =
        video.isPurchased == true || accessStatus == 'purchased';

    final bool isPlayable =
        (isFree || isPurchased) && video.hasVideoLink;

    final bool isLocked =
        !isPlayable &&
            (accessStatus == 'locked' || video.isPaid == true);

    final bool isAddedToCart = video.isAddedToCart == true;

    final bool canAddToCart =
        video.canAddToCart == true && !isAddedToCart && !isPlayable;

    final int amount = video.amount ?? 0;

    final Color statusColor = isPlayable
        ? Colors.green
        : isAddedToCart
        ? Colors.green
        : Colors.orange;

    final String statusLabel = isPurchased
        ? 'Purchased'
        : isFree
        ? 'Free'
        : isAddedToCart
        ? 'Added'
        : 'Locked';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isPlayable
                  ? Icons.play_circle_fill_rounded
                  : isAddedToCart
                  ? Icons.check_circle_rounded
                  : Icons.lock_rounded,
              color: statusColor,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Video ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColor.primaryTextColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _MiniStatusChip(
                      label: statusLabel,
                      color: statusColor,
                    ),
                    if (isLocked || (!isPlayable && amount > 0))
                      _MiniStatusChip(
                        label: '৳$amount',
                        color: AppColor.blue,
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          if (isPlayable)
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onPlayVideo(video),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColor.blue,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Play',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: canAddToCart && !isAddingToCart
                  ? () => onAddToCart(video)
                  : null,
              child: Opacity(
                opacity: canAddToCart || isAddedToCart ? 1 : 0.55,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isAddedToCart ? Colors.orange : AppColor.indigo,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isAddingToCart)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      else
                        Icon(
                          isAddedToCart
                              ? Icons.check_circle_rounded
                              : Icons.shopping_cart_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      const SizedBox(width: 5),
                      Text(
                        isAddingToCart
                            ? 'Adding'
                            : isAddedToCart
                            ? 'Added'
                            : 'Add',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniStatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniStatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.22),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// --------------------------------------
/// Stats content
/// --------------------------------------
class _StatsContent extends StatelessWidget {
  final QuestionAnalyticsBreakdownModel model;

  const _StatsContent({required this.model});

  static const _legendSegments = <PieLegendItem>[
    PieLegendItem(label: 'Right', color: Colors.green),
    PieLegendItem(label: 'Wrong', color: Colors.red),
    PieLegendItem(label: 'Skipped', color: Colors.orangeAccent),
  ];

  @override
  Widget build(BuildContext context) {
    if (model.isOverallWise) {
      final slices = _buildSlices(
        right: model.rightAsPercent,
        wrong: model.wrongAsPercent,
        skip: model.skipAsPercent,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _LegendChips(items: _legendSegments),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: AnimatedCakePieChart(
                slices: slices,
                duration: const Duration(milliseconds: 900),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Right ${slices[0].value.toStringAsFixed(0)}% • '
                  'Wrong ${slices[1].value.toStringAsFixed(0)}% • '
                  'Skipped ${slices[2].value.toStringAsFixed(0)}%',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColor.primaryTextColor.withOpacity(0.75),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
        ],
      );
    }

    final optionMap = model.optionBreakdowns ??
        const <String, QuestionAnalyticsOptionBreakdown>{};

    if (optionMap.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _LegendChips(items: _legendSegments),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Text(
              'No stats available.',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      );
    }

    final keys = optionMap.keys.toList()
      ..sort((a, b) {
        final aa = a.trim();
        final bb = b.trim();

        if (aa.length == 1 && bb.length == 1) {
          return aa.codeUnitAt(0).compareTo(bb.codeUnitAt(0));
        }

        return aa.compareTo(bb);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LegendChips(items: _legendSegments),
        const SizedBox(height: 12),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: keys.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            final k = keys[index];
            final o = optionMap[k];

            final slices = _buildSlices(
              right: o?.rightAsPercent,
              wrong: o?.wrongAsPercent,
              skip: o?.skipAsPercent,
            );

            return _StemPieTile(
              stemLabel: k,
              slices: slices,
            );
          },
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  List<PieSlice> _buildSlices({
    int? right,
    int? wrong,
    int? skip,
  }) {
    final r = (right ?? 0).toDouble();
    final w = (wrong ?? 0).toDouble();
    final s = (skip ?? 0).toDouble();

    return [
      PieSlice(label: 'Right', value: r, color: Colors.green),
      PieSlice(label: 'Wrong', value: w, color: Colors.red),
      PieSlice(label: 'Skipped', value: s, color: Colors.orangeAccent),
    ];
  }
}

class _StemPieTile extends StatelessWidget {
  final String stemLabel;
  final List<PieSlice> slices;

  const _StemPieTile({
    required this.stemLabel,
    required this.slices,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: AnimatedCakePieChart(
                slices: slices,
                duration: const Duration(milliseconds: 850),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stemLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColor.primaryTextColor,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionPillButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.loading,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColor.blue;
    final Color border = selected ? accent.withOpacity(0.55) : Colors.black12;
    final Color bg = selected ? accent.withOpacity(0.08) : Colors.white;
    final Color iconColor = selected ? accent : Colors.black87;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  icon,
                  size: 14,
                  color: iconColor,
                ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: Sizes.extraSmallText(context),
                  fontWeight: FontWeight.w900,
                  color: AppColor.primaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PieLegendItem {
  final String label;
  final Color color;

  const PieLegendItem({
    required this.label,
    required this.color,
  });
}

class _LegendChips extends StatelessWidget {
  final List<PieLegendItem> items;

  const _LegendChips({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((e) => _chip(e)).toList(),
    );
  }

  Widget _chip(PieLegendItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: item.color.withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            item.label,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColor.primaryTextColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class PieSlice {
  final String label;
  final double value;
  final Color color;

  const PieSlice({
    required this.label,
    required this.value,
    required this.color,
  });
}

class AnimatedCakePieChart extends StatefulWidget {
  final List<PieSlice> slices;
  final Duration duration;

  const AnimatedCakePieChart({
    super.key,
    required this.slices,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  State<AnimatedCakePieChart> createState() => _AnimatedCakePieChartState();
}

class _AnimatedCakePieChartState extends State<AnimatedCakePieChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _t = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
    );

    _ctrl.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCakePieChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.slices != widget.slices ||
        oldWidget.duration != widget.duration) {
      _ctrl.duration = widget.duration;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (_, __) {
        return CustomPaint(
          painter: _CakePiePainter(
            slices: widget.slices,
            t: _t.value,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _CakePiePainter extends CustomPainter {
  final List<PieSlice> slices;
  final double t;

  _CakePiePainter({
    required this.slices,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2;

    final bg = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black.withOpacity(0.03);

    canvas.drawCircle(center, radius, bg);

    final total = slices.fold<double>(
      0,
          (sum, slice) => sum + slice.value,
    );

    if (total <= 0) {
      final tp = TextPainter(
        text: const TextSpan(
          text: '0%',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: AppColor.primaryTextColor,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        center - Offset(tp.width / 2, tp.height / 2),
      );

      return;
    }

    final allowed = (2 * math.pi) * t;
    double startAngle = -math.pi / 2;

    for (final slice in slices) {
      final fullSweep = (slice.value / total) * (2 * math.pi);
      final used = startAngle - (-math.pi / 2);
      final remainingAllowed = allowed - used;

      if (remainingAllowed <= 0) break;

      final sweep = math.min(fullSweep, remainingAllowed);

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = slice.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        paint,
      );

      final outline = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withOpacity(0.95);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        outline,
      );

      startAngle += fullSweep;
    }

    double angle = -math.pi / 2;

    for (final slice in slices) {
      final sweep = (slice.value / total) * (2 * math.pi);

      if (slice.value <= 0) {
        angle += sweep;
        continue;
      }

      final mid = angle + sweep / 2;
      final r = radius * 0.55;

      final pos = Offset(
        center.dx + r * math.cos(mid),
        center.dy + r * math.sin(mid),
      );

      final tp = TextPainter(
        text: TextSpan(
          text: '${slice.value.toStringAsFixed(0)}%',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: radius < 60 ? 8 : 12,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        pos - Offset(tp.width / 2, tp.height / 2),
      );

      angle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _CakePiePainter oldDelegate) {
    return oldDelegate.slices != slices || oldDelegate.t != t;
  }
}