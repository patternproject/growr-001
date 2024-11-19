import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key, required this.title});

  final String title;

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  late String userEmail;
  late Stream<QuerySnapshot> servicesStream;
  List<SalonService> _services = [];

  @override
  void initState() {
    super.initState();
    // Get the logged-in user's email
    userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    // Fetch the services for the logged-in user from Firestore
    servicesStream = FirebaseFirestore.instance
        .collection('services')
        .where('user_email', isEqualTo: userEmail) // Filter by user's email
        .snapshots();
  }

  bool _selectAll = false;

  // Toggle the 'Select All' checkbox
  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      for (var service in _services) {
        service.isSelected = _selectAll;
      }
    });
  }

  // Toggle the selection of an individual service
  void _toggleRowSelection(SalonService service, bool? value) {
    setState(() {
      service.isSelected = value ?? false;
      _selectAll = _services.every((service) => service.isSelected);
    });
  }

  // Add a new service
  void _addRow() {
    setState(() {
      _services.add(SalonService(
        id: _services.length.toString(),
        name: 'New Service',
        duration: 'Duration',
        price: 'Price',
      ));
    });
  }

  // Delete a service by ID
  void _deleteService(String id) {
    setState(() {
      _services.removeWhere((row) => row.id == id);
    });
  }

  // Edit a service
  void _editRow(SalonService service) {
    _showAddUpdateServiceForm(service);
  }

  // Delete a service
  void _deleteRow(SalonService service) {
    setState(() {
      _services.remove(service);
    });
  }

  // Share a service
  void _shareRow(SalonService service) {
    print('Sharing row: ${service.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
            icon: const Icon(
              Icons.home,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: servicesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No services found.'));
                }

                final serviceDocuments = snapshot.data!.docs;

                // Convert snapshot data into SalonService objects
                _services = serviceDocuments.map((doc) {
                  return SalonService.fromFirestore(doc);
                }).toList();

                return ListView.builder(
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return _buildTableRow(service);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddUpdateServiceForm(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Checkbox(
            value: _selectAll,
            onChanged: _toggleSelectAll,
          ),
          _headerCell('Name', flex: 4),
          _headerCell('Duration', flex: 2),
          _headerCell('Price', flex: 2),
          _headerCell(''),
        ],
      ),
    );
  }

  Widget _buildTableRow(SalonService service) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: service.isSelected,
            onChanged: (value) => _toggleRowSelection(service, value),
          ),
          _dataCell(service.name, flex: 4),
          _dataCell(service.duration, flex: 2),
          _dataCell(service.price, flex: 2),
          _actionButtons(service),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _dataCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(fontSize: 20),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _actionButtons(SalonService service) {
    return Align(
      alignment: Alignment.centerRight,
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) {
          if (value == 'edit') {
            _editRow(service);
          } else if (value == 'delete') {
            _deleteRow(service);
          } else if (value == 'share') {
            _shareRow(service);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: const [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
            onTap: () {
              _showAddUpdateServiceForm(service);
            },
          ),
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: const [
                Icon(Icons.delete, size: 20),
                SizedBox(width: 8),
                Text('Delete'),
              ],
            ),
            onTap: () {
              _deleteRow(service);
            },
          ),
          PopupMenuItem<String>(
            value: 'share',
            child: Row(
              children: const [
                Icon(Icons.share, size: 20),
                SizedBox(width: 8),
                Text('Share'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _showAddUpdateServiceForm(SalonService? service) {
    if (service != null) {
      // Editing existing row
      _nameController.text = service.name;
      _durationController.text = service.duration;
      _priceController.text = service.price;
    } else {
      // Adding new row
      _nameController.clear();
      _durationController.clear();
      _priceController.clear();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add/Update Service'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Service Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a service name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(labelText: 'Duration'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a duration';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  final name = _nameController.text;
                  final duration = _durationController.text;
                  final price = _priceController.text;

                  if (service == null) {
                    // Adding a new service
                    try {
                      await FirebaseFirestore.instance.collection('services').add({
                        'name': name,
                        'duration': duration,
                        'price': price,
                        'user_email': userEmail, // Associate with the logged-in user
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Service added successfully!')),
                      );
                    } catch (e) {
                      print('Error adding service: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error adding service: $e')),
                      );
                    }
                  } else {
                    // Updating an existing service
                    try {
                      await FirebaseFirestore.instance
                          .collection('services')
                          .doc(service.id)
                          .update({
                        'name': name,
                        'duration': duration,
                        'price': price,
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Service updated successfully!')),
                      );
                    } catch (e) {
                      print('Error updating service: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating service: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }


  void _showAddUpdateServiceForm2(SalonService? service) {
    log(service != null ? service.name : 'no service passed');
    if (service != null) {
      // Editing existing row
      _nameController.text = service.name;
      _durationController.text = service.duration;
      _priceController.text = service.price;
    } else {
      // Adding new row
      _nameController.clear();
      _durationController.clear();
      _priceController.clear();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add/Update Service'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Service Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a service name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(labelText: 'Duration'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a duration';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  // Add or update the service
                  final name = _nameController.text;
                  final duration = _durationController.text;
                  final price = _priceController.text;

                  if (service == null) {
                    _addRow();
                  } else {
                    service.name = name;
                    service.duration = duration;
                    service.price = price;
                  }

                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
}

class SalonService {
  String id;
  String name;
  String duration;
  String price;
  bool isSelected;

  SalonService({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    this.isSelected = false,
  });

  factory SalonService.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SalonService(
      id: doc.id,
      name: data['name'],
      duration: data['duration'],
      price: data['price'],
      isSelected: data['isSelected'] ?? false,
    );
  }
}
