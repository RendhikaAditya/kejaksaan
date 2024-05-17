import 'package:flutter/cupertino.dart';

class ImageSlider extends StatefulWidget {
  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final List<String> images = [
    'https://assets.promediateknologi.id/crop/0x0:0x0/750x500/webp/photo/2023/03/16/IMG_20230316_101522-795259457.jpg',
    'https://rekrutmen.kejaksaan.go.id/uploads/news/title_img/04ce8b3174d4ca440b56246b463b4cd9.png',
    'https://www.kejaksaan.go.id/uploads/layanan/212f2a5d9889f30e16707f58690c04c1.png',
  ];

  final PageController _pageController = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Image.network(
                images[index],
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(images.length, (index) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentPage == index
                    ? Color.fromRGBO(41, 69, 145, 0.9019607843137255)
                    : Color.fromRGBO(0, 0, 0, 0.4),
              ),
            );
          }),
        ),
      ],
    );
  }
}