import 'package:flutter/material.dart';
import '../services/news_service.dart';
import '../models/news.dart';
import '../widgets/news_card.dart';
import 'news_detail_screen.dart';
import '../widgets/category_chips_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = NewsService();

  final ValueNotifier<String?> _selectedCategoryId =
      ValueNotifier<String?>(null);

  Future<void> _refresh() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _selectedCategoryId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ValueListenableBuilder<String?>(
          valueListenable: _selectedCategoryId,
          builder: (context, selectedId, _) {
        
            final Stream<List<News>> stream = switch (selectedId) {
              null => _service.streamPublished(),
              '_trending' => _service.streamTrending(), 
              String id => _service.streamByCategory(id),
            };

            return StreamBuilder<List<News>>(
              stream: stream,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const CustomScrollView(
                    slivers: [
                      _HomeAppBar(),
                      _ChipsSliver(),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }

                if (snap.hasError) {
                  return const CustomScrollView(
                    slivers: [
                      _HomeAppBar(),
                      _ChipsSliver(),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: Text('Error loading news')),
                      ),
                    ],
                  );
                }

                final items = snap.data ?? [];
                if (items.isEmpty) {
                  return const CustomScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    slivers: [
                      _HomeAppBar(),
                      _ChipsSliver(),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: Text('No news found.')),
                      ),
                    ],
                  );
                }

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    const _HomeAppBar(),
                    _ChipsSliver(selectedCategoryId: _selectedCategoryId),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      sliver: SliverList.builder(
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final n = items[i];
                          return NewsCard(
                            news: n,
                            onTap: () {
                             
                              final id = n.id;
                              if (id != null) {
                                NewsService().incrementViews(id);
                              }
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
                    ),
                  ],
                );
              },
            );
          },
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

class _ChipsSliver extends StatelessWidget {
  final ValueNotifier<String?>? selectedCategoryId;
  const _ChipsSliver({this.selectedCategoryId});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: CategoryChipsBar(
          
          selectedCategoryId:
              selectedCategoryId ?? ValueNotifier<String?>(null),
        ),
      ),
    );
  }
}
