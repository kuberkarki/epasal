library pasalconnector;

import 'helpers/api_provider.dart';
// import 'helpers/shared_pref.dart';
import 'models/products.dart';
import 'models/product_review.dart';
import 'models/product_category.dart';
import 'models/customer.dart';
import 'models/order.dart';
import 'models/product_variation.dart';
import 'models/product_attributes.dart';
import 'models/product_attribute_term.dart';
import 'models/product_shipping_class.dart';
import 'models/tax_rate.dart';
import 'models/shipping_zone_method.dart';
import 'models/tax_classes.dart';
import 'models/shipping_zone.dart';
import 'models/shipping_method.dart';
import 'models/payload/order_wc.dart';
// import 'package:http/http.dart' as http;

class PasalConnector {
  ApiProvider _apiProvider;
  bool _shouldDebug;

  static Future<PasalConnector> getInstance() async {
    PasalConnector pasalConnector =  PasalConnector._internal();
    await pasalConnector._init();
    return pasalConnector;
  }

  PasalConnector._internal();

  Future _init() async {
    _apiProvider = new ApiProvider();
    await _apiProvider.initializationDone;
  }

  bool _shouldDebugMode() {
    return this._shouldDebug;
  }

  void _printLog(String message) {
    if (_shouldDebugMode() == true) {
      print("DarazPasal LOG: " + message);
    }
  }

  Map<String, dynamic> _standardPayload(String type, json, String path) {
    return {"type": type, "payload": json, "path": path};
  }

  /// /products
  Future<List<Product>> getProducts(
      {int page,
      int perPage,
      String search,
      String after,
      String before,
      String order,
      String orderBy,
      String slug,
      String status,
      String type,
      String sku,
      String category,
      String tag,
      String shippingClass,
      String attribute,
      String attributeTerm,
      String taxClass,
      String minPrice,
      String maxPrice,
      String stockStatus,
      List<int> exclude,
      List<int> parentExclude,
      List<int> include,
      List<int> parent,
      int offset,
      bool featured,
      bool onSale}) async {
    Map<String, dynamic> payload = {};
    if (page != null) payload["page"] = page;
    if (perPage != null) payload["per_page"] = perPage;
    if (search != null) payload["search"] = search;
    if (after != null) payload["after"] = after;
    if (before != null) payload["before"] = before;
    if (order != null) payload["order"] = order;
    if (orderBy != null) payload["order_by"] = orderBy;
    if (slug != null) payload["slug"] = slug;
    if (status != null) payload["status"] = status;
    if (type != null) payload["type"] = type;
    if (sku != null) payload["sku"] = sku;
    if (category != null) payload["category"] = category;
    if (tag != null) payload["tag"] = tag;
    if (shippingClass != null) payload["shipping_class"] = shippingClass;
    if (attribute != null) payload["attribute"] = attribute;
    if (attributeTerm != null) payload["attribute_term"] = attributeTerm;
    if (taxClass != null) payload["tax_class"] = taxClass;
    if (minPrice != null) payload["min_price"] = minPrice;
    if (maxPrice != null) payload["max_price"] = maxPrice;
    if (stockStatus != null) payload["stock_status"] = stockStatus;
    if (exclude != null) payload["exclude"] = exclude;
    if (parentExclude != null) payload["parent_exclude"] = parentExclude;
    if (include != null) payload["include"] = include;
    if (parent != null) payload["parent"] = parent;
    if (offset != null) payload["offset"] = offset;
    if (featured != null) payload["featured"] = featured;
    if (onSale != null) payload["on_sale"] = onSale;

     String qry='';

    if (page != null) qry =qry+'&page='+page.toString();
    if (perPage != null) qry =qry+'&per_page='+perPage.toString();
    if (search != null) qry =qry+'&search='+search;
    if (exclude != null) qry =qry+'&exclude='+exclude.toString();
    if (include != null) qry =qry+'&include='+include.toString();
    if (order != null) qry =qry+'&order='+order;
    if (orderBy != null) qry =qry+'&orderby='+ orderBy;
    if (category != null) qry =qry+'&category='+category;
     if (search != null)  qry =qry+'&search='+ search;
    if (parent != null) qry =qry+'&parent='+ parent.toString();
    if (featured != null) qry =qry+'&featured='+ featured.toString();

    if (onSale != null) qry =qry+'&on_sale='+onSale.toString();
    if (slug != null) qry =qry+'&slug='+slug;

    _printLog("Parameters: " + payload.toString());
    payload = _standardPayload("get", payload, "products?"+qry);

    List<Product> products = [];
    await _apiProvider.post("/products", payload).then((json) {
      products = (json as List).map((i) => Product.fromJson(i)).toList();
    });
    _printLog(products.toString());
    return products;
  }

