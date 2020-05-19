// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pasal1/helpers/tools.dart';
import 'package:pasal1/widgets/app_loader.dart';
import 'package:pasal1/widgets/cart_icon.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
// import '../labelconfig.dart';
import '../models/product_category.dart' as WS;
import '../models/products.dart' as WS;
import 'package:pasal1/widgets/pasal_widgets.dart';
// import 'package:flutter_swiper/flutter_swiper.dart';

class HomePage extends StatefulWidget {
  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _HomePageState();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<WS.Product> _products = [];
  List<WS.Product> _onSaleProducts = [];
   List<WS.Product> _featuredProducts = [];
  List<WS.ProductCategory> _categories = [];
  final GlobalKey _key = GlobalKey();

  int _page;
  bool _shouldStopRequests;
  bool waitForNextRequest;
  bool _isLoading;

  @override
  void initState() {
    super.initState();

    _isLoading = true;
    _page = 1;
    _home();
  }

  _home() async {
    _shouldStopRequests = false;
    waitForNextRequest = false;
   
    await _fetchFeaturedProducts();
     await _fetchMoreProducts();
    await _fetchOnSaleProducts();
    await _fetchCategories();
    setState(() {
      _isLoading = false;
    });
  }

  _fetchCategories() async {
    _categories = await appPasalConnector((api) {
      return api.getProductCategories();
    });
  }

  _fetchMoreProducts() async {
    if (_shouldStopRequests) {
      return;
    }
    if (waitForNextRequest) {
      return;
    }
    waitForNextRequest = true;
    List<WS.Product> products =
        await appPasalConnector((api) => api.getProducts(
              perPage: 50,
              page: _page,
              status: "publish",
              stockStatus: "instock",
            ));
    _page = _page + 1;
    if (products.length == 0) {
      _shouldStopRequests = true;
    }
    waitForNextRequest = false;
    setState(() {
      _products.addAll(products.toList());
    });
  }

  _fetchFeaturedProducts() async {
    // if (_shouldStopRequests) {
    //   return;
    // }
    // if (waitForNextRequest) {
    //   return;
    // }
    // waitForNextRequest = true;
    List<WS.Product> products = await appPasalConnector((api) =>
        api.getProducts(
            perPage: 4,
            status: "publish",
            stockStatus: "instock",
            featured: true));
    // _page = _page + 1;
    if (products.length == 0) {
      _shouldStopRequests = true;
    }
    // waitForNextRequest = false;
    setState(() {
      _featuredProducts.addAll(products.toList());
    });
  }

_fetchOnSaleProducts() async {
    // if (_shouldStopRequests) {
    //   return;
    // }
    // if (waitForNextRequest) {
    //   return;
    // }
    // waitForNextRequest = true;
    List<WS.Product> products = await appPasalConnector((api) =>
        api.getProducts(
            perPage: 4,
            page: _page,
            status: "publish",
            stockStatus: "instock",
            onSale: true));
    // _page = _page + 1;
    if (products.length == 0) {
      _shouldStopRequests = true;
    }
    // waitForNextRequest = false;
    setState(() {
      _onSaleProducts.addAll(products.toList());
    });
  }

  void _modalBottomSheetMenu() {
    _key.currentState.setState(() {});
    wsModalBottom(
      context,
      title: trans(context, "Categories"),
      bodyWidget: ListView.separated(
        itemCount: _categories.length,
        separatorBuilder: (cxt, i) {
          return Divider();
        },
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(parseHtmlString(_categories[index].name)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/browse-category",
                      arguments: _categories[index])
                  .then((value) => setState(() {}));
            },
          );
        },
      ),
    );
  }

  List backgroundColor = [Colors.blue, Colors.orange, Colors.green, Colors.red];

  _productImageTapped(int i) {
    _showProduct(_featuredProducts[i]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Container(
          child: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Navigator.pushNamed(context, "/home-menu"),
          ),
          margin: EdgeInsets.only(left: 0),
        ),
        title: Image.asset('assets/images/logo.png', height: 40),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            alignment: Alignment.centerLeft,
            icon: Icon(
              Icons.search,
              color: Colors.black,
              size: 35,
            ),
            onPressed: () => Navigator.pushNamed(context, "/home-search")
                .then((value) => _key.currentState.setState(() {})),
          ),
          wsCartIcon(context, key: _key)
        ],
      ),
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            swiperProducts(context,products:_featuredProducts,onTap: _productImageTapped ),
            SizedBox(height: 20,),
            pwproductList(context,
                        products: _onSaleProducts,
                        onTap: _showProduct),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(trans(context, "Shop") + " / ",
                        style: Theme.of(context).primaryTextTheme.subtitle1),
                    Text(
                      trans(context, "Popular"),
                      style: Theme.of(context).primaryTextTheme.bodyText2,
                    )
                  ],
                ),
                MaterialButton(
                  minWidth: 100,
                  height: 60,
                  child: Text(
                    trans(context, "Browse categories"),
                    style: Theme.of(context).primaryTextTheme.bodyText1,
                  ),
                  onPressed: _modalBottomSheetMenu,
                )
              ],
            ),
            (_isLoading
                ? Container(child: showAppLoader())
                : Container(
                    child: pwproductList(context,
                        products: _products,
                        onTap: _showProduct),
                    // flex: 1,
                  )),
          ],
        ),
      ),
    );
  }

  void _onRefresh() async {
    await _fetchMoreProducts();
    setState(() {});
    if (_shouldStopRequests) {
      _refreshController.resetNoData();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  void _onLoading() async {
    await _fetchMoreProducts();

    if (mounted) {
      setState(() {});
      if (_shouldStopRequests) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    }
  }

  _showProduct(WS.Product product) {
    Navigator.pushNamed(context, "/product-detail", arguments: product)
        .then((value) => _key.currentState.setState(() {}));
  }
}
