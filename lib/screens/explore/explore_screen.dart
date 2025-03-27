import 'package:anilist_test/screens/explore/all_anime/popular_screen.dart';
import 'package:anilist_test/screens/explore/genres/genre_screen.dart';
import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    _tabController = TabController(length: 2, vsync: this);
    var theme = Theme.of(context).colorScheme;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: true,
              centerTitle: true,
              title: Text(
                "Explore Anime",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.primary,
                ),
              ),
              floating: true,
              bottom: TabBar(
                dividerColor: Colors.transparent,
                controller: _tabController,
                tabs: [Tab(text: "All Anime"), Tab(text: "Genres")],
              ),
            ),
          ];
        },

        body: TabBarView(
          controller: _tabController,
          children: [PopularAnimeScreen(), GenreScreen()],
        ),
      ),
    );
  }
}
