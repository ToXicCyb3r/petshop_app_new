import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<SearchSuggestion> searchSuggestions = [
    SearchSuggestion(
      name: 'Happy Pets & Grooming',
      price: '250.000',
      services: ['Grooming', 'Makanan Hewan'],
      location: 'Jl. Raya Kby Lama - Jakarta Barat',
      locationUrl: 'https://goo.gl/maps/pK5uE6wMjSwoxihP7',
    ),
    SearchSuggestion(
      name: 'Jakarta Petshop',
      price: '200.000',
      services: ['Klinik Hewan', 'Penitipan Hewan'],
      location: 'Jl. Anggrek Garuda D/I - Jakarta Pusat',
      locationUrl: 'https://goo.gl/maps/Qt4DZJjGNL9vSjtK6',
    ),
    SearchSuggestion(
      name: 'Joe Petshop',
      price: '300.000',
      services: ['Grooming', 'Klinik Hewan'],
      location: 'Jl. Gajah Mada, No. 19/26 - Jakarta Pusat ',
      locationUrl: 'https://goo.gl/maps/pNVbHyG1ocgXCyPA8',
    ),
    SearchSuggestion(
      name: 'Mocca Petshop & Clinic',
      price: '150.000',
      services: ['Grooming', 'Klinik Hewan'],
      location: 'Jl. Howitzer Raya, No. 49 - Jakarta Pusat ',
      locationUrl: 'https://goo.gl/maps/bqK52BiS52EkwANn7',
    ),
    // Tambahkan petshop lainnya dengan properti locationUrl yang sesuai
  ];

  List<SearchSuggestion> searchResults = [];

  void _performSearch(String query) {
    setState(() {
      searchResults = searchSuggestions
          .where((suggestion) =>
              suggestion.name.toLowerCase().contains(query.toLowerCase()) ||
              suggestion.price.toLowerCase().contains(query.toLowerCase()) ||
              suggestion.services.any((service) =>
                  service.toLowerCase().contains(query.toLowerCase())) ||
              suggestion.location.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _openMaps(SearchSuggestion suggestion) async {
    try {
      List<Location> locations = await locationFromAddress(suggestion.location);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        String mapsUrl = suggestion.locationUrl
            .replaceFirst('latitude', location.latitude.toString())
            .replaceFirst('longitude', location.longitude.toString());
        if (await canLaunch(mapsUrl)) {
          await launch(mapsUrl);
        } else {
          throw 'Could not open the map.';
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'SEARCH',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    String query = _searchController.text;
                    _performSearch(query);
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Search Suggestions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (BuildContext context, int index) {
                  final suggestion = searchResults[index];
                  return ListTile(
                    title: Text(suggestion.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Harga: ${suggestion.price}'),
                        Text('Layanan: ${suggestion.services.join(', ')}'),
                        Text('Lokasi: ${suggestion.location}'),
                      ],
                    ),
                    onTap: () {
                      _openMaps(suggestion);
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.location_on),
                      onPressed: () {
                        _openMaps(suggestion);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchSuggestion {
  String name;
  String price;
  List<String> services;
  String location;
  String locationUrl;

  SearchSuggestion({
    required this.name,
    required this.price,
    required this.services,
    required this.location,
    required this.locationUrl,
  });
}
