import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  Product product = Product(
    id: null,
    title: '',
    price: null,
    description: '',
    imageUrl: '',
  );

  EditProductScreen(Product product) {
    if (product != null) this.product = product;
  }

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  Product _editedProduct;

  @override
  void initState() {
    _editedProduct = widget.product;
    _imageFocusNode.addListener(_updateImageUrl);
    _imageUrlController.text = _editedProduct.imageUrl;
    super.initState();
  }

  @override
  void dispose() {
    _imageFocusNode.removeListener(_updateImageUrl);
    _imageFocusNode.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _submit(context) {
    if (_form.currentState.validate()) {
      _form.currentState.save();
      Provider.of<Products>(context, listen: false)
          .updateOrAddProduct(_editedProduct);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit product'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.save), onPressed: () => _submit(context))
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Title',
              ),
              textInputAction: TextInputAction.next,
              initialValue: widget.product.title,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_priceFocusNode);
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please, provide title';
                }
                return null;
              },
              onSaved: (value) {
                _editedProduct = Product(
                  id: _editedProduct.id,
                  title: value,
                  imageUrl: _editedProduct.imageUrl,
                  description: _editedProduct.description,
                  price: _editedProduct.price,
                );
              },
            ),
            TextFormField(
              initialValue: widget.product.price == null
                  ? ''
                  : widget.product.price.toString(),
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              focusNode: _priceFocusNode,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_descriptionFocusNode);
              },
              onSaved: (value) {
                _editedProduct = Product(
                  id: _editedProduct.id,
                  title: _editedProduct.title,
                  imageUrl: _editedProduct.imageUrl,
                  description: _editedProduct.description,
                  price: double.parse(value),
                );
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please, provider price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please, provider valid number';
                }
                if (double.parse(value) <= 0)
                  return 'Please, provide positive number';
              },
            ),
            TextFormField(
              initialValue: widget.product.description,
              decoration: InputDecoration(labelText: 'Description'),
              focusNode: _descriptionFocusNode,
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              onSaved: (value) {
                _editedProduct = Product(
                  id: _editedProduct.id,
                  title: _editedProduct.title,
                  imageUrl: _editedProduct.imageUrl,
                  description: value,
                  price: _editedProduct.price,
                );
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please, provider description';
                }
              },
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  width: 100,
                  height: 100,
                  margin: EdgeInsets.only(
                    top: 10,
                    right: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: _imageUrlController.text.isEmpty
                      ? Container()
                      : FittedBox(
                          child: Image.network(
                            _imageUrlController.text,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Image url'),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(context),
                    controller: _imageUrlController,
                    focusNode: _imageFocusNode,
                    onSaved: (value) {
                      _editedProduct = Product(
                        id: _editedProduct.id,
                        title: _editedProduct.title,
                        imageUrl: value,
                        description: _editedProduct.description,
                        price: _editedProduct.price,
                      );
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please, provider image url';
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
