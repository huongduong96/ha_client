part of '../main.dart';

class PurchasePage extends StatefulWidget {
  PurchasePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PurchasePageState createState() => new _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {

  bool _loaded = false;
  String _error = "";


  @override
  void initState() {
    super.initState();
    if (PremiumFeaturesManager().products.isEmpty) {
      _error = "Subscription is not loaded";
    } else {
      _loaded = true;
    }
  }

  Widget _buildProducts() {
    List<Widget> productWidgets = [];
    for (ProductDetails product in PremiumFeaturesManager().products) {
      productWidgets.add(
        ProductPurchase(
          product: product,
          onBuy: (product) => _buyProduct(product),
          purchased: PremiumFeaturesManager().purchases.any((purchase) { return purchase.productID == product.id;}),)
      );
    }
    return ListView(
        scrollDirection: Axis.vertical,
        children: productWidgets
      );
  }

  void _buyProduct(ProductDetails product) {
    Logger.d("Starting purchase of ${product.id}");
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    InAppPurchaseConnection.instance.buyNonConsumable(purchaseParam: purchaseParam);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (!_loaded) {
      body = _error.isEmpty ? PageLoadingIndicator() : PageLoadingError(errorText: _error);
    } else {
      body = _buildProducts();
    }
    return new Scaffold(
      appBar: new AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          Navigator.pop(context);
        }),
        title: new Text(widget.title),
      ),
      body: body,
    );
  }
  
}