  /// /products-variations
  Future<List<ProductVariation>> getProductVariations(int productId,
      {int page,
      int perPage,
      String search,
      String after,
      String before,
      List<int> exclude,
      List<int> include,
      int offset,
      String order,
      String orderBy,
      List<int> parent,
      List<int> parentExclude,
      String slug,
      String status,
      String sku,
      String taxClass,
      bool onSale,
      String minPrice,
      String maxPrice,
      String stockStatus}) async {
    Map<String, dynamic> payload = {};
    if (page != null) payload["page"] = page;
    if (perPage != null) payload["per_page"] = perPage;
    if (search != null) payload["search"] = search;
    if (after != null) payload["after"] = after;
    if (before != null) payload["before"] = before;
    if (exclude != null) payload["exclude"] = exclude;
    if (include != null) payload["include"] = include;
    if (offset != null) payload["offset"] = offset;
    if (order != null) payload["order"] = order;
    if (orderBy != null) payload["orderby"] = orderBy;
    if (parent != null) payload["parent"] = parent;
    if (parentExclude != null) payload["parent_exclude"] = parentExclude;
    if (slug != null) payload["slug"] = slug;
    if (status != null) payload["status"] = status;
    if (sku != null) payload["sku"] = sku;
    if (taxClass != null) payload["tax_class"] = taxClass;
    if (onSale != null) payload["on_sale"] = onSale;
    if (minPrice != null) payload["min_price"] = minPrice;
    if (maxPrice != null) payload["max_price"] = maxPrice;
    if (stockStatus != null) payload["stock_status"] = stockStatus;

    _printLog(payload.toString());
    payload = _standardPayload(
        "get", payload, "products/" + productId.toString() + "/variations");

    List<ProductVariation> productVariations = [];
    await _apiProvider.post( "products/" + productId.toString() + "/variations", payload).then((json) {
      productVariations =
          (json as List).map((i) => ProductVariation.fromJson(i)).toList();
    });
    _printLog(productVariations.toString());
    return productVariations;
  }

  /// /products-attributes
  Future<List<ProductAttribute>> getProductAttributes() async {
    Map<String, dynamic> payload = {};

    _printLog(payload.toString());
    payload = _standardPayload("get", payload, "products/attributes");

    List<ProductAttribute> productAttributes = [];
    await _apiProvider.post("/request", payload).then((json) {
      productAttributes =
          (json as List).map((i) => ProductAttribute.fromJson(i)).toList();
    });
    _printLog(productAttributes.toString());
    return productAttributes;
  }

  /// /products-attribute-terms
  Future<List<ProductAttributeTerm>> getProductAttributeTerms(int attributeId,
      {int page,
      int perPage,
      String search,
      List<int> exclude,
      List<int> include,
      String order,
      String orderBy,
      bool hideEmpty,
      int parent,
      int product,
      String slug}) async {
    Map<String, dynamic> payload = {};
    if (page != null) payload["page"] = page;
    if (perPage != null) payload["per_page"] = perPage;
    if (search != null) payload["search"] = search;
    if (exclude != null) payload["exclude"] = exclude;
    if (include != null) payload["include"] = include;
    if (int != null) payload["int"] = int;
    if (int != null) payload["int"] = int;
    if (order != null) payload["order"] = order;
    if (orderBy != null) payload["orderby"] = orderBy;
    if (hideEmpty != null) payload["hide_empty"] = hideEmpty;
    if (parent != null) payload["parent"] = parent;
    if (product != null) payload["product"] = product;
    if (slug != null) payload["slug"] = slug;

    _printLog(payload.toString());
    payload = _standardPayload("get", payload,
        "products/attributes/" + attributeId.toString() + "/terms");

    List<ProductAttributeTerm> productAttributeTerms = [];
    await _apiProvider.post("/request", payload).then((json) {
      productAttributeTerms =
          (json as List).map((i) => ProductAttributeTerm.fromJson(i)).toList();
    });
    _printLog(productAttributeTerms.toString());
    return productAttributeTerms;
  }

