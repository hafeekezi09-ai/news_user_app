import 'package:flutter/material.dart';
import '../models/news.dart';
import '../widgets/news_card.dart';
import 'news_detail_screen.dart';
import '../widgets/category_chips_bar.dart';
import '../services/paged_news_service.dart';

class HomePaginatedScreen extends StatefulWidget {
  const HomePaginatedScreen({super.key});

  @override
  State<HomePaginatedScreen> createState() => _HomePaginatedScreenState();
}

class _HomePaginatedScreenState extends State<HomePaginatedScreen> {
  final ValueNotifier<String?> _selectedCategoryId = ValueNotifier<String?>(null);
  final _svc = PagedNewsService();
  final _controller = ScrollController();

  final List<News> _items = [];
  bool _loading = false;
  bool _initialLoaded = false;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _controller.addListener(_onScroll);
    _selectedCategoryId.addListener(() {
      _svc.reset(categoryId: _selectedCategoryId.value);
      _items.clear();
      _initialLoaded = false;
      _loadInitial();
    });
  }

  Future<void> _loadInitial() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final data = await _svc.loadFirstPage(categoryId: _selectedCategoryId.value);
      setState(() {
        _items.addAll(data);
        _initialLoaded = true;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _loading) return;
    setState(() => _loadingMore = true);
    try {
      final more = await _svc.loadNextPage(categoryId: _selectedCategoryId.value);
      if (more.isNotEmpty) {
        setState(() => _items.addAll(more));
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _onScroll() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _refresh() async {
    _svc.reset(categoryId: _selectedCategoryId.value);
    _items.clear();
    await _loadInitial();
  }

  @override
  void dispose() {
    _controller.dispose();
    _selectedCategoryId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          controller: _controller,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const _HomeAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: CategoryChipsBar(selectedCategoryId: _selectedCategoryId),
              ),
            ),

            if (_loading && !_initialLoaded)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('No news found.')),
              )
            else
              SliverList.builder(
                itemCount: _items.length + 1, // +1 for loader
                itemBuilder: (context, index) {
                  if (index == _items.length) {
                    return _loadingMore
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox.shrink();
                  }
                  final n = _items[index];
                  return NewsCard(
                    news: n,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NewsDetailScreen(news: n),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      title: const Text('Latest News'),
    );
  }
}
