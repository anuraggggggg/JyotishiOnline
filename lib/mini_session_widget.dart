import 'package:AstrowayCustomer/views/chat/newChatScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'controllers/call_session_controller.dart';

class MiniSessionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final session = CallSessionController.instance;

    if (!session.isActive) return SizedBox();

    return Positioned(
      bottom: 100,
      right: 20,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CustomerChatPage(
                roomId: session.roomId,
                astrologerUserId: "",
                astrologerProfileId: "",
                myUserId: "",
                astrologerName: "Chat",
              ),
            ),
          );
        },
        child: Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Icon(Icons.call, color: Colors.white, size: 40),
          ),
        ),
      ),
    );
  }
}
