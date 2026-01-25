import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/application/providers.dart';
import 'package:wishi_app/presentation/widgets/login_bottom_sheet.dart';
import 'package:wishi_app/presentation/viewmodels/profile/profile_state.dart'
    show
        InitialProfileState,
        LoadingProfileState,
        LoadedProfileState,
        ErrorProfileState,
        UnauthenticatedProfileState;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:wishi_app/presentation/views/map_picker_screen.dart'; // Removed

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileViewModelProvider);

    Widget bodyContent;

    if (profileState is InitialProfileState) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (profileState is LoadingProfileState) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (profileState is UnauthenticatedProfileState) {
      bodyContent = LoginBottomSheet(ref: ref);
    } else if (profileState is LoadedProfileState) {
      bodyContent = CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'User Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (profileState.isAnonymous) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(
                                    context,
                                  ).viewInsets.bottom,
                                ),
                                child: LoginBottomSheet(ref: ref),
                              ),
                            );
                          } else {
                            ref
                                .read(profileViewModelProvider.notifier)
                                .signOut();
                          }
                        },
                        child: Text(
                          profileState.isAnonymous ? 'Log In' : 'Sign Out',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (profileState.isAnonymous) ...[
                    Card(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.account_circle,
                              size: 64,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Guest Account',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onTertiaryContainer,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create an account to save your orders, track history, and access exclusive offers.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onTertiaryContainer,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ] else ...[
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return _ProfileEditor(
                          profileState: profileState,
                          ref: ref,
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                  const Text(
                    'Order History',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final completedOrdersAsync = ref.watch(completedOrdersProvider);
              return completedOrdersAsync.when(
                data: (orders) => orders.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No completed orders yet.'),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final order = orders[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text(order.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total: \$${order.total.toStringAsFixed(2)}',
                                    ),
                                    Text(
                                      '${order.items.length} items',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Repeat order feature coming soon!',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }, childCount: orders.length),
                      ),
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (err, stack) => SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Error loading orders: $err'),
                    ),
                  ),
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      );
    } else if (profileState is ErrorProfileState) {
      bodyContent = Center(child: Text('Error: ${profileState.message}'));
    } else {
      bodyContent = const Center(child: Text('Unknown state'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: bodyContent,
      bottomNavigationBar:
          (profileState is LoadedProfileState && profileState.isAnonymous)
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: LoginBottomSheet(ref: ref),
                    ),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('log in'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            )
          : null,
    );
  }
}

// Helper widget for profile editing to keep main screen clean
class _ProfileEditor extends StatefulWidget {
  final LoadedProfileState profileState;
  final WidgetRef ref;

  const _ProfileEditor({
    Key? key,
    required this.profileState,
    required this.ref,
  }) : super(key: key);

  @override
  State<_ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<_ProfileEditor> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  double? _latitude;
  double? _longitude;
  GoogleMapController? _mapController;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.profileState.userProfile;
    _displayNameController = TextEditingController(text: profile.displayName);
    _phoneController = TextEditingController(text: profile.phoneNumber);
    _streetController = TextEditingController(text: profile.streetAddress);
    _cityController = TextEditingController(text: profile.city);
    _stateController = TextEditingController(text: profile.state);
    _zipController = TextEditingController(text: profile.zipCode);
    _latitude = profile.latitude;
    _longitude = profile.longitude;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = widget.profileState.userProfile.copyWith(
        displayName: _displayNameController.text,
        phoneNumber: _phoneController.text,
        streetAddress: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipController.text,
        latitude: _latitude,
        longitude: _longitude,
      );

      widget.ref
          .read(profileViewModelProvider.notifier)
          .updateProfile(updatedProfile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  Future<void> _locateAddress() async {
    final street = _streetController.text.trim();
    final city = _cityController.text.trim();
    final state = _stateController.text.trim();
    final zip = _zipController.text.trim();

    if (street.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least Street and City')),
      );
      return;
    }

    final address = '$street, $city, $state, $zip';
    setState(() => _isLocating = true);

    try {
      if (kIsWeb) {
        // Web Fallback using HTTP to avoid geocoding plugin issues
        // TODO: Move API Key to a secure configuration or env variable
        const apiKey = 'AIzaSyDrp3R_UvuONMaTv5LTl598_dwva-p1UVU';
        final encodedAddress = Uri.encodeComponent(address);
        final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$apiKey',
        );

        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK') {
            final results = data['results'] as List;
            if (results.isNotEmpty) {
              final location = results[0]['geometry']['location'];
              final lat = location['lat'];
              final lng = location['lng'];

              setState(() {
                _latitude = lat;
                _longitude = lng;
              });

              _mapController?.animateCamera(
                CameraUpdate.newLatLng(LatLng(lat, lng)),
              );
            } else {
              throw Exception('No results found for this address.');
            }
          } else {
            throw Exception(
              'Geocoding API Error: ${data['status']} - ${data['error_message'] ?? ''}',
            );
          }
        } else {
          throw Exception('HTTP Error: ${response.statusCode}');
        }
      } else {
        // Mobile Implementation
        List<Location> locations = await locationFromAddress(address);

        if (locations.isNotEmpty) {
          final location = locations.first;
          final lat = location.latitude;
          final lng = location.longitude;

          setState(() {
            _latitude = lat;
            _longitude = lng;
          });

          // Animate map to new location
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(LatLng(lat, lng)),
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not find location for address'),
              ),
            );
          }
        }
      }
    } catch (e, stackTrace) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 10),
            action: SnackBarAction(
              label: 'Details',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error Details'),
                    content: SingleChildScrollView(
                      child: SelectableText('$e\n\n$stackTrace'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  // Future<void> _openMapPicker() async { ... } // Removed

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.profileState.userProfile.photoUrl != null)
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    widget.profileState.userProfile.photoUrl!,
                  ),
                )
              else
                const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person, size: 30),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.profileState.userProfile.email,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Update your details below',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _displayNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          Text('Address', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _streetController,
            decoration: const InputDecoration(
              labelText: 'Street Address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.home_outlined),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: 'State',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _zipController,
            decoration: const InputDecoration(
              labelText: 'Zip Code',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLocating ? null : _locateAddress,
              icon: _isLocating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(
                _isLocating ? 'Locating...' : 'Update Map from Address',
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_latitude != null && _longitude != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Location Selected: $_latitude, $_longitude',
                style: const TextStyle(color: Colors.green),
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            'Pin your exact location',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 250,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (kIsWeb ||
                      defaultTargetPlatform == TargetPlatform.android ||
                      defaultTargetPlatform == TargetPlatform.iOS)
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: (_latitude != null && _longitude != null)
                            ? LatLng(_latitude!, _longitude!)
                            : const LatLng(
                                19.4326,
                                -99.1332,
                              ), // Default fallback
                        zoom: 15,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      onCameraMove: (position) {
                        // Update state without setState to avoid frequently rebuilding the whole form
                        // unless we want real-time coordinate display.
                        _latitude = position.target.latitude;
                        _longitude = position.target.longitude;
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      // EagerGestureRecognizer allows map to capture gestures inside ScrollView
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                    )
                  else
                    Container(
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Map view is only supported on Android, iOS, and Web.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  const Icon(Icons.location_pin, size: 40, color: Colors.red),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: const Text('Save Profile'),
            ),
          ),
        ],
      ),
    );
  }
}
