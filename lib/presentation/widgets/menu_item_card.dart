import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wishi_app/domain/models/menu_item.dart';
import 'package:wishi_app/presentation/views/home/menu_item_details_dialog.dart';

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    super.key,
    required this.item,
    required this.categoryName,
  });

  final MenuItem item;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) =>
                MenuItemDetailsDialog(item: item, categoryName: categoryName),
          );
        },
        child: Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: <Widget>[
            if (item.imageUrl != null)
              FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: item.imageUrl!,
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50),
                    ),
                  );
                },
              )
            else
              Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54, Colors.black87],
                  stops: const [0.5, 0.8, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    item.name,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                  ),
                  if (item.optionGroups.isNotEmpty)
                    Text(
                      item.optionGroups
                          .expand((group) => group.options)
                          .map((option) => option.name)
                          .join(', '),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
