part of 'main.dart';

class PurchasePage extends StatefulWidget {
  PurchasePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PurchasePageState createState() => new _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  _loadProducts() async {
    const Set<String> _kIds = {'flat_white_a_month', 'lunch_a_month22'};
    final ProductDetailsResponse response = await InAppPurchaseConnection.instance.queryProductDetails(_kIds);
    if (!response.notFoundIDs.isEmpty) {
      Logger.d("Not found products: ${response.notFoundIDs}");
    }
    List<ProductDetails> products = response.productDetails;
    for (ProductDetails product in products) {
      Logger.d("Product: ${product}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          Navigator.pop(context);
        }),
        title: new Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.content_copy),
            onPressed: () {
              //
            },
          )
        ],
      ),
      body: Text("Hi!"),
    );
  }
}