library image_carousel;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:image_viewer/image_viewer.dart';

class Carousel extends StatefulWidget {
  const Carousel({
    Key key,
    this.images,
    this.fullImages,
    this.initialized,
    this.expandable = false,
    this.noImagesString = 'No images',
    this.showPageIndicator = true,
    this.inactivePageColor = const Color(0xFF00B3A6),
    this.activePageColor = const Color(0xFFC4C4C4),
  }) : super(key: key);

  final List<ImageProvider> images;
  final List<ImageProvider> fullImages;
  final String noImagesString;
  final bool expandable;
  final Function(PageController) initialized;
  final bool showPageIndicator;
  final Color inactivePageColor;
  final Color activePageColor;

  @override
  CarouselState createState() => CarouselState();
}

class CarouselState extends State<Carousel> {
  PageController controller;
  double _page = 1;

  @override
  void initState() {
    controller = PageController(
      viewportFraction: .75,
      initialPage: 1,
      keepPage: true,
    );

    controller.addListener(() {
      _page = controller.page;
      setState(() {});
    });

    if (widget.initialized != null) widget.initialized(controller);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    if (widget.images == null || widget.images.isEmpty) {
      return Center(
        child: Opacity(
          opacity: .35,
          child: Text(
            widget.noImagesString,
            style: theme.textTheme.headline5,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: <Widget>[
        Positioned.fill(
          bottom: widget.showPageIndicator == true ? 32.0 : 0.0,
          child: PageView.builder(
            controller: controller,
            physics: BouncingScrollPhysics(),
            itemCount: widget.images.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              double pageOffset = index - _page;

              return Container(
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(pageOffset * -15)
                    ..scale(1 - (pageOffset.abs() / 5)),
                  alignment: FractionalOffset.center,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: OpenContainer(
                        tappable: widget.expandable,
                        closedElevation: 0,
                        closedColor: Colors.transparent,
                        closedBuilder: (context, action) => Image(
                          image: widget.images[index],
                          fit: BoxFit.cover,
                        ),
                        openColor: Colors.transparent,
                        openBuilder: (context, action) => ImageViewer(
                          image: widget.fullImages[index],
                        ),
                        useRootNavigator: true,
                      )),
                ),
              );
            },
          ),
        ),
        if (widget.showPageIndicator)
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            height: 32.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List<Widget>.generate(widget.images.length, (index) {
                double pageOffset = (index - _page).abs().clamp(0.0, 1.0);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Container(
                    height: 11.0,
                    width: 11.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.lerp(
                        widget.activePageColor,
                        widget.inactivePageColor,
                        pageOffset,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
