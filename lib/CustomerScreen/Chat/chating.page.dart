/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

final box = Hive.box('folder');
final String? currentUserId = box.get('id');   // <-- your logged-in user

class ChatingPage extends ConsumerStatefulWidget {
  final IO.Socket socket;
  final String senderId;     // currentUserId
  final String receiverId;   // the other side
  final String deliveryId;   // <-- you must pass the deliveryId

  const ChatingPage({
    required this.socket,
    required this.senderId,
    required this.receiverId,
    required this.deliveryId,
    super.key,
  });

  @override
  ConsumerState<ChatingPage> createState() => _ChatingPageState();
}

class _ChatingPageState extends ConsumerState<ChatingPage> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  late IO.Socket _socket;
  String? _lastSentText;               // deduplication
  bool _isLoadingHistory = false;

  // --------------------------------------------------------------
  //  Helper: scroll to bottom
  // --------------------------------------------------------------
  void _scrollToBottom({bool animated = true}) {
    if (!_scrollCtrl.hasClients) return;
    final target = _scrollCtrl.position.maxScrollExtent;
    if (animated) {
      _scrollCtrl.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollCtrl.jumpTo(target);
    }
  }

  // --------------------------------------------------------------
  //  Group messages by date + insert date separators
  // --------------------------------------------------------------
  void _addMessages(List<dynamic> raw) {
    final List<Map<String, dynamic>> incoming = raw
        .map((e) => e as Map<String, dynamic>)
        .toList();

    // sort by timestamp (assume server sends ISO string in `createdAt`)
    incoming.sort((a, b) =>
        DateTime.parse(a['createdAt']).compareTo(DateTime.parse(b['createdAt'])));

    final List<Map<String, dynamic>> grouped = [];
    DateTime? lastDate;

    for (final msg in incoming) {
      final dt = DateTime.parse(msg['createdAt']);
      final dateKey = DateFormat('dd MMM yyyy').format(dt);

      if (lastDate == null || dateKey != DateFormat('dd MMM yyyy').format(lastDate)) {
        grouped.add({'type': 'date', 'date': dateKey});
      }

      grouped.add({
        'type': 'msg',
        'text': msg['message'] ?? '',
        'isSender': msg['senderId'].toString() == widget.senderId,
        'time': DateFormat('hh:mm a').format(dt),
        'createdAt': dt,
      });

      lastDate = dt;
    }

    setState(() {
      _messages.clear();
      _messages.addAll(grouped);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  // --------------------------------------------------------------
  //  Socket listeners
  // --------------------------------------------------------------



  void _setupSocketListeners() {
    // 1. New incoming message (broadcast from server)
    _socket.on('chat:fetch_history', (data) {
      if (data == null) return;

      // Handle both single message (Map) and list of messages (List)
      List<Map<String, dynamic>> incomingMessages = [];

      if (data is Map) {
        incomingMessages.add(Map<String, dynamic>.from(data));
      } else if (data is List) {
        incomingMessages = data
            .where((item) => item is Map)
            .cast<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } else {
        debugPrint('Unexpected data type in chat:fetch_history: ${data.runtimeType}');
        return;
      }

      // Process each message
      for (var msg in incomingMessages) {
        // Avoid double-rendering of the message we just sent
        if (msg['message'] == _lastSentText && msg['senderId'] == widget.senderId) {
          _lastSentText = null;
          continue; // skip this message
        }
        _addMessages([msg]);
      }
    });

    // 2. History response
    _socket.on('chat:history', (data) {
      List<Map<String, dynamic>> historyMessages = [];

      if (data is List) {
        historyMessages = data
            .where((item) => item is Map)
            .cast<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } else if (data is Map) {
        historyMessages.add(Map<String, dynamic>.from(data));
      }

      _addMessages(historyMessages);
      setState(() => _isLoadingHistory = false);
    });

    // 3. Connection events
    _socket.onConnect((_) => debugPrint('Socket connected'));
    _socket.onDisconnect((_) => debugPrint('Socket disconnected'));
    _socket.onConnectError((err) => debugPrint('Connect error: $err'));
  }
  // --------------------------------------------------------------
  //  Join room + fetch history
  // --------------------------------------------------------------
  void _joinAndFetch() {
    // 1. Join
    _socket.emit('chat:join', {
      'deliveryId': widget.deliveryId,
      'userId': widget.senderId,
    });

    // 2. Ask for history
    _socket.emit('chat:fetch_history', {'deliveryId': widget.deliveryId});
    setState(() => _isLoadingHistory = true);
  }

  // --------------------------------------------------------------
  //  Send message
  // --------------------------------------------------------------
  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    final payload = {
      'deliveryId': widget.deliveryId,
      'senderId': widget.senderId,
      'receiverId': widget.receiverId,
      'message': text,
      'messageType': 'text', // you can extend later
    };

    _socket.emit('chat:message', payload);

    // Optimistic UI – show instantly
    final now = DateTime.now();
    final optimistic = {
      'type': 'msg',
      'text': text,
      'isSender': true,
      'time': DateFormat('hh:mm a').format(now),
      'createdAt': now,
    };
    setState(() {
      _messages.add(optimistic);
      _lastSentText = text;
    });
    _msgCtrl.clear();
    _scrollToBottom();
  }

  // --------------------------------------------------------------
  //  Lifecycle
  // --------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _socket = widget.socket;
    _setupSocketListeners();
    _joinAndFetch();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    // leave room (optional)
    _socket.emit('chat:leave', {
      'deliveryId': widget.deliveryId,
      'userId': widget.senderId,
    });
    // Do **NOT** disconnect here if the socket is shared across screens!
    // widget.socket.disconnect();   // <-- remove if socket is global
    super.dispose();
  }

  // --------------------------------------------------------------
  //  UI
  // --------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F7),
      body: Column(
        children: [
          // -------------------- Header --------------------
          SizedBox(
            height: 103.h,
            child: Card(
              color: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Color(0xff010311)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 10.w),

                    SizedBox(width: 10.w),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Adem Electronics',
                            style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff010311))),
                        Text('Online',
                            style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff2FAF0F))),
                      ],
                    ),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.videocam_outlined), onPressed: () {}),
                    // IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
                  ],
                ),
              ),
            ),
          ),

          // -------------------- Chat list --------------------
          Expanded(
            child: _isLoadingHistory
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollCtrl,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final item = _messages[i];
                if (item['type'] == 'date') {
                  return DateSeparator(date: item['date']);
                }
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: ChatBubble(
                    message: item['text'],
                    isSender: item['isSender'],
                    time: item['time'],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // -------------------- Input --------------------
      bottomSheet: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(20.w, 13.h, 20.w, 13.h),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 233, 232, 235),
                  hintText: 'Type Message',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color.fromARGB(255, 140, 140, 148)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            InkWell(
              onTap: _sendMessage,
              child: Container(
                width: 48.w,
                height: 46.h,
                decoration: BoxDecoration(
                  color: const Color(0xff4A3DFE),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
//  DateSeparator & ChatBubble (unchanged – just copied)
// -----------------------------------------------------------------
class DateSeparator extends StatelessWidget {
  final String date;
  const DateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Center(
        child: Text(
          date,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xff606480),
          ),
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSender;
  final String time;

  const ChatBubble(
      {super.key,
        required this.message,
        required this.isSender,
        required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isSender ? const Color(0xff00D0B8) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isSender ? 16.r : 0),
            bottomRight: Radius.circular(isSender ? 0 : 16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment:
          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: GoogleFonts.roboto(
                fontSize: 17.sp,
                fontWeight: FontWeight.w400,
                color: isSender ? Colors.white : const Color(0xFF2B2B2B),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              time,
              style: GoogleFonts.roboto(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: isSender
                    ? Colors.white.withOpacity(0.7)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/


//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:intl/intl.dart';
// import 'package:hive/hive.dart';
//
// final box = Hive.box('folder');
// final String? currentUserId = box.get('id'); // logged-in user id
//
// class ChatingPage extends ConsumerStatefulWidget {
//   final IO.Socket socket;
//   final String senderId; // current user
//   final String receiverId; // chat partner
//   final String deliveryId; // delivery id for chat room
//
//   const ChatingPage({
//     required this.socket,
//     required this.senderId,
//     required this.receiverId,
//     required this.deliveryId,
//     super.key,
//   });
//
//   @override
//   ConsumerState<ChatingPage> createState() => _ChatingPageState();
// }
//
// class _ChatingPageState extends ConsumerState<ChatingPage> {
//   final TextEditingController _msgCtrl = TextEditingController();
//   final ScrollController _scrollCtrl = ScrollController();
//   final List<Map<String, dynamic>> _messages = [];
//
//   late IO.Socket _socket;
//   String? _lastSentText;
//   bool _isLoadingHistory = false;
//
//   // 🔹 Scroll to bottom
//   void _scrollToBottom({bool animated = true}) {
//     if (!_scrollCtrl.hasClients) return;
//     final target = _scrollCtrl.position.maxScrollExtent;
//     if (animated) {
//       _scrollCtrl.animateTo(
//         target,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     } else {
//       _scrollCtrl.jumpTo(target);
//     }
//   }
//
//   // 🔹 Add messages to list with date grouping
//   void _addMessages(List<dynamic> raw) {
//     final List<Map<String, dynamic>> incoming =
//     raw.map((e) => Map<String, dynamic>.from(e)).toList();
//
//     incoming.sort((a, b) =>
//         DateTime.parse(a['createdAt']).compareTo(DateTime.parse(b['createdAt'])));
//
//     final List<Map<String, dynamic>> grouped = [];
//     DateTime? lastDate;
//
//     for (final msg in incoming) {
//       final dt = DateTime.parse(msg['createdAt']);
//       final dateKey = DateFormat('dd MMM yyyy').format(dt);
//
//       if (lastDate == null ||
//           dateKey != DateFormat('dd MMM yyyy').format(lastDate)) {
//         grouped.add({'type': 'date', 'date': dateKey});
//       }
//
//       grouped.add({
//         'type': 'msg',
//         'text': msg['message'] ?? '',
//         'isSender': msg['senderId'].toString() == widget.senderId,
//         'time': DateFormat('hh:mm a').format(dt),
//         'createdAt': dt,
//       });
//
//       lastDate = dt;
//     }
//
//     setState(() {
//       _messages.clear();
//       _messages.addAll(grouped);
//     });
//
//     WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
//   }
//
//   // 🔹 Setup all socket event listeners
//   void _setupSocketListeners() {
//     // When history is received
//     _socket.on('chat:fetch_history', (data) {
//       if (data is List) {
//         _addMessages(data);
//       }
//       setState(() => _isLoadingHistory = false);
//     });
//
//     // When a new message is broadcasted
//     _socket.on('chat:fetch_history', (data) {
//       if (data == null) return;
//       final msg = Map<String, dynamic>.from(data);
//
//       // Avoid showing same message twice
//       if (msg['message'] == _lastSentText &&
//           msg['senderId'].toString() == widget.senderId) {
//         _lastSentText = null;
//         return;
//       }
//
//       _addMessages([msg]);
//     });
//
//     _socket.onConnect((_) => debugPrint('Socket connected'));
//     _socket.onDisconnect((_) => debugPrint('Socket disconnected'));
//     _socket.onConnectError((err) => debugPrint('⚠ Connect error: $err'));
//   }
//
//   // 🔹 Join chat room & fetch chat history
//   void _joinAndFetch() {
//     _socket.emit('chat:join', {
//       'deliveryId': widget.deliveryId,
//       'userId': widget.senderId,
//     });
//
//     _socket.emit('chat:fetch_history', {'deliveryId': widget.deliveryId});
//     setState(() => _isLoadingHistory = true);
//   }
//
//   // 🔹 Send message
//   void _sendMessage() {
//     final text = _msgCtrl.text.trim();
//     if (text.isEmpty) return;
//
//     final payload = {
//       'deliveryId': widget.deliveryId,
//       'senderId': widget.senderId,
//       'receiverId': widget.receiverId,
//       'message': text,
//       'messageType': 'text',
//     };
//
//     _socket.emit('chat:message', payload);
//     _socket.emit('chat:fetch_history', {'deliveryId': widget.deliveryId});
//
//     // Optimistic UI (show instantly)
//     final now = DateTime.now();
//     setState(() {
//       _messages.add({
//         'type': 'msg',
//         'text': text,
//         'isSender': true,
//         'time': DateFormat('hh:mm a').format(now),
//         'createdAt': now,
//       });
//       _lastSentText = text;
//     });
//
//     _msgCtrl.clear();
//     _scrollToBottom();
//   }
//
//   // 🔹 Lifecycle
//   @override
//   void initState() {
//     super.initState();
//     _socket = widget.socket;
//     _setupSocketListeners();
//     _joinAndFetch();
//   }
//
//   @override
//   void dispose() {
//     _msgCtrl.dispose();
//     _scrollCtrl.dispose();
//
//     // Leave room (optional)
//     _socket.emit('chat:leave', {
//       'deliveryId': widget.deliveryId,
//       'userId': widget.senderId,
//     });
//
//     super.dispose();
//   }
//
//   // 🔹 UI
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffF5F5F7),
//       body: Column(
//         children: [
//           // Header
//           SizedBox(
//             height: 103.h,
//             child: Card(
//               color: Colors.white,
//               shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 10.w),
//                 child: Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.arrow_back_ios, color: Color(0xff010311)),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     SizedBox(width: 10.w),
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Adem Electronics',
//                             style: GoogleFonts.inter(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: const Color(0xff010311))),
//                         Text('Online',
//                             style: GoogleFonts.inter(
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xff2FAF0F))),
//                       ],
//                     ),
//                     const Spacer(),
//                     IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),
//                     IconButton(icon: const Icon(Icons.videocam_outlined), onPressed: () {}),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           // Chat List
//           Expanded(
//             child: _isLoadingHistory
//                 ? const Center(child: CircularProgressIndicator())
//                 : ListView.builder(
//               controller: _scrollCtrl,
//               padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
//               itemCount: _messages.length,
//               itemBuilder: (ctx, i) {
//                 final item = _messages[i];
//                 if (item['type'] == 'date') {
//                   return DateSeparator(date: item['date']);
//                 }
//                 return Padding(
//                   padding: EdgeInsets.only(bottom: 10.h),
//                   child: ChatBubble(
//                     message: item['text'],
//                     isSender: item['isSender'],
//                     time: item['time'],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//
//       // Message Input
//       bottomSheet: Container(
//         color: Colors.white,
//         padding: EdgeInsets.fromLTRB(20.w, 13.h, 20.w, 13.h),
//         child: Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: _msgCtrl,
//                 onSubmitted: (_) => _sendMessage(),
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: const Color.fromARGB(255, 233, 232, 235),
//                   hintText: 'Type Message',
//                   hintStyle: GoogleFonts.inter(
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.w500,
//                     color: const Color.fromARGB(255, 140, 140, 148),
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.r),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//                 ),
//               ),
//             ),
//             SizedBox(width: 8.w),
//             InkWell(
//               onTap: _sendMessage,
//               child: Container(
//                 width: 48.w,
//                 height: 46.h,
//                 decoration: BoxDecoration(
//                   color: const Color(0xff4A3DFE),
//                   borderRadius: BorderRadius.circular(10.r),
//                 ),
//                 alignment: Alignment.center,
//                 child: const Icon(Icons.send, color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ----------------------- Helper Widgets ------------------------
//
// class DateSeparator extends StatelessWidget {
//   final String date;
//   const DateSeparator({super.key, required this.date});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 10.h),
//       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
//       decoration: BoxDecoration(
//         color: Colors.grey.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20.r),
//       ),
//       child: Center(
//         child: Text(
//           date,
//           style: GoogleFonts.inter(
//             fontSize: 12.sp,
//             fontWeight: FontWeight.w500,
//             color: const Color(0xff606480),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class ChatBubble extends StatelessWidget {
//   final String message;
//   final bool isSender;
//   final String time;
//
//   const ChatBubble({
//     super.key,
//     required this.message,
//     required this.isSender,
//     required this.time,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.75,
//         ),
//         decoration: BoxDecoration(
//           color: isSender ? const Color(0xff00D0B8) : Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(16.r),
//             topRight: Radius.circular(16.r),
//             bottomLeft: Radius.circular(isSender ? 16.r : 0),
//             bottomRight: Radius.circular(isSender ? 0 : 16.r),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment:
//           isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//           children: [
//             Text(
//               message,
//               style: GoogleFonts.roboto(
//                 fontSize: 17.sp,
//                 fontWeight: FontWeight.w400,
//                 color: isSender ? Colors.white : const Color(0xFF2B2B2B),
//               ),
//             ),
//             SizedBox(height: 4.h),
//             Text(
//               time,
//               style: GoogleFonts.roboto(
//                 fontSize: 12.sp,
//                 fontWeight: FontWeight.w400,
//                 color: isSender
//                     ? Colors.white.withOpacity(0.7)
//                     : const Color(0xFF9CA3AF),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

final box = Hive.box('folder');
final String? currentUserId = box.get('id'); // logged-in user id

class ChatingPage extends ConsumerStatefulWidget {
  final IO.Socket socket;
  final String senderId; // current user
  final String receiverId; // chat partner
  final String deliveryId; // delivery id for chat room

  const ChatingPage({
    required this.socket,
    required this.senderId,
    required this.receiverId,
    required this.deliveryId,
    super.key,
  });

  @override
  ConsumerState<ChatingPage> createState() => _ChatingPageState();
}

class _ChatingPageState extends ConsumerState<ChatingPage> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  late IO.Socket _socket;
  String? _lastSentText;
  bool _isLoadingHistory = false;

  // Scroll to bottom
  void _scrollToBottom({bool animated = true}) {
    if (!_scrollCtrl.hasClients) return;
    final target = _scrollCtrl.position.maxScrollExtent;
    if (animated) {
      _scrollCtrl.animateTo(target, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _scrollCtrl.jumpTo(target);
    }
  }

  DateTime _parseDate(dynamic createdAt) {
    if (createdAt == null) return DateTime.now();

    if (createdAt is String) {
      try {
        return DateTime.parse(createdAt);
      } catch (e) {
        debugPrint('Invalid date string: $createdAt');
        return DateTime.now();
      }
    }

    if (createdAt is int) {
      try {
        // Try milliseconds first
        return DateTime.fromMillisecondsSinceEpoch(createdAt);
      } catch (e) {
        // If too big/small, try seconds
        try {
          return DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
        } catch (_) {
          return DateTime.now();
        }
      }
    }

    return DateTime.now();
  }

  void _addMessages(List<dynamic> raw, {bool clearFirst = false}) {
    final List<Map<String, dynamic>> incoming = raw
        .where((e) => e is Map)
        .cast<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    if (incoming.isEmpty) return;

    // Sort by createdAt
    incoming.sort((a, b) {
      final dtA = _parseDate(a['createdAt']);
      final dtB = _parseDate(b['createdAt']);
      return dtA.compareTo(dtB);
    });

    final List<Map<String, dynamic>> grouped = [];
    DateTime? lastDate;

    for (final msg in incoming) {
      final dt = _parseDate(msg['createdAt']);
      final dateKey = DateFormat('dd MMM yyyy').format(dt);

      // Add date separator if new day
      if (lastDate == null || dateKey != DateFormat('dd MMM yyyy').format(lastDate)) {
        grouped.add({'type': 'date', 'date': dateKey});
      }

      grouped.add({
        'type': 'msg',
        'text': msg['message']?.toString() ?? '',
        'isSender': msg['senderId'].toString() == widget.senderId,
        'time': DateFormat('hh:mm a').format(dt),
        'createdAt': dt,
      });

      lastDate = dt;
    }

    setState(() {
      if (clearFirst) {
        _messages.clear();
      }
      _messages.addAll(grouped);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }
  // STEP 1: Setup Socket Listeners (Correct Events)
  void _setupSocketListeners() {
    // STEP 3: Receive Chat History
    _socket.on('chat:history', (data) {
      if (data is List) {
        _addMessages(data, clearFirst: true); // Load full history
      }
      setState(() => _isLoadingHistory = false);
    });

    // STEP 5: Receive New Message (Realtime)
    _socket.on('chat:message', (data) {
      if (data == null) return;

      // Avoid duplicate (our own sent message)
      if (data is Map &&
          data['message'] == _lastSentText &&
          data['senderId'].toString() == widget.senderId) {
        _lastSentText = null;
        return;
      }

      _addMessages([data]); // Append single message
    });

    // Connection events
    _socket.onConnect((_) => debugPrint('Socket connected'));
    _socket.onDisconnect((_) => debugPrint('Socket disconnected'));
    _socket.onConnectError((err) => debugPrint('Connect error: $err'));
  }

  // STEP 2: Join Room & Fetch History
  void _joinAndFetch() {
    _socket.emit('chat:join', {
      'deliveryId': widget.deliveryId,
      'userId': widget.senderId,
    });

    _socket.emit('chat:fetch_history', {'deliveryId': widget.deliveryId});
    setState(() => _isLoadingHistory = true);
  }

  // STEP 4: Send Message
  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    final payload = {
      'deliveryId': widget.deliveryId,
      'senderId': widget.senderId,
      'receiverId': widget.receiverId,
      'message': text,
      'messageType': 'text',
    };

    _socket.emit('chat:message', payload);

    // Optimistic UI
    final now = DateTime.now();
    setState(() {
      _messages.add({
        'type': 'msg',
        'text': text,
        'isSender': true,
        'time': DateFormat('hh:mm a').format(now),
        'createdAt': now,
      });
      _lastSentText = text;
    });

    _msgCtrl.clear();
    _scrollToBottom();
  }

  @override
  void initState() {
    super.initState();
    _socket = widget.socket;
    _setupSocketListeners();
    _joinAndFetch(); // Step 2
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();

    // STEP 6: Leave Room
    _socket.emit('chat:leave', {
      'deliveryId': widget.deliveryId,
      'userId': widget.senderId,
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F7),
      body: Column(
        children: [
          // Header
          SizedBox(
            height: 103.h,
            child: Card(
              color: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Color(0xff010311)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Adem Electronics',
                            style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff010311))),
                        Text('Online',
                            style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff2FAF0F))),
                      ],
                    ),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.videocam_outlined), onPressed: () {}),
                  ],
                ),
              ),
            ),
          ),

          // Chat List
          Expanded(
            child: _isLoadingHistory
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollCtrl,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final item = _messages[i];
                if (item['type'] == 'date') {
                  return DateSeparator(date: item['date']);
                }
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: ChatBubble(
                    message: item['text'],
                    isSender: item['isSender'],
                    time: item['time'],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Message Input
      bottomSheet: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(20.w, 13.h, 20.w, 13.h),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 233, 232, 235),
                  hintText: 'Type Message',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 140, 140, 148),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            InkWell(
              onTap: _sendMessage,
              child: Container(
                width: 48.w,
                height: 46.h,
                decoration: BoxDecoration(
                  color: const Color(0xff4A3DFE),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------- Helper Widgets ------------------------

class DateSeparator extends StatelessWidget {
  final String date;
  const DateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Center(
        child: Text(
          date,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xff606480),
          ),
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSender;
  final String time;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isSender,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isSender ? const Color(0xff00D0B8) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isSender ? 16.r : 0),
            bottomRight: Radius.circular(isSender ? 0 : 16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: GoogleFonts.roboto(
                fontSize: 17.sp,
                fontWeight: FontWeight.w400,
                color: isSender ? Colors.white : const Color(0xFF2B2B2B),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              time,
              style: GoogleFonts.roboto(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: isSender ? Colors.white.withOpacity(0.7) : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
