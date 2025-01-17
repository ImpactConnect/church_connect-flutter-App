import 'package:flutter/material.dart';
import '../../services/post_service.dart';
import '../../models/post.dart';
import 'create_post_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _postService = PostService();
  final List<Post> _posts = [];
  bool _isLoading = false;
  int _page = 1;
  bool _hasMore = true;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }

  Future<void> _loadPosts() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final posts = await _postService.getPosts(page: _page);
      setState(() {
        _posts.addAll(posts);
        _hasMore = posts.length == 10;
        _page++;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || !_hasMore) return;
    await _loadPosts();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _posts.clear();
      _page = 1;
      _hasMore = true;
    });
    await _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8),
          itemCount: _posts.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _posts.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final post = _posts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: post.userProfileImageUrl != null
                          ? NetworkImage(post.userProfileImageUrl!)
                          : null,
                      child: post.userProfileImageUrl == null
                          ? Text(post.userFullName[0])
                          : null,
                    ),
                    title: Text(post.userFullName),
                    subtitle: Text(timeago.format(post.createdAt)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(post.content),
                  ),
                  if (post.imageUrl != null)
                    Image.network(
                      post.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            post.isLikedByCurrentUser
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: post.isLikedByCurrentUser ? Colors.red : null,
                          ),
                          onPressed: () async {
                            try {
                              if (post.isLikedByCurrentUser) {
                                await _postService.unlikePost(post.id);
                              } else {
                                await _postService.likePost(post.id);
                              }
                              await _refreshPosts();
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                        ),
                        Text('${post.likesCount} likes'),
                        const SizedBox(width: 16),
                        Icon(Icons.comment_outlined),
                        const SizedBox(width: 8),
                        Text('${post.commentsCount} comments'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
          if (result == true) {
            await _refreshPosts();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
