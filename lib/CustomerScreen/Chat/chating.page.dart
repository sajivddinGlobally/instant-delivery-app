


/*

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
*/
/*

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

final box = Hive.box('folder');
final String? currentUserId = box.get('id');

class ChatingPage extends ConsumerStatefulWidget {
  final IO.Socket socket;
  final String senderId;
  final String receiverId;
  final String deliveryId;

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

  // ── SCROLL TO BOTTOM ─────────────────────────────────────
  void _scrollToBottom() {
    if (!mounted || !_scrollCtrl.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ── PARSE DATE (Safe) ───────────────────────────────────
  DateTime _parseDate(dynamic createdAt) {
    if (createdAt == null) return DateTime.now();
    if (createdAt is String) {
      try { return DateTime.parse(createdAt); } catch (_) {}
    }
    if (createdAt is int) {
      try { return DateTime.fromMillisecondsSinceEpoch(createdAt); } catch (_) {}
      try { return DateTime.fromMillisecondsSinceEpoch(createdAt * 1000); } catch (_) {}
    }
    return DateTime.now();
  }

  // ── ADD MESSAGES WITH DATE SEPARATOR ─────────────────────
  void _addMessages(List<dynamic> raw, {bool clearFirst = false}) {
    if (!mounted) return;

    final incoming = raw
        .where((e) => e is Map)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    if (incoming.isEmpty) return;

    incoming.sort((a, b) => _parseDate(a['createdAt']).compareTo(_parseDate(b['createdAt'])));

    final grouped = <Map<String, dynamic>>[];
    DateTime? lastDate;

    for (final msg in incoming) {
      final dt = _parseDate(msg['createdAt']);
      final dateKey = DateFormat('dd MMM yyyy').format(dt);

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

    if (!mounted) return;

    setState(() {
      if (clearFirst) _messages.clear();
      _messages.addAll(grouped);
    });

    _scrollToBottom();
  }

  // ── SETUP SOCKET LISTENERS (No Duplicates!) ───────────────
  void _setupSocketListeners() {
    // ← PURANE LISTENERS HATAYE (Critical!)
    _socket.off('chat:history');
    _socket.off('chat:message');

    _socket.on('chat:history', (data) {
      if (!mounted) return;
      if (data is List) {
        _addMessages(data, clearFirst: true);
      }
      // ← LOADER BAND! (Fix #1)
      setState(() => _isLoadingHistory = false);
    });

    _socket.on('chat:message', (data) {
      if (!mounted || data == null) return;

      // Ignore own echo
      if (data is Map &&
          data['message'] == _lastSentText &&
          data['senderId'].toString() == widget.senderId) {
        _lastSentText = null;
        return;
      }

      _addMessages([data]);
    });

    _socket.onConnect((_) => debugPrint('Socket connected'));
  }

  // ── JOIN + FETCH + LOADER TIMEOUT ───────────────────────
  void _joinAndFetch() {
    _socket.emit('chat:join', {
      'deliveryId': widget.deliveryId,
      'userId': widget.senderId,
    });

    _socket.emit('chat:fetch_history', {'deliveryId': widget.deliveryId});

    setState(() => _isLoadingHistory = true);

    // ← 5 sec baad loader band (Safety net)
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isLoadingHistory) {
        setState(() => _isLoadingHistory = false);
      }
    });
  }

  // ── SEND MESSAGE (Optimistic) ───────────────────────────
  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || !mounted) return;

    final payload = {
      'deliveryId': widget.deliveryId,
      'senderId': widget.senderId,
      'receiverId': widget.receiverId,
      'message': text,
      'messageType': 'text',
    };

    _socket.emit('chat:message', payload);

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

  // ── INIT (Fix #2: Remove old listeners) ─────────────────
  @override
  void initState() {
    super.initState();
    _socket = widget.socket;

    // ← PURANE LISTENERS HATAYE YAHAN BHI!
    _socket.off('chat:history');
    _socket.off('chat:message');

    _setupSocketListeners();
    _joinAndFetch();
  }

  // ── DISPOSE (Clean exit) ───────────────────────────────
  @override
  void dispose() {
    _socket.off('chat:history');
    _socket.off('chat:message',);
    _socket.emit('chat:leave', {
      'deliveryId': widget.deliveryId,
      'userId': widget.senderId,
    });

    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── BUILD UI ───────────────────────────────────────────
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

          // Chat Messages
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

      // Input Bar
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

// ── DATE SEPARATOR ───────────────────────────────────────
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

// ── CHAT BUBBLE ───────────────────────────────────────────
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
}*/
/*


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

final box = Hive.box('folder');
final String? currentUserId = box.get('id');
final String currentUserType = box.get('userType') ?? 'customer'; // ← ADD YE LINE

class ChatingPage extends ConsumerStatefulWidget {
  final IO.Socket socket;
  final String senderId;
  final String receiverId;
  final String deliveryId;

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
  bool _isLoadingHistory = false;

  void _scrollToBottom() {
    if (!mounted || !_scrollCtrl.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  DateTime _parseDate(dynamic createdAt) {
    if (createdAt == null) return DateTime.now();
    if (createdAt is String) {
      try { return DateTime.parse(createdAt); } catch (_) {}
    }
    if (createdAt is int) {
      try { return DateTime.fromMillisecondsSinceEpoch(createdAt); } catch (_) {}
      try { return DateTime.fromMillisecondsSinceEpoch(createdAt * 1000); } catch (_) {}
    }
    return DateTime.now();
  }

  void _addMessages(List<dynamic> raw, {bool clearFirst = false}) {
    if (!mounted) return;

    final incoming = raw.where((e) => e is Map).cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    if (incoming.isEmpty) return;

    incoming.sort((a, b) => _parseDate(a['createdAt']).compareTo(_parseDate(b['createdAt'])));

    final grouped = <Map<String, dynamic>>[];
    DateTime? lastDate;

    for (final msg in incoming) {
      final dt = _parseDate(msg['createdAt']);
      final dateKey = DateFormat('dd MMM yyyy').format(dt);

      if (lastDate == null || dateKey != DateFormat('dd MMM yyyy').format(lastDate)) {
        grouped.add({'type': 'date', 'date': dateKey});
      }

      final String msgUserType = msg['userType']?.toString().toLowerCase() ?? 'customer';
      final bool isSender = msgUserType == currentUserType; // ← YE HI TRICK!

      grouped.add({
        'type': 'msg',
        'text': msg['message']?.toString() ?? '',
        'isSender': isSender,
        'time': DateFormat('hh:mm a').format(dt),
        'createdAt': dt,
        'tempId': msg['tempId'],
        'userType': msgUserType,
      });
      lastDate = dt;
    }

    setState(() {
      if (clearFirst) _messages.clear();
      _messages.addAll(grouped);
    });
    _scrollToBottom();
  }

  void _setupSocketListeners() {
    _socket.off('chat:history');
    _socket.off('chat:message');

    _socket.on('chat:history', (data) {
      if (!mounted) return;
      if (data is List) _addMessages(data, clearFirst: true);
      setState(() => _isLoadingHistory = false);
    });

    _socket.on('chat:message', (data) {
      if (!mounted || data == null) return;

      final tempId = data['tempId']?.toString();
      if (tempId != null && _messages.any((m) => m['tempId'] == tempId)) return;

      _addMessages([data]);
    });
  }

  void _joinAndFetch() {
    _socket.emit('chat:join', {
      'deliveryId': widget.deliveryId,
      'userId': widget.senderId,
    });
    _socket.emit('chat:fetch_history', {'deliveryId': widget.deliveryId});
    setState(() => _isLoadingHistory = true);

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isLoadingHistory) setState(() => _isLoadingHistory = false);
    });
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || !mounted) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    _socket.emit('chat:message', {
      'deliveryId': widget.deliveryId,
      'senderId': widget.senderId,
      'receiverId': widget.receiverId,
      'message': text,
      'messageType': 'text',
      'tempId': tempId,
      'userType': currentUserType, // ← YE BHEJO!
    });

    final now = DateTime.now();
    setState(() {
      _messages.add({
        'type': 'msg',
        'text': text,
        'isSender': true,
        'time': DateFormat('hh:mm a').format(now),
        'createdAt': now,
        'tempId': tempId,
        'userType': currentUserType,
      });
    });

    _msgCtrl.clear();
    _scrollToBottom();
  }

  @override
  void initState() {
    super.initState();
    _socket = widget.socket;
    _socket.off('chat:history');
    _socket.off('chat:message');
    _setupSocketListeners();
    _joinAndFetch();
  }

  @override
  void dispose() {
    _socket.off('chat:history');
    _socket.off('chat:message');
    _socket.emit('chat:leave', {
      'deliveryId': widget.deliveryId,
      'userId': widget.senderId,
    });
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F7),
      body: Column(
        children: [
          SizedBox(
            height: 103.h,
            child: Card(
              color: Colors.white,
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
                            style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xff010311))),
                        Text('Online',
                            style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xff2FAF0F))),
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

          Expanded(
            child: _isLoadingHistory
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollCtrl,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final item = _messages[i];
                if (item['type'] == 'date') return DateSeparator(date: item['date']);
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
                  hintStyle: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w500, color: const Color.fromARGB(255, 140, 140, 148)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
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
                decoration: BoxDecoration(color: const Color(0xff4A3DFE), borderRadius: BorderRadius.circular(10.r)),
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

class DateSeparator extends StatelessWidget {
  final String date;
  const DateSeparator({super.key, required this.date});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(20.r)),
      child: Center(
        child: Text(date, style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w500, color: const Color(0xff606480))),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSender;
  final String time;

  const ChatBubble({super.key, required this.message, required this.isSender, required this.time});

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
            Text(message, style: GoogleFonts.roboto(fontSize: 17.sp, fontWeight: FontWeight.w400, color: isSender ? Colors.white : const Color(0xFF2B2B2B))),
            SizedBox(height: 4.h),
            Text(time, style: GoogleFonts.roboto(fontSize: 12.sp, fontWeight: FontWeight.w400, color: isSender ? Colors.white.withOpacity(0.7) : const Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}*/


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