  /// /product-categories
  Future<List<ProductCategory>> getProductCategories(
      {int page,
      int perPage,
      String search,
      List<int> exclude,
      List<int> include,
      String order,
      String orderBy,
      bool hideEmpty,
      int parent,
      int product,
      String slug}) async {
    Map<String, dynamic> payload = {};
    if (page != null) payload["page"] = page;
    if (perPage != null) payload["per_page"] = perPage;
    if (search != null) payload["search"] = search;
    if (exclude != null) payload["exclude"] = exclude;
    if (include != null) payload["include"] = include;
    if (order != null) payload["order"] = order;
    if (orderBy != null) payload["orderby"] = orderBy;
    if (hideEmpty != null) payload["hide_empty"] = hideEmpty;
    if (parent != null) payload["parent"] = parent;
    if (product != null) payload["product"] = product;
    if (slug != null) payload["slug"] = slug;

    String qry='';

    if (page != null) qry =qry+'&page='+page.toString();
    if (perPage != null) qry =qry+'&per_page='+perPage.toString();
    if (search != null) qry =qry+'&search='+search;
    if (exclude != null) qry =qry+'&exclude='+exclude.toString();
    if (include != null) qry =qry+'&include='+include.toString();
    if (order != null) qry =qry+'&order='+order;
    if (orderBy != null) qry =qry+'&orderby='+ orderBy;
    if (hideEmpty != null) qry =qry+'&hide_empty='+hideEmpty.toString();
    if (parent != null) qry =qry+'&parent='+ parent.toString();
    if (product != null) qry =qry+'&product='+product.toString();
    if (slug != null) qry =qry+'&slug='+slug;

    _printLog(payload.toString());
    payload = _standardPayload("get", payload, "products/categories?"+qry);

    List<ProductCategory> productCategories = [];
    await _apiProvider.post("/products/categories", payload).then((json) {
      _printLog(json.toString());
      productCategories =
          (json as List).map((i) => ProductCategory.fromJson(i)).toList();
    });
    _printLog(productCategories.toString());
    return productCategories;
  }

  /// /product-shipping-classes
  Future<List<ProductShippingClass>> getProductShippingClasses(
      {int page,
      int perPage,
      String search,
      List<int> exclude,
      List<int> include,
      int offset,
      String order,
      String orderBy,
      bool hideEmpty,
      int product,
      String slug}) async {
    Map<String, dynamic> payload = {};
    if (page != null) payload["page"] = page;
    if (perPage != null) payload["per_page"] = perPage;
    if (search != null) payload["search"] = search;
    if (exclude != null) payload["exclude"] = exclude;
    if (include != null) payload["include"] = include;
    if (offset != null) payload["offset"] = offset;
    if (order != null) payload["order"] = order;
    if (orderBy != null) payload["orderby"] = orderBy;
    if (hideEmpty != null) payload["hide_empty"] = hideEmpty;
    if (product != null) payload["product"] = product;
    if (slug != null) payload["slug"] = slug;

    _printLog(payload.toString());
    payload = _standardPayload("get", payload, "products/shipping_classes");

    List<ProductShippingClass> productShippingClasses = [];
    await _apiProvider.post("/request", payload).then((json) {
      productShippingClasses =
          (json as List).map((i) => ProductShippingClass.fromJson(i)).toList();
    });
    _printLog(productShippingClasses.toString());
    return productShippingClasses;
  }

  /// /product-reviews
  Future<List<ProductReview>> getProductReviews(
      {int page,
      int perPage,
      String search,
      String after,
      String before,
      List<int> exclude,
      List<int> include,
      int offset,
      String order,
      String orderBy,
      List<int> reviewer,
      List<int> reviewerExclude,
      List<String> reviewerEmail,
      List<int> product,
      String status}) async {
    Map<String, dynamic> payload = {};

    if (page != null) payload["page"] = page;
    if (perPage != null) payload["per_page"] = perPage;
    if (search != null) payload["search"] = search;
    if (after != null) payload["after"] = after;
    if (before != null) payload["before"] = before;
    if (exclude != null) payload["exclude"] = exclude;
    if (include != null) payload["include"] = include;
    if (offset != null) payload["offset"] = offset;
    if (order != null) payload["order"] = order;
    if (orderBy != null) payload["orderby"] = orderBy;
    if (reviewer != null) payload["reviewer"] = reviewer;
    if (reviewerExclude != null) payload["reviewer_exclude"] = reviewerExclude;
    if (reviewerEmail != null) payload["reviewer_email"] = reviewerEmail;
    if (product != null) payload["product"] = product;
    if (status != null) payload["status"] = status;

    _printLog(payload.toString());
    payload = _standardPayload("get", payload, "products/reviews");

    List<ProductReview> productReviews = [];
    await _apiProvider.post("/request", payload).then((json) {
      productReviews =
          (json as List).map((i) => ProductReview.fromJson(i)).toList();
    });
    _printLog(productReviews.toString());
    return productReviews;
  }

