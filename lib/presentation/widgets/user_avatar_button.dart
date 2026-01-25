import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wishi_app/application/providers.dart';
import 'package:wishi_app/presentation/viewmodels/profile/profile_state.dart';
import 'package:wishi_app/presentation/widgets/login_bottom_sheet.dart';
import 'package:wishi_app/presentation/views/profile_screen.dart';

class UserAvatarButton extends ConsumerWidget {
  const UserAvatarButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileViewModelProvider);

    if (profileState is LoadingProfileState) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (profileState is LoadedProfileState) {
      if (profileState.isAnonymous) {
        // Guest User - Show Login Icon
        return IconButton(
          icon: const Icon(Icons.login),
          tooltip: 'Login',
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
        );
      } else {
        // Authenticated User - Show Avatar
        final userInitial = profileState.userProfile.email.isNotEmpty
            ? profileState.userProfile.email[0].toUpperCase()
            : 'U';

        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: profileState.userProfile.photoUrl != null
                ? CachedNetworkImage(
                    imageUrl: profileState.userProfile.photoUrl!,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      radius: 18,
                      backgroundImage: imageProvider,
                    ),
                    placeholder: (context, url) => CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        userInitial,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    errorWidget: (context, url, error) => CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        userInitial,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      userInitial,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
          ),
        );
      }
    }

    // Default/Unauthenticated/Error - Show Login (or nothing depending on error handling strategy)
    // Assuming unauthenticated state should allow login attempt:
    return IconButton(
      icon: const Icon(Icons.login),
      tooltip: 'Login',
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
    );
  }
}
