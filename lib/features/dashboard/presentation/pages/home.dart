import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:carousel_slider/carousel_slider.dart';

import 'package:rakhsa/camera.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/features/news/persentation/pages/detail.dart';

import 'package:rakhsa/websockets.dart';

class HomePage extends StatefulWidget {
  final GlobalKey<ScaffoldState> globalKey;
  const HomePage({
    required this.globalKey,
    super.key
  });

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  Completer<GoogleMapController> mapsC = Completer();

  List<Marker> _markers = [];
  List<Marker> get markers => [..._markers];

  late WebSocketsService webSocketsService;
  late DashboardNotifier dashboardNotifier;
  late ProfileNotifier profileNotifier;

  String currentAddress = "";
  String currentCountry = "";
  String currentLat = "";
  String currentLng = "";

  bool loadingCurrentAddress = true;

  Future<void> getData() async {
    if(!mounted) return;
      profileNotifier.getProfile();

    if(!mounted) return;
      dashboardNotifier.getNews();
  }

  Future<void> checkAndGetLocation() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationServiceEnabled) {
      if(mounted) {
        showDialog(
        context: context,
        barrierDismissible: false,  
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Location Services Disabled'),
            content: const Text('Please enable location services to continue.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();  
                  Geolocator.openLocationSettings();  
                },
                child: const Text('Open Settings'),
              ),
            ],
          );
        },
      );
      }
    } else {
      getCurrentLocation();
    }
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Future.delayed(const Duration(seconds: 1), () {
          checkAndGetLocation();
        });
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      forceAndroidLocationManager: true
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    String country = placemarks[0].country ?? "-";
    String street = placemarks[0].street ?? "-";
    String administrativeArea = placemarks[0].administrativeArea ?? "-";
    String subadministrativeArea = placemarks[0].subAdministrativeArea ?? "-"; 

    String address = "$administrativeArea $subadministrativeArea\n$street, $country";

    setState(() {
      currentAddress = address;
      currentCountry = country;

      currentLat = position.latitude.toString();
      currentLng = position.longitude.toString();

      _markers = [];
      _markers.add(
        Marker(
          markerId: const MarkerId("currentPosition"),
          position: LatLng(
            position.latitude, 
            position.longitude
          ),
          icon: BitmapDescriptor.defaultMarker,
        )
      );
      
      loadingCurrentAddress = false;
    });
  }

  @override
  void initState() {
    super.initState();

    webSocketsService = context.read<WebSocketsService>();
    dashboardNotifier = context.read<DashboardNotifier>();
    profileNotifier = context.read<ProfileNotifier>();

    Future.microtask(() => getData());

    checkAndGetLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Provider.of<WebSocketsService>(context);

    return Scaffold(
      body: Consumer<ProfileNotifier>(
        builder: (BuildContext context, ProfileNotifier notifier, Widget? child) {
          if(notifier.providerState == ProviderState.loading) {
            return const Center(
              child: SizedBox(
                width: 16.0,
                height: 16.0,
                child: CircularProgressIndicator()
              ),
            );
          }
           if(notifier.providerState == ProviderState.error) {
            return Center(
              child: Text(notifier.message,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: ColorResources.black
                ),
              ),
            );
          }
          return SafeArea(
            child: RefreshIndicator.adaptive(
              onRefresh: () {
                return Future.sync(() {
                  getData();
                });
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(
                    top: 16.0,
                    left: 14.0,
                    right: 14.0,
                    bottom: 16.0
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                  
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Selamat datang",
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: ColorResources.hintColor
                                ),
                              ), 
                              Text(notifier.profileModel.data?.username ?? "-",
                                style: robotoRegular.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: Dimensions.fontSizeExtraLarge
                                ),
                              )
                            ],
                          ),

                          GestureDetector(
                            onTap: () {
                              widget.globalKey.currentState?.openDrawer();
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                
                                CachedNetworkImage(
                                  imageUrl: notifier.profileModel.data?.avatar ?? "-",
                                  imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                    return CircleAvatar(
                                      backgroundImage: imageProvider,
                                    );
                                  },
                                  placeholder: (BuildContext context, String url) {
                                    return const CircleAvatar(
                                      backgroundImage: AssetImage('assets/images/default.jpeg'),
                                    );
                                  },
                                  errorWidget: (BuildContext context, String url, Object error) {
                                    return const CircleAvatar(
                                      backgroundImage: AssetImage('assets/images/default.jpeg'),
                                    );
                                  },
                                )
                            
                              ],
                            ),
                          )
                  
                        ],
                      ),

                      Container(
                        margin: const EdgeInsets.only(
                          top: 30.0
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            
                            Text("Apakah Anda dalam\nkeadaan darurat ?",
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeOverLarge,
                                fontWeight: FontWeight.bold
                              ),
                            )

                          ]
                        )
                      ),

                      Container(
                        margin: const EdgeInsets.only(
                          top: 20.0
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            
                            Text("Tekan dan tahan tombol ini, maka bantuan\nakan segera hadir",
                              textAlign: TextAlign.center,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: ColorResources.hintColor
                              ),
                            )

                          ],
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.only(
                          top: 55.0
                        ),
                        child: SosButton(
                          location: currentAddress,
                          country: currentCountry,
                          lat: currentLat,
                          lng: currentLng,
                        )
                      ),

                      Consumer<DashboardNotifier>(
                        builder: (BuildContext context, DashboardNotifier notifier, Widget? child) {
                          
                          if(notifier.state == ProviderState.loading) {
                            return const SizedBox(
                              height: 200.0,
                              child: Center(
                                child: SizedBox(
                                  width: 16.0,
                                  height: 16.0,
                                  child: CircularProgressIndicator()
                                )
                              ),
                            );
                          }

                          if(notifier.state == ProviderState.error) {
                            return SizedBox(
                              height: 200.0,
                              child: Center(
                                child: Text(notifier.message,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: ColorResources.black
                                  ),
                                )
                              )
                            );
                          }
                          
                          return Container(
                            margin: const EdgeInsets.only(
                              top: 45.0,
                            ),
                            child: CarouselSlider(
                              options: CarouselOptions(
                                autoPlay: true,
                                height: 175.0,
                                viewportFraction: 1.0
                              ),
                              items: notifier.news.map((item) {
                                if(item.id == 0) {
                                  return Card(
                                    color: ColorResources.white,
                                    surfaceTintColor: ColorResources.white,
                                    elevation: 1.0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                                                  
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                                  
                                                CachedNetworkImage(
                                                  imageUrl: profileNotifier.profileModel.data!.avatar.toString(),
                                                  imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                                    return CircleAvatar(
                                                      backgroundImage: imageProvider,
                                                    );
                                                  },
                                                  placeholder: (BuildContext context, String url) {
                                                    return const CircleAvatar(
                                                      backgroundImage: AssetImage('assets/images/default.jpeg'),
                                                    );
                                                  },
                                                  errorWidget: (BuildContext context, String url, Object error) {
                                                    return const CircleAvatar(
                                                      backgroundImage: AssetImage('assets/images/default.jpeg'),
                                                    );
                                                  },
                                                ),
                                                                  
                                                const SizedBox(width: 15.0),
                                                                  
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                                  
                                                      Text("Posisi Anda saat ini",
                                                        style: robotoRegular.copyWith(
                                                          fontSize: Dimensions.fontSizeDefault,
                                                          fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                                  
                                                      const SizedBox(height: 4.0),
                                                  
                                                      Text(loadingCurrentAddress 
                                                        ? "Mohon tunggu..." 
                                                        : currentAddress,
                                                        style: robotoRegular.copyWith(
                                                          fontSize: Dimensions.fontSizeSmall,
                                                          color: ColorResources.black
                                                        ),
                                                      )
                                                  
                                                    ],
                                                  ),
                                                )
                                                                  
                                              ],
                                            ),
                                        
                                            Container(
                                              width: double.infinity,
                                              height: 180.0,
                                              margin: const EdgeInsets.only(
                                                top: 16.0,
                                                left: 16.0, 
                                                right: 16.0
                                              ),
                                              child: loadingCurrentAddress 
                                              ? const SizedBox() 
                                              : GoogleMap(
                                                mapType: MapType.normal,
                                                gestureRecognizers: {}..add(Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer())),
                                                myLocationEnabled: false,
                                                initialCameraPosition: CameraPosition(
                                                  target: LatLng(
                                                    double.parse(currentLat), 
                                                    double.parse(currentLng)
                                                  ),
                                                  zoom: 15.0,
                                                ),
                                                markers: Set.from(markers),
                                                onMapCreated: (GoogleMapController controller) {
                                                  mapsC.complete(controller);
                                                },
                                              ),
                                            )
                                                                  
                                          ],
                                        ),
                                      ),
                                    )
                                  );
                                }
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, 
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return NewsDetailPage(
                                            title: item.title.toString(), 
                                            img: item.img.toString(), 
                                            desc: item.desc.toString()
                                          );
                                        },
                                      )
                                    );
                                  },
                                  child: Card(
                                    color: ColorResources.white,
                                    surfaceTintColor: ColorResources.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    ),
                                    elevation: 1.0,
                                    child: CachedNetworkImage(
                                      imageUrl: item.img.toString(),
                                      imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            image: DecorationImage(
                                              fit: BoxFit.fitWidth,
                                              image: imageProvider,
                                            ),
                                          ),
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.5),
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: [
                                                        Flexible(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Text(
                                                                item.title.toString(),
                                                                style: robotoRegular.copyWith(
                                                                  color: ColorResources.white,
                                                                  fontSize: Dimensions.fontSizeDefault,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 4.0),
                                                              Text(
                                                                item.desc.toString(),
                                                                style: robotoRegular.copyWith(
                                                                  color: ColorResources.white,
                                                                  fontSize: Dimensions.fontSizeSmall,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      placeholder: (BuildContext context, String url) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            image: const DecorationImage(
                                              fit: BoxFit.fitWidth,
                                              image: AssetImage('assets/images/default.jpeg'),
                                            ),
                                          ),
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.5),
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: [
                                                        Flexible(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Text(
                                                                item.title.toString(),
                                                                style: robotoRegular.copyWith(
                                                                  color: ColorResources.white,
                                                                  fontSize: Dimensions.fontSizeDefault,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 4.0),
                                                              Text(
                                                                item.desc.toString(),
                                                                style: robotoRegular.copyWith(
                                                                  color: ColorResources.white,
                                                                  fontSize: Dimensions.fontSizeSmall,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      errorWidget: (BuildContext context, String url, Object error) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            image: const DecorationImage(
                                              fit: BoxFit.fitWidth,
                                              image: AssetImage('assets/images/default.jpeg'),
                                            ),
                                          ),
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.5),
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: [
                                                        Flexible(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Text(
                                                                item.title.toString(),
                                                                style: robotoRegular.copyWith(
                                                                  color: ColorResources.white,
                                                                  fontSize: Dimensions.fontSizeDefault,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 4.0),
                                                              Text(
                                                                item.desc.toString(),
                                                                style: robotoRegular.copyWith(
                                                                  color: ColorResources.white,
                                                                  fontSize: Dimensions.fontSizeSmall,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }
                      )
                  
                    ],
                  ),
                )
              ),
            ),
          );
        },
      ) 
    );
  }
}

