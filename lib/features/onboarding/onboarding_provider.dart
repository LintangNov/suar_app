import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';

class OnboardingNotifier extends Notifier<bool> {
  static const _key = 'is_onboarding_done';

  @override
  bool build(){
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_key) ?? false;
  }

  void completeOnboarding(){
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(_key, true); 
    
    state = true;
  }
}

final onboardingStateProvider = NotifierProvider<OnboardingNotifier, bool>((){
  return OnboardingNotifier();
});