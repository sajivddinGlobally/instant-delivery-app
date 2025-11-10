import 'dart:developer';
import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/ticketReplyBodyModel.dart';
import 'package:delivery_mvp_app/data/controller/getTicketListController.dart';
import 'package:hive/hive.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TicketDetailsPage extends ConsumerStatefulWidget {
  final IO.Socket socket;
  final String id;
  const TicketDetailsPage(this.socket, {super.key, required this.id});

  @override
  ConsumerState<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends ConsumerState<TicketDetailsPage> {
  final messageController = TextEditingController();
  final List<dynamic> _allReplies = [];
  final ScrollController _scrollController = ScrollController();
  late IO.Socket socket;
  String? currentUserId;
  String? currentUserRole;

  @override
  void initState() {
    super.initState();
    socket = widget.socket;

    // final box = Hive.box('folder');
    // currentUserId = box.get('user_id');
    currentUserRole = 'driver';

    if (socket.connected) {
      socket.emit("join_ticket", widget.id);
      log('join_ticket emitted: ${widget.id}');
    } else {
      socket.onConnect((_) {
        socket.emit("join_ticket", widget.id);
        log('join_ticket emitted on connect: ${widget.id}');
      });
      socket.connect();
    }

    socket.on("new_ticket_reply", (data) {
      log("new_ticket_reply received: $data");
      if (data is Map && data['ticketId'] == widget.id) {
        setState(() {
          _allReplies.add(data);
        });
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    socket.emit("leave_ticket", widget.id);
    socket.off("new_ticket_reply");
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    messageController.clear();
    try {
      final body = TicketReplyBodyModel(message: text, ticketId: widget.id);
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.ticketReply(body);

      if (response.code == 0) {
        Fluttertoast.showToast(msg: "Message sent!");

        final optimisticReply = {
          "message": text,
          "repliedBy": {"_id": currentUserId, "userType": "driver"},
          "repliedByModel": "User",
          "role": currentUserRole,
          "createdAt": DateTime.now().millisecondsSinceEpoch,
        };

        setState(() {
          _allReplies.add(optimisticReply);
        });

        _scrollToBottom();
        socket.emit("new_ticket_reply", {
          "ticketId": widget.id,
          "message": text,
          "sender": currentUserRole,
          "createdAt": DateTime.now().toIso8601String(),
          "repliedBy": 'driver',
        });
      } else {
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e, st) {
      log("Error sending message: $e\n$st");
      Fluttertoast.showToast(msg: "Failed to send");
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketDetailsProvider = ref.watch(ticketDetailsController(widget.id));

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFFFFFF),
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: IconButton(
            style: IconButton.styleFrom(shape: const CircleBorder()),
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          ),
        ),
        title: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: Text(
            "Support/Faq Details",
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF091425),
            ),
          ),
        ),
      ),
      body: ticketDetailsProvider.when(
        data: (snap) {
          if (_allReplies.isEmpty && snap.data.replies != null) {
            _allReplies.addAll(
              snap.data.replies!.map((reply) => reply.toJson()).toList(),
            );
            _allReplies.sort((a, b) {
              final aTime = a['createdAt'] ?? 0;
              final bTime = b['createdAt'] ?? 0;
              return aTime.compareTo(bTime);
            });
            _scrollToBottom();
          }

          return Padding(
            padding: EdgeInsets.only(left: 15.w, right: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: Color(0xFFCBCBCB), thickness: 1),
                SizedBox(height: 28.h),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.r),
                      bottomRight: Radius.circular(10.r),
                      topRight: Radius.circular(10.r),
                    ),
                    color: const Color(0xFFF0F5F5),
                  ),
                  child: Text(
                    snap.data.ticket!.subject,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _allReplies.length,
                    itemBuilder: (context, index) {
                      final reply = _allReplies[index];
                      final isSender = _isCurrentUser(reply);
                      final senderName = _getSenderName(reply);
                      final timestamp = _formatTimestamp(reply['createdAt']);

                      return _buildMessageBubble(
                        message: reply['message'] ?? '',
                        isSender: isSender,
                        senderName: senderName,
                        timestamp: timestamp,
                      );
                    },
                  ),
                ),
                SizedBox(height: 70.h),
              ],
            ),
          );
        },
        error: (error, stackTrace) {
          log(stackTrace.toString());
          return Center(child: Text(error.toString()));
        },
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      bottomSheet: MessageInput(
        controller: messageController,
        onSend: _handleSendMessage,
      ),
    );
  }

  bool _isCurrentUser(Map<String, dynamic> reply) {
    final repliedBy = reply['repliedBy'];
    if (repliedBy is Map<String, dynamic>) {
      return repliedBy['_id']?.toString() == currentUserId;
    }
    return false;
  }

  String _getSenderName(Map<String, dynamic> reply) {
    final repliedBy = reply['repliedBy'];
    if (repliedBy is Map<String, dynamic>) {
      if (repliedBy['firstName'] != null) {
        return "${repliedBy['firstName']} ${repliedBy['lastName'] ?? ''}"
            .trim();
      } else if (repliedBy['name'] != null) {
        return repliedBy['name'];
      }
    }
    final role = reply['role']?.toString().toLowerCase();
    if (role == 'manager' || role == 'superadmin') {
      return 'Support';
    }
    return 'You';
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    int millis;
    if (timestamp is String) {
      millis = int.tryParse(timestamp) ?? DateTime.now().millisecondsSinceEpoch;
    } else if (timestamp is int) {
      millis = timestamp;
    } else {
      return '';
    }
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == today) {
      return DateFormat('h:mm a').format(date);
    } else if (msgDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('dd MMM, h:mm a').format(date);
    }
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isSender,
    required String senderName,
    required String timestamp,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Column(
        crossAxisAlignment: isSender
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!isSender)
            Padding(
              padding: EdgeInsets.only(left: 12.w, bottom: 4.h),
              child: Text(
                senderName,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
          Align(
            alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(maxWidth: 0.75.sw),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isSender
                    ? const Color(0xFF008080)
                    : const Color(0xFFF0F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.r),
                  topRight: Radius.circular(10.r),
                  bottomLeft: Radius.circular(isSender ? 10.r : 0),
                  bottomRight: Radius.circular(isSender ? 0 : 10.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: isSender ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    timestamp,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: isSender ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.w, bottom: 10.h),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(
                    left: 15.w,
                    right: 15.w,
                    top: 10.h,
                    bottom: 10.h,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF0F5F5),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: Colors.grey, width: 1.w),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(
                      color: Color(0xFF006970),
                      width: 1,
                    ),
                  ),
                  hintText: "Type a message ...",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFAFAFAF),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 55.w,
              height: 54.h,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF008080),
              ),
              child: Center(
                child: Icon(Icons.send_sharp, color: Colors.white, size: 28.sp),
              ),
            ),
          ),
          SizedBox(width: 15.w),
        ],
      ),
    );
  }
}
