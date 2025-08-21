import 'package:flutter/material.dart';
import 'package:precious/providers/categories_provider.dart';
import 'package:precious/screens/category_screen.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:provider/provider.dart';
import 'package:precious/utils/config.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    final categories = Provider.of<CategoriesProvider>(context).categories;

    return Scaffold(
      backgroundColor: Config.greyColor,
      appBar: AppBar(
        backgroundColor: Config.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Config.darkColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          LocalizationService().translate('categories'),
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Montserrat-SemiBold',
            color: Config.darkColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 1.0,
          horizontal: 10.0,
        ),
        child: Column(
          children: [
            const SizedBox(height: 5.0),
            _buildHeading(),
            const SizedBox(height: 5.0),
            _buildCategoryGrid(categories),
          ],
        ),
      ),
    );
  }

  Widget _buildHeading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Row(
        children: [
          Text(
            LocalizationService().translate('categories'),
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Montserrat-SemiBold',
              color: Config.darkColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(List<dynamic> categories) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          IconData icon = Icons.help; // Default icon

          // Handle dynamic icon resolution
          switch (category['icon']) {
            case 'Icons.mic':
              icon = Icons.mic;
              break;
            case 'Icons.church':
              icon = Icons.church;
              break;
            case 'Icons.book':
              icon = Icons.book;
              break;
            case 'Icons.shelves':
              icon = Icons.shelves;
              break;
            case 'Icons.face':
              icon = Icons.face;
              break;
            case 'Icons.heat_pump_rounded':
              icon = Icons.heat_pump_rounded;
              break;
            default:
              icon = Icons.help;
          }

          // Get gradient colors based on the icon type
          List<Color> gradientColors = _getGradientColors(icon);

          return _CategoryCard(
            categoryID: category['id'],
            categoryName: LocalizationService().translate(category['title']),
            icon: icon,
            gradientColors: gradientColors,
          );
        },
      ),
    );
  }

  // Method to return gradient colors based on the icon
  List<Color> _getGradientColors(IconData icon) {
    switch (icon) {
      case Icons.mic:
        return [Colors.blue, Colors.blueAccent];
      case Icons.church:
        return [Colors.deepOrange, Colors.orangeAccent];
      case Icons.book:
        return [Colors.green, Colors.greenAccent];
      case Icons.shelves:
        return [Colors.purple, Colors.purpleAccent];
      case Icons.face:
        return [Colors.teal, Colors.cyanAccent];
      case Icons.heat_pump_rounded:
        return [Colors.red, Colors.redAccent];
      default:
        return [Colors.grey, Colors.grey];
    }
  }
}

// ignore: unused_element
class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Chip(
        label: Text(label),
        backgroundColor: Config.whiteColor,
        labelStyle: const TextStyle(
          color: Config.primaryColor,
          fontFamily: 'Montserrat-SemiBold',
          fontSize: 12.0,
        ),
        padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
        elevation: 0,
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final int categoryID;
  final String categoryName;
  final IconData icon;
  final List<Color> gradientColors;

  const _CategoryCard({
    required this.categoryID,
    required this.categoryName,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryScreen(
              categoryID: categoryID,
              title: categoryName,
            ),
          ),
        );
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 25, color: Config.whiteColor),
            const SizedBox(height: 8.0),
            Text(
              categoryName,
              style: const TextStyle(
                color: Config.whiteColor,
                fontFamily: 'Montserrat-SemiBold',
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
