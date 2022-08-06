import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:music_project/3D_cards_details.dart';

import 'model/cards.dart';

class CardHome extends StatelessWidget {
  const CardHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black87,
        ),
        backgroundColor: Colors.white,
        title: Text(
          'My Playlist',
          style: TextStyle(color: Colors.black87),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => null,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: CardsBody(),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(bottom: 25),
              child: CardsHorizontal(),
            ),
          ),
        ],
      ),
    );
  }
}

class CardsBody extends StatefulWidget {
  const CardsBody({Key? key}) : super(key: key);

  @override
  State<CardsBody> createState() => _CardsBodyState();
}

class _CardsBodyState extends State<CardsBody> with TickerProviderStateMixin {
  bool selectedMode = false;
  late AnimationController _animationControllerSelection;
  late AnimationController animationControllerMovement;
  int? selectedIndex;

  Future<void> _onCardSelected(Card3D card, int index) async {
    setState(() {
      selectedIndex = index;
    });
    final duration = Duration(milliseconds: 750);
    animationControllerMovement.forward();

    await Navigator.of(context).push(
      PageRouteBuilder(
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          pageBuilder: (context, animation, _) => FadeTransition(
              opacity: animation, child: CardDetails(card: card))),
    );
    animationControllerMovement.reverse(from: 1.0);
  }

  int _getCurrentFactor(int currentIndex) {
    if (selectedIndex == null || currentIndex == selectedIndex) {
      return 0;
    } else if (currentIndex > selectedIndex!) {
      return -1;
    } else {
      return 1;
    }
  }

  @override
  void initState() {
    _animationControllerSelection = AnimationController(
        vsync: this,
        lowerBound: 0.15,
        upperBound: 0.5,
        duration: Duration(milliseconds: 500));
    animationControllerMovement =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    super.initState();
  }

  @override
  void dispose() {
    _animationControllerSelection.dispose();
    animationControllerMovement.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return AnimatedBuilder(
        animation: _animationControllerSelection,
        builder: (context, snapshot) {
          final selectiomValue = _animationControllerSelection.value;
          return GestureDetector(
            onTap: () {
              if (!selectedMode) {
                _animationControllerSelection.forward().whenComplete(() {
                  setState(() {
                    selectedMode = true;
                  });
                });
              } else {
                _animationControllerSelection.reverse().whenComplete(() {
                  setState(() {
                    selectedMode = false;
                  });
                });
              }
            },
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(selectiomValue),
              child: AbsorbPointer(
                absorbing: !selectedMode,
                child: Container(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth * 0.45,
                  color: Colors.white,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: List.generate(
                      4,
                      (index) => Card3DItem(
                        height: constraints.maxHeight / 2,
                        card: cardlist[index],
                        percent: selectiomValue,
                        depth: index,
                        animation: animationControllerMovement,
                        verticalFactor: _getCurrentFactor(index),
                        onCardSelected: (card) {
                          _onCardSelected(card, index);
                        },
                      ),
                    ).reversed.toList(),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

class Card3DItem extends AnimatedWidget {
  const Card3DItem(
      {Key? key,
      required this.card,
      this.percent,
      this.height,
      this.depth,
      this.verticalFactor = 0,
      required Animation<double> animation,
      required this.onCardSelected})
      : super(key: key, listenable: animation);

  final Card3D card;
  final double? percent;
  final double? height;
  final int? depth;
  final ValueChanged<Card3D> onCardSelected;
  final int verticalFactor;

  Animation<double> get animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final depthFactor = 40.0;
    final bottonMargin = height! / 5.0;
    return Positioned(
      left: 0,
      right: 0,
      top: height! + -depth! * height! / 2.4 * percent! - bottonMargin,
      child: Opacity(
        opacity: verticalFactor == 0 ? 1 : 1 - animation.value,
        child: Hero(
          tag: Text(card.title),
          flightShuttleBuilder: (
            context,
            animation,
            flightDirection,
            fromHeroContext,
            toHeroContext,
          ) {
            Widget current;
            if (flightDirection == HeroFlightDirection.push) {
              current = toHeroContext.widget;
            } else {
              current = fromHeroContext.widget;
            }
            return AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                final newValue = lerpDouble(
                  0.0,
                  2 * pi,
                  animation.value,
                );
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(newValue!),
                  child: current,
                );
              },
            );
          },
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0011)
              ..translate(
                  0.0,
                  verticalFactor *
                      animation.value *
                      MediaQuery.of(context).size.height,
                  depth! * depthFactor),
            child: GestureDetector(
              onTap: () {
                onCardSelected(card);
              },
              child: SizedBox(
                height: height,
                child: Card3DWidget(
                  card: card,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Card3DWidget extends StatelessWidget {
  Card3DWidget({Key? key, required this.card}) : super(key: key);
  final Card3D card;

  @override
  Widget build(BuildContext context) {
    final border = BorderRadius.circular(20);
    return PhysicalModel(
      color: Colors.white,
      elevation: 10,
      borderRadius: border,
      child: ClipRRect(
        borderRadius: border,
        child: Image.asset(
          card.image!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class CardsHorizontal extends StatelessWidget {
  const CardsHorizontal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text(
            'Recently Played',
            style: TextStyle(fontSize: 22),
          ),
        ),
        Expanded(
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: cardlist.length,
                itemBuilder: (context, index) {
                  final card = cardlist[index];
                  return Padding(
                    padding: EdgeInsets.all(10),
                    child: Card3DWidget(
                      card: card,
                    ),
                  );
                }))
      ],
    );
  }
}
