import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/db_helper.dart';

class CategoryItem extends StatelessWidget {
  final Key key;
  final Category category;
  final Color color;
  final Function onPress;
  bool isAll;

  CategoryItem({
    required this.color,
    required this.key,
    required this.category,
    required this.isAll,
    required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => onPress(category),
        splashColor: Colors.grey,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                StreamBuilder<List<Item>>(
                    stream: isAll
                        ? Provider.of<DBHelper>(context, listen: false)
                            .getAllItemsStream()
                        : Provider.of<DBHelper>(context, listen: false)
                            .getCategoryItemsStream(category.id),
                    builder: (ctx, dataSnapshot) {
                      if (dataSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                          ),
                        );
                      }
                      if (dataSnapshot.hasData) {
                        return Text(
                          "${dataSnapshot.data!.length}",
                          style: const TextStyle(
                            fontSize: 25,
                          ),
                        );
                      }
                      print(dataSnapshot.error);
                      return Icon(Icons.error);
                    }),
              ],
            ),
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}

//5TrOXU7j6JoI1Gd8hC0q

//wbhCXLNtRoAwWj8Fbe2O