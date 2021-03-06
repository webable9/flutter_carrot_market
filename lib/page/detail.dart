import 'package:carousel_slider/carousel_slider.dart';
import 'package:carrot_market/components/manor_temperature_widget.dart';
import 'package:carrot_market/repository/contents_repository.dart';
import 'package:carrot_market/utils/data_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DetailContentView extends StatefulWidget {
  Map<String, String> data;
  DetailContentView({Key key, this.data}) : super(key: key);

  @override
  _DetailContentViewState createState() => _DetailContentViewState();
}

class _DetailContentViewState extends State<DetailContentView>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  ContentsRepository contentsRepository = ContentsRepository();
  Size size;
  List<Map<String, String>> imgList;
  int _current;
  double scrollpositionToAlpha = 0;
  ScrollController _controller = ScrollController();
  AnimationController _animationController;
  Animation _colorTween;
  bool isMyFavoriteContent;

  @override
  void initState() {
    super.initState();
    isMyFavoriteContent = false; //관심상품
    contentsRepository = ContentsRepository();
    //앱바 아이콘 스크롤시 색상 변경
    _animationController = AnimationController(vsync: this);
    _colorTween = ColorTween(begin: Colors.white, end: Colors.black)
        .animate(_animationController);
    _controller.addListener(() {
      setState(() {
        //앱바 배경색상 스크롤시 색상 변경
        if (_controller.offset > 255) {
          scrollpositionToAlpha = 255;
        } else {
          scrollpositionToAlpha = _controller.offset;
        }
        _animationController.value = scrollpositionToAlpha / 255;
      });
    });
    _loadMyFavoriteContentState();
  }

  _loadMyFavoriteContentState() async {
    bool ck = await contentsRepository.isMyFavoritecontents(widget.data["cid"]);
    print(ck);
    setState(() {
      isMyFavoriteContent = ck; //관심상품
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = MediaQuery.of(context).size;
    //캐로젤에 사용하는 이미지 리스트
    imgList = [
      {"id": "0", "url": widget.data["image"]},
      {"id": "1", "url": widget.data["image"]},
      {"id": "2", "url": widget.data["image"]},
      {"id": "3", "url": widget.data["image"]},
      {"id": "4", "url": widget.data["image"]},
    ];
    _current = 0;
  }

  //아이콘 색상이 점진적으로 변화(화이트에서 블랙으로)
  Widget _makeIcon(IconData icon) {
    return AnimatedBuilder(
      animation: _colorTween,
      builder: (context, child) => Icon(icon, color: _colorTween.value),
    );
  }

  //앱바
  Widget _appbarWidget() {
    return AppBar(
      backgroundColor: Colors.white.withAlpha(scrollpositionToAlpha.toInt()),
      elevation: 0,
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: _makeIcon(Icons.arrow_back)),
      actions: [
        IconButton(onPressed: () {}, icon: _makeIcon(Icons.share)),
        IconButton(onPressed: () {}, icon: _makeIcon(Icons.more_vert)),
      ],
    );
  }

  Widget _makeSliderImage() {
    return Container(
      child: Stack(
        children: [
          //화면 전환 애니메이션 효과
          Hero(
            tag: widget.data["cid"],
            child: CarouselSlider(
              options: CarouselOptions(
                  height: size.width,
                  initialPage: 0,
                  enableInfiniteScroll: false,
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  }),
              items: imgList.map(
                (map) {
                  return Image.asset(
                    map["url"],
                    width: size.width,
                    fit: BoxFit.fill,
                  );
                },
              ).toList(),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imgList.map((map) {
                return Container(
                  width: 10.0,
                  height: 10.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == int.parse(map["id"])
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sellerSimpleInfo() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: Image.asset("assets/images/user.png").image,
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "개발하는 남자",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "제주시 도담동",
              )
            ],
          ),
          Expanded(
            child: ManorTemperatur(
              manorTemp: 37.5,
            ),
          )
        ],
      ),
    );
  }

  Widget _line() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 1,
      color: Colors.grey.withOpacity(0.3),
    );
  }

  Widget _contentDetail() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 20,
          ),
          Text(
            widget.data["title"],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            "디지털/가전 22시간 전",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "선물받은 새상품이고\n상품 꺼내보기만 했습니다.\n거래는 직거래만 합니다.",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "채팅 3 . 관심 17 . 조회 295",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Widget _otherCellContents() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "판매자님의 판매 상품",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "모두보기",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget _bodyWidget() {
    return CustomScrollView(
      controller: _controller,
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              _makeSliderImage(),
              _sellerSimpleInfo(),
              _line(),
              _contentDetail(),
              _line(),
              _otherCellContents(),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            delegate: SliverChildListDelegate(List.generate(20, (index) {
              return Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: Colors.grey,
                        height: 120,
                      ),
                    ),
                    Text(
                      "상품 제목",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "금액",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              );
            }).toList()),
          ),
        ),
      ],
    );
  }

  Widget _bottomBarWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      width: size.width,
      height: 55,
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              if (isMyFavoriteContent) {
                await contentsRepository
                    .deleteMyFavoriteContent(widget.data["cid"]); //제거
              } else {
                await contentsRepository.addMyFavoriteContent(widget.data); //등록
              }

              setState(() {
                isMyFavoriteContent = !isMyFavoriteContent; //토클로 처리됨
              });
              //툴팁 보여주기
              scaffoldKey.currentState.showSnackBar(SnackBar(
                duration: Duration(milliseconds: 1000),
                content: Text(
                  isMyFavoriteContent ? "관심목록에 추가됐습니다." : "관심목록에 제거됐습니다.",
                ),
              ));
            },
            child: SvgPicture.asset(
              isMyFavoriteContent
                  ? "assets/svg/heart_on.svg"
                  : "assets/svg/heart_off.svg",
              width: 25,
              height: 25,
              color: Color(0Xfff08f4f),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              left: 15,
              right: 10,
            ),
            width: 1,
            height: 40,
            color: Colors.grey.withOpacity(0.3),
          ),
          Column(
            children: [
              Text(
                DataUtils.calcStringToWon(widget.data["price"]),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "가격제안불가",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Color(0Xfff08F4f),
                  ),
                  child: Text("채팅으로 거래하기",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: _appbarWidget(),
      body: _bodyWidget(),
      bottomNavigationBar: _bottomBarWidget(),
    );
  }
}
