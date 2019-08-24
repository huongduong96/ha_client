part of 'main.dart';

class PurchasePage extends StatefulWidget {
  PurchasePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PurchasePageState createState() => new _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  
  bool _loaded = false;
  List<ProductDetails> _products;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  _loadProducts() async {
    const Set<String> _kIds = {'flat_white_a_month', 'lunch_a_month'};
    final ProductDetailsResponse response = await InAppPurchaseConnection.instance.queryProductDetails(_kIds);
    if (!response.notFoundIDs.isEmpty) {
      Logger.d("Not found products: ${response.notFoundIDs}");
    }
    _products = response.productDetails;
    for (ProductDetails product in _products) {
      Logger.d("Product: ${product}");
    }
    setState(() {
      _loaded = true;
    });
  }
  
  Widget _buildLoading() {
    return Text("Loading...");
  }
  
  Widget _buildProducts() {
    List<Widget> productWidgets = [];
    for (ProductDetails product in _products) {
      productWidgets.add(
        _buildProduct(product)
      );
    }
    return ListView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(10.0),
        children: productWidgets
      );
  }
  
  Widget _buildProduct(ProductDetails product) {
    return Card(
        child: Flex(
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.max,
          
          children: <Widget>[
            Column(
              children: <Widget>[
                Text("${product.title}"),
                Text("${product.price}")
              ],
            ),
            FlatButton(
              child: Text("Buy"),
              onPressed: () => Logger.d("Buy!"),
            )
          ],
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (!_loaded) {
      body = _buildLoading();
    } else {
      body = _buildProducts();
    }
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
      body: body,
    );
  }
  
}