  /// /product-reviews
  Future<ProductReview> createProductReview(
      {int productId,
      int status,
      String reviewer,
      String reviewerEmail,
      String review,
      int rating,
      bool verified}) async {
    Map<String, dynamic> payload = {};

    if (productId != null) payload['product_id'] = productId;
    if (status != null) payload['status'] = status;
    if (reviewer != null) payload['reviewer'] = reviewer;
    if (reviewerEmail != null) payload['reviewer_email'] = reviewerEmail;
    if (review != null) payload['review'] = review;
    if (rating != null) payload['rating'] = rating;
    if (verified != null) payload['verified'] = verified;

    _printLog(payload.toString());
    payload = _standardPayload("post", payload, "products/reviews");

    ProductReview productReview;
    await _apiProvider.post("/request", payload).then((json) {
      productReview = ProductReview.fromJson(json);
    });
    _printLog(productReview.toString());
    return productReview;
  }

  /// /customers
  Future<List<Customer>> getCustomers(
      {int page,
      int perPage,
      String search,
      List<int> exclude,
      List<int> include,
      int offset,
      String order,
      String orderBy,
      bool hideEmpty,
      int parent,
      int product,
      String email,
      String slug,
      String role}) async {
    Map<String, dynamic> payload = {};

    if (page != null) payload["page"] = page;
    if (perPage != null) payload["per_page"] = perPage;
    if (search != null) payload["search"] = search;
    if (exclude != null) payload["exclude"] = exclude;
    if (include != null) payload["include"] = include;
    if (offset != null) payload["offset"] = offset;
    if (order != null) payload["order"] = order;
    if (orderBy != null) payload["orderby"] = orderBy;
    if (hideEmpty != null) payload["hide_empty"] = hideEmpty;
    if (parent != null) payload["parent"] = parent;
    if (product != null) payload["product"] = product;
    if (email != null) payload["email"] = email;
    if (slug != null) payload["slug"] = slug;
    if (role != null) payload["role"] = role;

    _printLog(payload.toString());
    payload = _standardPayload("get", payload, "customers");

    List<Customer> customers = [];
    await _apiProvider.post("/request", payload).then((json) {
      customers = (json as List).map((i) => Customer.fromJson(i)).toList();
    });
    _printLog(customers.toString());
    return customers;
  }

  /// /orders
  Future<List<Order>> getOrders(
      {int page,
      int perPage,
      String search,
      String after,
      String before,
      List<int> exclude,
      List<int> include,
      int offset,
      String order,
      String orderBy,
      List<int> parent,
      List<int> parentExclude,
      List<String>
          status, // Options: any, pending, processing, on-hold, completed, cancelled, refunded, failed and trash. Default is any.
      int customer,
      int product,
      int dp}) async {
    Map<String, dynamic> payload = {};

    if (page != null) payload["page"] = page;
    if (perPage != null) payload["per_page"] = perPage;
    if (search != null) payload["search"] = search;
    if (after != null) payload["after"] = after;
    if (before != null) payload["before"] = before;
    if (exclude != null) payload["exclude"] = exclude;
    if (include != null) payload["include"] = include;
    if (offset != null) payload["offset"] = offset;
    if (order != null) payload["order"] = order;
    if (orderBy != null) payload["orderby"] = orderBy;
    if (parent != null) payload["parent"] = parent;
    if (parentExclude != null) payload["parent_exclude"] = parentExclude;
    if (status != null) payload["status"] = status;
    if (customer != null) payload["customer"] = customer;
    if (product != null) payload["product"] = product;
    if (dp != null) payload["dp"] = dp;

    _printLog(payload.toString());
    payload = _standardPayload("get", payload, "orders");

    List<Order> orders = [];
    await _apiProvider.post("/request", payload).then((json) {
      orders = (json as List).map((i) => Order.fromJson(i)).toList();
    });
    _printLog(orders.toString());
    return orders;
  }

  /// /orders#retrieve-a-order
  Future<Order> retrieveOrder(int id, {String dp}) async {
    Map<String, dynamic> payload = {};
    if (dp != null) payload["dp"] = dp;

    _printLog(payload.toString());
    payload = _standardPayload("get", payload, "orders/" + id.toString());

    Order order;
    await _apiProvider.post("/request", payload).then((json) {
      order = Order.fromJson(json);
    });
    _printLog(order.toString());
    return order;
  }

  /// /orders#create-an-order
  Future<Order> createOrder(OrderWC orderWC) async {
    Map<String, dynamic> payload = orderWC.toJson();

    _printLog(payload.toString());
    payload = _standardPayload("post", payload, "orders");

    Order order;
    await _apiProvider.post("/request", payload).then((json) {
      order = Order.fromJson(json);
    });

    _printLog(order.toString());
    return order;
  }