final box = Hive.box('folder');
final String? currentUserId = box.get('id');
final String currentUserType = box.get('userType') ?? 'customer'; // ← customer or driver

class ChatingPage extends ConsumerStatefulWidget {
  final name;
  final IO.Socket socket;
  final String senderId;
  final String receiverId;
  final String deliveryId;

  const ChatingPage({
    required this.name,
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
  bool _isLoadingHistory = false;

  void _scrollToBottom() {
    if (!mounted || !_scrollCtrl.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  DateTime _parseDate(dynamic createdAt) {
    if (createdAt == null) return DateTime.now();
    if (createdAt is String) {
      try { return DateTime.parse(createdAt); } catch (_) {}
    }
    if (createdAt is int) {
      try { return DateTime.fromMillisecondsSinceEpoch(createdAt); } catch (_) {}
      try { return DateTime.fromMillisecondsSinceEpoch(createdAt * 1000); } catch (_) {}
    }
    return DateTime.now();
  }

  void _addMessages(List<dynamic> raw, {bool clearFirst = false}) {
    if (!mounted) return;

    final incoming = raw.where((e) => e is Map).cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    if (incoming.isEmpty) return;

    incoming.sort((a, b) => _parseDate(a['createdAt']).compareTo(_parseDate(b['createdAt'])));

    final grouped = <Map<String, dynamic>>[];
    DateTime? lastDate;

    for (final msg in incoming) {
      final dt = _parseDate(msg['createdAt']);
      final dateKey = DateFormat('dd MMM yyyy').format(dt);

      if (lastDate == null || dateKey != DateFormat('dd MMM yyyy').format(lastDate)) {
        grouped.add({'type': 'date', 'date': dateKey});
      }

      final String msgUserType = (msg['userType'] ?? 'customer').toString().toLowerCase();
      final bool isSender = msgUserType == currentUserType;

      grouped.add({
        'type': 'msg',
        'text': msg['message']?.toString() ?? '',
        'isSender': isSender,
        'time': DateFormat('hh:mm a').format(dt),
        'createdAt': dt,
        'tempId': msg['tempId'],
        'userType': msgUserType,
      });
      lastDate = dt;
    }

    setState(() {
      if (clearFirst) _messages.clear();
      _messages.addAll(grouped);
    });
    _scrollToBottom();
  }

  void _setupSocketListeners() {
    _socket.off('chat:history');
    _socket.off('chat:message');

    _socket.on('chat:history', (data) {
      if (!mounted) return;
      if (data is List) _addMessages(data, clearFirst: true);
      setState(() => _isLoadingHistory = false);
    });


    _socket.on('chat:message', (data) {
      if (!mounted || data == null) return;

      final tempId = data['tempId']?.toString();
      if (tempId != null && _messages.any((m) => m['tempId'] == tempId)) return;

      _addMessages([data]); // ← Sirf server se aaya dikhega
    });
  }

  void _joinAndFetch() {
    _socket.emit('chat:join', {
      'deliveryId': widget.deliveryId,
      'userId': widget.senderId,
    });
    _socket.emit('chat:fetch_history', {'deliveryId': widget.deliveryId});
    setState(() => _isLoadingHistory = true);

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isLoadingHistory) setState(() => _isLoadingHistory = false);
    });
  }

  // ── SEND MESSAGE (NO LOCAL UI – SIRF EMIT) ───────────────────
  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || !mounted) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    _socket.emit('chat:message', {
      'deliveryId': widget.deliveryId,
      'senderId': widget.senderId,
      'receiverId': widget.receiverId,
      'message': text,
      'messageType': 'text',
      'tempId': tempId,
      'userType': currentUserType,
    });

