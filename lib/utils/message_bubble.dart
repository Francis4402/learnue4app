import 'package:flutter/material.dart';


// class MessageBubble extends StatefulWidget {
//   final String text;
//   final bool isMe;
//
//   const MessageBubble({super.key, required this.text, required this.isMe});
//
//   @override
//   State<MessageBubble> createState() => _MessageBubbleState();
// }
//
// class _MessageBubbleState extends State<MessageBubble>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 200),
//     );
//     _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
//     );
//     _controller.forward();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       child: Align(
//         alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
//         child: ScaleTransition(
//           scale: _scaleAnimation,
//           child: Container(
//             constraints: BoxConstraints(
//               maxWidth: MediaQuery.of(context).size.width * 0.7,
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             decoration: BoxDecoration(
//               color: widget.isMe ? Colors.blue : Colors.grey[300],
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               widget.text,
//               style: TextStyle(
//                 color: widget.isMe ? Colors.white : Colors.black,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class MessageBubble extends StatefulWidget {
  const MessageBubble({super.key});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
