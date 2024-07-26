import 'package:firebase_ui_auth/firebase_ui_auth.dart'; // new
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';               // new
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';                 // new

import 'app_state.dart';                                 // new
import 'mapbase.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: ((context, child) => const MyApp()),
  ));
}

final _router = GoRouter(routes: [
  GoRoute(path: '/', builder: (context, state) => const MyHomePage(), routes: [
    GoRoute(
      path: 'sign-in',
      builder: (context, state) {
        return SignInScreen(
          actions: [
            ForgotPasswordAction(((context, email) {
              final uri = Uri(
                path: '/sign-in/forgot-password',
                queryParameters: <String, String?>{
                  'email': email,
                },
              );
              context.push(uri.toString());
            })),
            AuthStateChangeAction(((context, state) {
              final user = switch (state) {
                SigningIn state => state.user,
                UserCreated state => state.credential.user,
                _ => null
              };
              if (user == null) {
                return;
              }
              if (state is UserCreated) {
                user.updateDisplayName(user.email!.split('@')[0]);
              }
              if (!user.emailVerified) {
                user.sendEmailVerification();
                snackBar = const SnackBar(
                  content: Text(
                      'Please check your email to verify your email address'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
              context.pushReplacement('/');
            })),
          ],
        );
      },
      routes: [
        GoRoute(
          path: 'forgot-password',
          builder: (context, state) {
            final arguments = state.uri.queryParameters;
            return ForgotPasswordScreen(
              email: arguments['email'],
              headerMaxExtent: 200,
            );
          },
        ),
      ],
    ),
    GoRoute(
        path: 'profile',
        builder: (context, state) {
          return ProfileScreen(
            providers: const [],
            actions: [
              SignedOutAction((context) {
                context.pushReplacement('/');
              }),
            ],
          );
        })
  ])
]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'basemap',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
              highlightColor: Colors.deepPurple,
            ),
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: _router,
    );
  }
}
