import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/models/career_guideline_folder_model.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/services/career_guideline_folder_service.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/career_guideline_file_tile.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';
import 'package:medi_exam/presentation/widgets/loading_widget.dart';

class CareerGuidelineScreen extends StatefulWidget {
  const CareerGuidelineScreen({super.key});

  @override
  State<CareerGuidelineScreen> createState() => _CareerGuidelineScreenState();
}

class _CareerGuidelineScreenState extends State<CareerGuidelineScreen> {
  final CareerGuidelineFolderService _service = CareerGuidelineFolderService();
  final ScrollController _scrollController = ScrollController();

  CareerGuidelineFolderModel? _model;
  final List<CareerGuidelineFile> _files = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  String _folderId = '';
  String _folderName = 'Post Graduation Guideline';
  String _folderColorHex = '#5019d2';

  CareerGuidelinePagination? get _pagination => _model?.pagination;

  @override
  void initState() {
    super.initState();
    _readArguments();
    _scrollController.addListener(_onScroll);
    _fetchInitial();
  }

  void _readArguments() {
    final args = Get.arguments;

    if (args is Map) {
      _folderId = (args['folderId'] ?? '').toString();
      _folderName =
          (args['folderName'] ?? 'Post Graduation Guideline').toString();
      _folderColorHex = (args['folderColor'] ?? '#5019d2').toString();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Color get _headerColor {
    try {
      final hex = _folderColorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColor.primaryColor;
    }
  }

  Future<void> _fetchInitial() async {
    if (_folderId.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Folder ID is missing';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _model = null;
      _files.clear();
    });

    try {
      final NetworkResponse response = await _service.fetchCareerGuidelineFolder(
        folderId: _folderId,
        page: 1,
      );

      if (!mounted) return;

      if (response.isSuccess &&
          response.responseData is CareerGuidelineFolderModel) {
        final model = response.responseData as CareerGuidelineFolderModel;

        setState(() {
          _model = model;
          _files
            ..clear()
            ..addAll(model.safeFiles);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              response.errorMessage ?? 'Failed to load guideline files';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _fetchInitial();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_isLoading || _isLoadingMore) return;

    final pagination = _pagination;
    if (pagination == null || !pagination.hasNextPage) return;

    final threshold = _scrollController.position.maxScrollExtent - 180;
    if (_scrollController.position.pixels >= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final pagination = _pagination;
    if (pagination == null || !pagination.hasNextPage || _isLoadingMore) {
      return;
    }

    final nextPage = pagination.nextPage;
    if (nextPage == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final NetworkResponse response = await _service.fetchCareerGuidelineFolder(
        folderId: _folderId,
        page: nextPage,
      );

      if (!mounted) return;

      if (response.isSuccess &&
          response.responseData is CareerGuidelineFolderModel) {
        final nextModel = response.responseData as CareerGuidelineFolderModel;

        setState(() {
          _model = nextModel;
          _files.addAll(nextModel.safeFiles);
        });
      }
    } catch (_) {
      // Load-more failure is intentionally silent to keep scrolling smooth.
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  String get _countText {
    return '${_files.length} item${_files.length == 1 ? '' : 's'}';
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomBlobBackground(
        backgroundColor: Colors.white,
        blobColor: _headerColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _headerColor.withOpacity(0.12),
                ),
                child: Icon(
                  Icons.folder_open_rounded,
                  size: 24,
                  color: _headerColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _folderName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: Sizes.bodyText(context),
                        fontWeight: FontWeight.bold,
                        color: _headerColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Browse all available guideline files',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: Sizes.smallText(context),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _headerColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _countText,
                  style: TextStyle(
                    fontSize: Sizes.smallText(context),
                    color: _headerColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: CustomBlobBackground(
          backgroundColor: Colors.white,
          blobColor: AppColor.indigo,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 56,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage ?? 'Something went wrong',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Sizes.normalText(context),
                    color: Colors.red[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchInitial,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: CustomBlobBackground(
          backgroundColor: Colors.white,
          blobColor: _headerColor,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.insert_drive_file_outlined,
                  size: 60,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'No files available',
                  style: TextStyle(
                    fontSize: Sizes.bodyText(context),
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Please check again later.',
                  style: TextStyle(
                    fontSize: Sizes.smallText(context),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColor.primaryColor,
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _buildHeaderCard(context),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _files.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final file = _files[index];
                    return CareerGuidelineFileTile(file: file);
                  },
                ),
                if (_isLoadingMore) ...[
                  const SizedBox(height: 14),
                  const Center(
                    child: LoadingWidget(size: 26),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (_errorMessage != null) {
      return _buildErrorView(context);
    }

    if (_files.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _buildHeaderCard(context),
          const SizedBox(height: 12),
          _buildEmptyView(context),
        ],
      );
    }

    return _buildListView(context);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: _folderName,
      body: _buildBody(context),
    );
  }
}