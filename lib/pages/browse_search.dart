

import 'package:flutter/material.dart';
import 'package:pasal1/helpers/tools.dart';
import 'package:pasal1/widgets/app_loader.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/products.dart' as WS;

class BrowseSearchPage extends StatefulWidget {
  final String search;
  BrowseSearchPage({Key key, @required this.search}) : super(key: key);

  @override
  _BrowseSearchState createState() => _BrowseSearchState(search);
}

class _BrowseSearchState extends State<BrowseSearchPage> {
  _BrowseSearchState(this._search);

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<WS.Product> _products = [];
  String _search;
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

    _fetchProductsForSearch();
  }

  _fetchProductsForSearch() async {
    waitForNextRequest = true;
    List<WS.Product> products = await appPasalConnector((api) => api.getProducts(
        perPage: 100,
        search: _search,
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
            Text(trans(context, "Search results for"),
                style: Theme.of(context).primaryTextTheme.subtitle1),
            Text("\"" + _search + "\"",
                style: Theme.of(context).primaryTextTheme.headline6)
          ],
        ),
        centerTitle: true,
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
    await _fetchProductsForSearch();
    setState(() {});
    if (_shouldStopRequests) {
      _refreshController.resetNoData();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  void _onLoading() async {
    await _fetchProductsForSearch();

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
    Navigator.pushNamed(context, "/product-detail", arguments: product);
  }
}