class SosButton extends StatefulWidget {
  final String location;
  final String country;
  final String lat;
  final String lng;

  const SosButton({
    required this.location,
    required this.country,
    required this.lat, 
    required this.lng,
    super.key
  });

  @override
  SosButtonState createState() => SosButtonState();
}

class SosButtonState extends State<SosButton> with TickerProviderStateMixin {

  late AnimationController pulseController;
  late AnimationController timerController;  

  late Animation<double> pulseAnimation;

  late int countdownTime;

  bool isPressed = false;
  Timer? holdTimer;

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    pulseAnimation = Tween<double>(begin: 1.0, end: 2.5).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeOut),
    );

    timerController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );
  }

  void handleLongPressStart() {
    pulseController.forward();

    holdTimer = Timer(const Duration(milliseconds: 2000), () {
      pulseController.reverse();
      if (mounted) {
        startTimer();
      }
    });
  }

  void handleLongPressEnd() {
    if (holdTimer?.isActive ?? false) {
      holdTimer?.cancel();
      pulseController.reverse();
    } else if (!isPressed) {
      setState(() => isPressed = false);
    }
  }

  void startTimer() {
    DateTime now = DateTime.now();
    String time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    // context.read<WebSocketsService>().sos(
    //   location: widget.location,
    //   country: widget.country,
    //   lat: widget.lat,
    //   lng: widget.lng,
    //   time: time
    // );

    Navigator.push(context, 
      MaterialPageRoute(builder: (context) {
        return CameraPage(
          location: widget.location, 
          country: widget.country, 
          lat: widget.lat, 
          lng: widget.lng, 
          time: time
        ); 
      })
    ).then((_) {

      setState(() {
        isPressed = true;
        countdownTime = 60; 
      });

      timerController
      ..reset()
      ..forward().whenComplete(() {
        setState(() => isPressed = false);
        pulseController.reverse();
      });

      timerController.addListener(() {
        setState(() {
          countdownTime = (60 - (timerController.value * 60)).round();
        });
      });

    });

  }

  @override
  void dispose() {
    pulseController.dispose();
    timerController.dispose();
    
    holdTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (double scaleFactor in [0.8, 1.2, 1.4])
            AnimatedBuilder(
              animation: pulseAnimation,
              builder: (BuildContext context, Widget? child) {
                return Transform.scale(
                  scale: pulseAnimation.value * scaleFactor,
                  child: Container(
                    width: 55, 
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFE1717).withOpacity(0.2 / scaleFactor),
                    ),
                  ),
                );
              },
            ),
          if (isPressed)
            SizedBox(
              width: 145,
              height: 145,
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1FFE17)),
                strokeWidth: 6,
                value: 1 - timerController.value,
                backgroundColor: Colors.transparent,
              ),
            ),
          GestureDetector(
            onLongPressStart: (_) => handleLongPressStart(),
            onLongPressEnd: (_) => handleLongPressEnd(),
            child: AnimatedBuilder(
              animation: timerController,
              builder: (BuildContext context, Widget? child) {
                return Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFE1717),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFE1717).withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isPressed ? "$countdownTime" : "SOS",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}