

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pasal1/helpers/enums/sort_enums.dart';
import 'package:pasal1/helpers/tools.dart';
import 'package:pasal1/widgets/app_loader.dart';
import 'package:pasal1/widgets/buttons.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/product_category.dart';
import '../models/products.dart' as WS;
import 'package:pasal1/widgets/pasal_widgets.dart';

class BrowseCategoryPage extends StatefulWidget {
  final ProductCategory productCategory;
  const BrowseCategoryPage({Key key, @required this.productCategory})
      : super(key: key);

  @override
  _BrowseCategoryPageState createState() =>
      _BrowseCategoryPageState(productCategory);
}

class _BrowseCategoryPageState extends State<BrowseCategoryPage> {
  _BrowseCategoryPageState(this._selectedCategory);

  List<WS.Product> _products = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ProductCategory _selectedCategory;
  bool _isLoading;
  int _page;
  bool _shouldStopRequests;
  bool waitForNextRequest;

  @override
  void initState() {
    super.initState();

    _isLoading = true;

    _page = 1;
    _shouldStopRequests = false;
    waitForNextRequest = false;
    _fetchMoreProducts();
  }

  _fetchMoreProducts() async {
    waitForNextRequest = true;
    List<WS.Product> products = await appPasalConnector((api) => api.getProducts(
        perPage: 50,
        category: _selectedCategory.id.toString(),
        page: _page,
        status: "publish",
        stockStatus: "instock"));
    _products.addAll(products);
    waitForNextRequest = false;
    _page = _page + 1;

    waitForNextRequest = false;
    if (products.length == 0) {
      _shouldStopRequests = true;
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(trans(context, "Browse"),
                style: Theme.of(context).primaryTextTheme.subtitle1),
            Text(_selectedCategory.name,
                style: Theme.of(context).primaryTextTheme.headline6)
          ],
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.tune),
            onPressed: _modalSheetTune,
          )
        ],
      ),
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: _isLoading
            ? Center(
                child: showAppLoader(),
              )
            : refreshableScroll(context,
                refreshController: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                products: _products,
                onTap: _showProduct),
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

  _sortProducts({@required SortByType by}) {
    switch (by) {
      case SortByType.LowToHigh:
        _products.sort((product1, product2) => (parseWcPrice(product1.price))
            .compareTo((double.tryParse(product2.price) ?? 0)));
        break;
      case SortByType.HighToLow:
        _products.sort((product1, product2) => (parseWcPrice(product2.price))
            .compareTo((double.tryParse(product1.price) ?? 0)));
        break;
      case SortByType.NameAZ:
        _products.sort(
            (product1, product2) => product1.name.compareTo(product2.name));
        break;
      case SortByType.NameZA:
        _products.sort(
            (product1, product2) => product2.name.compareTo(product1.name));
        break;
    }
    setState(() {
      Navigator.pop(context);
    });
  }

  _modalSheetTune() {
    wsModalBottom(
      context,
      title: trans(context, "Sort results"),
      bodyWidget: ListView(
        children: <Widget>[
          wsLinkButton(context,
              title: trans(context, "Sort: Low to high"),
              action: () => _sortProducts(by: SortByType.LowToHigh)),
          Divider(
            height: 0,
          ),
          wsLinkButton(context,
              title: trans(context, "Sort: High to low"),
              action: () => _sortProducts(by: SortByType.HighToLow)),
          Divider(
            height: 0,
          ),
          wsLinkButton(context,
              title: trans(context, "Sort: Name A-Z"),
              action: () => _sortProducts(by: SortByType.NameAZ)),
          Divider(
            height: 0,
          ),
          wsLinkButton(context,
              title: trans(context, "Sort: Name Z-A"),
              action: () => _sortProducts(by: SortByType.NameZA)),
          Divider(
            height: 0,
          ),
          wsLinkButton(context,
              title: trans(context, "Cancel"), action: _dismissModal)
        ],
      ),
    );
  }

  _dismissModal() {
    Navigator.pop(context);
  }

  _showProduct(WS.Product product) {
    Navigator.pushNamed(context, "/product-detail", arguments: product);
  }
}
