import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

// Define the data model classes
class MenuItem {
  final String name;
  final double price;
  final File? picture;
  final String details;

  MenuItem({
    required this.name,
    required this.price,
    required this.picture,
    required this.details,
  });
}

class Order {
  final MenuItem item;
  final DateTime dateTime;
  String status;

  Order({required this.item, required this.dateTime, required this.status});
}

// Define the menus and orders
final List<MenuItem> menuItems = [];
final List<Order> orders = [];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OAS Restaurant App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'OpenSans',
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'OAS Restaurant App',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminPage()),
                );
              },
              child: Text(
                'Admin Portal',
                style: TextStyle(fontSize: 20.0),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserPage()),
                );
              },
              child: Text(
                'User Portal',
                style: TextStyle(fontSize: 20.0),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _image;

  Future getImage() async {
    final XFile? pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> addMenuItem() async {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        detailsController.text.isEmpty ||
        _image == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please fill all the fields and select an image.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    final String name = nameController.text;
    final double price = double.parse(priceController.text);
    final String details = detailsController.text;

    // Perform API request to add menu item
    // Replace 'http://example.com' with your actual API endpoint
    const String apiUrl = 'http://localhost:3000/users/{userId}';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'name': name,
        'price': price.toString(),
        'details': details,
        // You might need to adjust the key based on your API requirements
        'image': base64Encode(_image!.readAsBytesSync()),
      },
    );

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Menu item added successfully.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      nameController.clear();
      priceController.clear();
      detailsController.clear();
      setState(() {
        _image = null;
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to add menu item.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Portal'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Menu Item',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: detailsController,
                decoration: InputDecoration(
                  labelText: 'Details',
                ),
                maxLines: null,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: getImage,
                child: Text('Select Image'),
              ),
              SizedBox(height: 8.0),
              if (_image != null) Image.file(_image!),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: addMenuItem,
                child: Text('Add Menu Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserPage extends StatelessWidget {
  Future<List<MenuItem>> getMenuItems() async {
    const String apiUrl = 'http://localhost:3000/users/{userId}';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final List<MenuItem> menuItems = data
          .map((item) => MenuItem(
                name: item['name'],
                price: double.parse(item['price']),
                picture: null,
                details: item['details'],
              ))
          .toList();

      return menuItems;
    } else {
      throw Exception('Failed to fetch menu items');
    }
  }

  Future<void> placeOrder(MenuItem item) async {
    final DateTime now = DateTime.now();

    // Perform API request to submit order
    // Replace 'http://example.com' with your actual API endpoint
    const String apiUrl = 'http://localhost:3000/users/{userId}';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'name': item.name,
        'price': item.price.toString(),
        'details': item.details,
        'dateTime': now.toIso8601String(),
      },
    );

    if (response.statusCode == 200) {
      var context;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Order placed successfully.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      var context;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to place order.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Portal'),
      ),
      body: FutureBuilder<List<MenuItem>>(
        future: getMenuItems(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<MenuItem> menuItems = snapshot.data!;

            return ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final MenuItem item = menuItems[index];
                return ListTile(
                  leading: item.picture != null
                      ? Image.file(item.picture!)
                      : Container(),
                  title: Text(item.name),
                  subtitle: Text('Price: \$${item.price.toStringAsFixed(2)}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      placeOrder(item);
                    },
                    child: Text('Order'),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to fetch menu items'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
