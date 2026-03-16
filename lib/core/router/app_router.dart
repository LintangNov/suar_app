import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/onboarding_provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref){
  final hasCompletedOnboarding = ref.watch(onboardingStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,

    redirect: (context, state){
      final isGoingToOnboarding = state.uri.path == '/onboarding';
      if (!hasCompletedOnboarding && !isGoingToOnboarding) {
        return '/onboarding';
      }

      if (hasCompletedOnboarding && isGoingToOnboarding){
        return '/';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title:  const Text('SUAR - Setup'),),
          body: Center(
            child: ElevatedButton(
              onPressed: (){
                ref.read(onboardingStateProvider.notifier).completeOnboarding();
              },
              child: const Text('Selesaikan Onboarding'),
            ),
          ),
        ),
      ),

      // Map & EWS Route
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('SUAR - Peta & EWS')),
          body: Center(
            child: ElevatedButton(
              onPressed: () => context.push('/chat'),
              child: const Text('Buka Mesh Chat (Offline)'),
            ),
          ),
        ),
      ),

      // Offline mesh chat route
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Public Channel (Mesh)')),
          body: Center(
            child: ElevatedButton(
              // Contoh passing parameter ID ke halaman Direct Message
              onPressed: () => context.push('/chat/dm/user_123'), 
              child: const Text('Chat Private dengan Budi'),
            ),
          ),
        ),
        routes: [
          // Sub-route untuk Direct Message
          GoRoute(
            path: 'dm/:peerId',
            name: 'direct_message',
            builder: (context, state) {
              // Menangkap parameter dari URL
              final peerId = state.pathParameters['peerId']!;
              return Scaffold(
                appBar: AppBar(title: const Text('Private Chat')),
                body: Center(child: Text('Chatting dengan: $peerId')),
              );
            },
          ),
        ],
      ),
    ],
  );
});