  /// /tax-rates
  Future<List<TaxRate>> getTaxRates(
      {int page,
      int perPage,
      int offset,
      String order,
      String orderBy,
      String taxClass}) async {
    Map<String, dynamic> payload = {};

    if (page != null) payload["page"] = page;
    if (perPage != null) payload["per_page"] = perPage;
    if (offset != null) payload["offset"] = offset;
    if (order != null) payload["order"] = order;
    if (orderBy != null) payload["orderby"] = orderBy;
    if (taxClass != null) payload["taxClass"] = taxClass;

    _printLog(payload.toString());
    payload = _standardPayload("get", payload, "taxes");

    List<TaxRate> taxRates = [];
    await _apiProvider.post("/request", payload).then((json) {
      taxRates = (json as List).map((i) => TaxRate.fromJson(i)).toList();
    });
    _printLog(taxRates.toString());
    return taxRates;
  }

  /// /tax-classes
  Future<List<TaxClass>> getTaxClasses() async {
    Map<String, dynamic> payload = {};

    _printLog(payload.toString());
    payload = _standardPayload("get", payload, "taxes/classes");

    List<TaxClass> taxClasses = [];
    await _apiProvider.post("/request", payload).then((json) {
      taxClasses = (json as List).map((i) => TaxClass.fromJson(i)).toList();
    });
    _printLog(taxClasses.toString());
    return taxClasses;
  }

  /// /shipping-zone-methods
  Future<List<ShippingZoneMethod>> getShippingZoneMethods(int zoneId) async {
    Map<String, dynamic> payload = {};

    _printLog(payload.toString());
    payload = _standardPayload(
        "get", payload, "shipping/zones/" + zoneId.toString() + "/methods");

    List<ShippingZoneMethod> shippingZoneMethods = [];
    await _apiProvider.post("/request", payload).then((json) {
      shippingZoneMethods =
          (json as List).map((i) => ShippingZoneMethod.fromJson(i)).toList();
    });
    _printLog(shippingZoneMethods.toString());
    return shippingZoneMethods;
  }

  /// /shipping-methods
  Future<List<WSShipping>> getShippingMethods() async {
    Map<String, dynamic> payload = {};

    _printLog(payload.toString());
    payload = _standardPayload("get", payload, "ws/shipping_methods");

    List<WSShipping> shippingMethods = [];
    await _apiProvider.post("/ws/shipping_methods", payload).then((json) {
      shippingMethods =
          (json as List).map((i) => WSShipping.fromJson(i)).toList();
    });
    _printLog(shippingMethods.toString());
    return shippingMethods;
  }

  /// /shipping-zones
  Future<List<ShippingZone>> getShippingZones() async {
    Map<String, dynamic> payload = {};
    payload = _standardPayload("get", [], "shipping/zones");

    List<ShippingZone> shippingZones = [];

    await _apiProvider.post("/request", payload).then((json) {
      shippingZones =
          (json as List).map((i) => ShippingZone.fromJson(i)).toList();
    });
    _printLog(shippingZones.toString());
    return shippingZones;
  }

  /// /shipping-zones#retrive-a-shipping-zone
  Future<ShippingZone> retrieveShippingZone(int id) async {
    Map<String, dynamic> payload = {};
    payload =
        _standardPayload("get", payload, "shipping/zones/" + id.toString());

    ShippingZone shippingZone;
    await _apiProvider.post("/request", payload).then((json) {
      shippingZone = ShippingZone.fromJson(json);
    });
    _printLog(shippingZone.toString());
    return shippingZone;
  }

  Future<Map<String, dynamic>> stripePaymentIntent(
      {String amount,
      String desc,
      String email,
      Map<String, dynamic> shipping}) async {
    Map<String, dynamic> payload = {
      "amount": amount,
      "receipt_email": email,
      "shipping": shipping,
      "desc": desc,
      "path": "order/pi",
      "type": "post"
    };
    Map<String, dynamic> payloadRsp = {};
    await _apiProvider.post("/order/pi", payload).then((json) {
      payloadRsp = json;
    });
    _printLog(payloadRsp.toString());
    return payloadRsp;
  }

  Future<List<dynamic>> cartCheck(List<Map<String, dynamic>> cartLines) async {
    // Map<String, dynamic> payload = {};
    // payload = _standardPayload("get", cartLines, "ws/cart_check");

    // List<dynamic> payloadRsp = [];
    // await _apiProvider.post("/ws/cart_check", payload).then((json) {
    //   payloadRsp = json;
    // });
    // _printLog(payloadRsp.toString());
    return cartLines;
  }
}