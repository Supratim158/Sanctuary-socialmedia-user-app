import 'package:chat_plugin/chat_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sanctuary/core/themes.dart';
import 'package:sanctuary/entry_page.dart';
import 'package:sanctuary/screen/authenticaton/login_screen.dart';
import 'package:sanctuary/screen/authenticaton/register_screen.dart';
import 'package:sanctuary/screen/authenticaton/otp_verification_screen.dart';
import 'package:sanctuary/screen/onboarding_screen.dart';
import 'package:sanctuary/services/auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light
      )
  );

  final isLoggedIn = await AuthServices.isLoggedIn();

  if(isLoggedIn == true){
    await AuthServices.initializeChatPlugin();
  }
  runApp(MyApp(isLoggedIn: isLoggedIn,));
}

class MyApp extends StatefulWidget {

  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    if(widget.isLoggedIn){
      WidgetsBinding.instance.addPostFrameCallback((_){
        _ensureChatConnection();
      }
      );
    }
  }

  void _ensureChatConnection() async{
    if(ChatConfig.instance.userId != null){
      try{
        final chatService = ChatPlugin.chatService;

        if(!chatService.isSocketConnected){
          chatService.initGlobalConnection();
        }
        else{
          chatService.refreshGlobalConnection();
        }

        chatService.updateUserStatus(true);
      }
      catch(ex){}
    }

    else{
      AuthServices.initializeChatPlugin();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    if(!widget.isLoggedIn) return;

    if(state == AppLifecycleState.resumed){
      _ensureChatConnection();
    }
    else if(state == AppLifecycleState.paused){
      try{
        final chatService = ChatPlugin.chatService;
        chatService.updateUserStatus(false);
      }
      catch(ex){

      }
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sanctuary',
      theme: AppTheme.darkTheme,
      // home: OnboardingScreen(),
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => InitializerWidget(),
        '/landing': (context) => OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/verify': (context) => OtpVerificationScreen(),
        '/directMessages': (context) => EntryPage(),
      },
    );
  }
}

class InitializerWidget extends StatefulWidget {
  const InitializerWidget({super.key});

  @override
  State<InitializerWidget> createState() => _InitializerWidgetState();
}

class _InitializerWidgetState extends State<InitializerWidget> {

  String? initialRoute;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async{
    final isLoggedIn = await AuthServices.isLoggedIn();

    if(isLoggedIn == true){
      final isVerified = await AuthServices.isVerified();

      if(isVerified){
        initialRoute = '/directMessages';
      } else {
        initialRoute = '/verify';
      }
    }
    else{
      initialRoute = '/landing';
    }
    
    Navigator.of(context).pushReplacementNamed(initialRoute!);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