    _msgCtrl.clear();
    _scrollToBottom();
    // ← KOI setState NHI! Server se aayega!
  }

  @override
  void initState() {
    super.initState();
    _socket = widget.socket;
    _socket.off('chat:history');
    _socket.off('chat:message');
    _setupSocketListeners();
    _joinAndFetch();
  }

  @override
  void dispose() {
    _socket.off('chat:history');
    _socket.off('chat:message');
    _socket.emit('chat:leave', {
      'deliveryId': widget.deliveryId,
      'userId': widget.senderId,
    });
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F7),
      body: Column(
        children: [
          SizedBox(height: 20.h,),

          SizedBox(
            height: 103.h,
            child: Card(
              color: Colors.white,
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
                        Text(
                            widget.name??
                            'Adem Electronics',
                            style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xff010311))),
                        Text('Online',
                            style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xff2FAF0F))),
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

          Expanded(
            child: _isLoadingHistory
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollCtrl,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final item = _messages[i];
                if (item['type'] == 'date') return DateSeparator(date: item['date']);
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
                  hintStyle: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w500, color: const Color.fromARGB(255, 140, 140, 148)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
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
                decoration: BoxDecoration(color: const Color(0xff4A3DFE), borderRadius: BorderRadius.circular(10.r)),
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

// DateSeparator & ChatBubble same as before
class DateSeparator extends StatelessWidget {
  final String date;
  const DateSeparator({super.key, required this.date});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(20.r)),
      child: Center(
        child: Text(date, style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w500, color: const Color(0xff606480))),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSender;
  final String time;

  const ChatBubble({super.key, required this.message, required this.isSender, required this.time});

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
            Text(message, style: GoogleFonts.roboto(fontSize: 17.sp, fontWeight: FontWeight.w400, color: isSender ? Colors.white : const Color(0xFF2B2B2B))),
            SizedBox(height: 4.h),
            Text(time, style: GoogleFonts.roboto(fontSize: 12.sp, fontWeight: FontWeight.w400, color: isSender ? Colors.white.withOpacity(0.7) : const Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}