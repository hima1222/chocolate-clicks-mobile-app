import 'package:flutter/material.dart';
import '../models/favorite_item.dart';
import '../services/favorites_service.dart';

class FavoriteButton extends StatefulWidget {
  final String name;
  final String image;
  final String category;

  const FavoriteButton({
    super.key,
    required this.name,
    required this.image,
    this.category = 'Treats',
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _busy = false;
  final _service = FavoritesService();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _service,
      builder: (context, child) {
        final saved = _service.contains(widget.image);
        return IconButton(
          tooltip: saved ? 'Remove from favourites' : 'Add to favourites',
          onPressed: _busy
              ? null
              : () async {
                  setState(() => _busy = true);
                  try {
                    if (saved) {
                      await _service.removeFavorite(widget.image);
                    } else {
                      await _service.addFavorite(
                        FavoriteItem(
                          id: widget.image,
                          name: widget.name,
                          imageUrl: widget.image,
                          category: widget.category,
                        ),
                      );
                    }
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          saved
                              ? 'Removed from favourites'
                              : 'Added to favourites',
                        ),
                      ),
                    );
                  } finally {
                    if (mounted) setState(() => _busy = false);
                  }
                },
          icon: Icon(
            saved ? Icons.favorite : Icons.favorite_border,
            color: saved ? Colors.redAccent : const Color(0xFFCA7A2B),
          ),
        );
      },
    );
  }
}
