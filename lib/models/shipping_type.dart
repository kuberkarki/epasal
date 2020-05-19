

import '../models/shipping_method.dart';

import '../helpers/tools.dart';

class ShippingType {
  String methodId;
  String cost;
  dynamic object;

  ShippingType({this.methodId, this.object, this.cost});

  Map<String, dynamic> toJson() =>
      {'methodId': methodId, 'object': object, 'cost': cost};

  String getTotal({bool withFormatting}) {
    if (this.methodId != null && this.object != null) {
      switch (this.methodId) {
        case "flat_rate":
          FlatRate flatRate = (this.object as FlatRate);
          return (withFormatting == true
              ? formatStringCurrency(total: cost)
              : flatRate.cost);
        case "free_shipping":
          FreeShipping freeShipping = (this.object as FreeShipping);
          return (withFormatting == true
              ? formatStringCurrency(total: cost)
              : freeShipping.cost);
        case "local_pickup":
          LocalPickup localPickup = (this.object as LocalPickup);
          return (withFormatting == true
              ? formatStringCurrency(total: cost)
              : localPickup.cost);
        default:
          return "0";
          break;
      }
    }
    return "0";
  }

  String getTitle() {
    if (this.methodId != null && this.object != null) {
      switch (this.methodId) {
        case "flat_rate":
          FlatRate flatRate = (this.object as FlatRate);
          return flatRate.title;
        case "free_shipping":
          FreeShipping freeShipping = (this.object as FreeShipping);
          return freeShipping.title;
        case "local_pickup":
          LocalPickup localPickup = (this.object as LocalPickup);
          return localPickup.title;
        default:
          return "";
          break;
      }
    }
    return "";
  }

  Map<String, dynamic> toShippingLineFee() {
    if (this.methodId != null && this.object != null) {
      Map<String, dynamic> tmpShippingLinesObj = {};

      switch (this.methodId) {
        case "flat_rate":
          FlatRate flatRate = (this.object as FlatRate);
          tmpShippingLinesObj["method_title"] = flatRate.title;
          tmpShippingLinesObj["method_id"] = flatRate.methodId;
          tmpShippingLinesObj["total"] = this.cost;
          break;
        case "free_shipping":
          FreeShipping freeShipping = (this.object as FreeShipping);
          tmpShippingLinesObj["method_title"] = freeShipping.title;
          tmpShippingLinesObj["method_id"] = freeShipping.methodId;
          tmpShippingLinesObj["total"] = this.cost;
          break;
        case "local_pickup":
          LocalPickup localPickup = (this.object as LocalPickup);
          tmpShippingLinesObj["method_title"] = localPickup.title;
          tmpShippingLinesObj["method_id"] = localPickup.methodId;
          tmpShippingLinesObj["total"] = this.cost;
          break;
        default:
          return null;
          break;
      }
      return tmpShippingLinesObj;
    }

    return null;
  }
}
