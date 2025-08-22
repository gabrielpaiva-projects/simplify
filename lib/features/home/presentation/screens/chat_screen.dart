import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/chat_message_model.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel chat;

  const ChatScreen({
    super.key,
    required this.chat,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;

  // Mock messages - substituir por dados reais do Firebase
  final List<ChatMessageModel> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMockMessages();
    // Scroll para o final após carregar as mensagens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _loadMockMessages() {
    _messages.addAll([
      ChatMessageModel(
        id: '1',
        chatId: widget.chat.id,
        senderId: widget.chat.clientId,
        senderName: widget.chat.clientName,
        receiverId: widget.chat.professionalId,
        receiverName: widget.chat.professionalName,
        content: 'Olá! Gostaria de agendar um serviço',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: true,
      ),
      ChatMessageModel(
        id: '2',
        chatId: widget.chat.id,
        senderId: widget.chat.professionalId,
        senderName: widget.chat.professionalName,
        receiverId: widget.chat.clientId,
        receiverName: widget.chat.clientName,
        content: 'Olá! Claro, qual serviço você precisa?',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 50)),
        isRead: true,
      ),
      ChatMessageModel(
        id: '3',
        chatId: widget.chat.id,
        senderId: widget.chat.clientId,
        senderName: widget.chat.clientName,
        receiverId: widget.chat.professionalId,
        receiverName: widget.chat.professionalName,
        content: 'Preciso de uma limpeza residencial completa',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
        isRead: true,
      ),
      ChatMessageModel(
        id: '4',
        chatId: widget.chat.id,
        senderId: widget.chat.professionalId,
        senderName: widget.chat.professionalName,
        receiverId: widget.chat.clientId,
        receiverName: widget.chat.clientName,
        content: 'Perfeito! Posso fazer amanhã às 10h. Funciona para você?',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
        isRead: true,
      ),
      ChatMessageModel(
        id: '5',
        chatId: widget.chat.id,
        senderId: widget.chat.clientId,
        senderName: widget.chat.clientName,
        receiverId: widget.chat.professionalId,
        receiverName: widget.chat.professionalName,
        content: 'Sim, perfeito!',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      ChatMessageModel(
        id: '6',
        chatId: widget.chat.id,
        senderId: widget.chat.clientId,
        senderName: widget.chat.clientName,
        receiverId: widget.chat.professionalId,
        receiverName: widget.chat.professionalName,
        content: 'Rua das Flores, 123 - Jardim Primavera',
        type: MessageType.location,
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        isRead: true,
        locationAddress: 'Rua das Flores, 123 - Jardim Primavera',
        latitude: -23.550520,
        longitude: -46.633308,
      ),
      ChatMessageModel(
        id: '7',
        chatId: widget.chat.id,
        senderId: widget.chat.professionalId,
        senderName: widget.chat.professionalName,
        receiverId: widget.chat.clientId,
        receiverName: widget.chat.clientName,
        content: 'Ok, estarei aí às 10h conforme combinado',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
    ]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.chat.id,
      senderId: widget.chat.professionalId,
      senderName: widget.chat.professionalName,
      receiverId: widget.chat.clientId,
      receiverName: widget.chat.clientName,
      content: text,
      type: MessageType.text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4A90E2),
                    const Color(0xFF357ABD),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  widget.chat.clientName.split(' ').map((e) => e[0]).take(2).join().toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat.clientName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Online',
                    style: TextStyle(
                      color: const Color(0xFF4CAF50),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implementar chamada de voz
            },
            icon: const Icon(Icons.phone, color: Colors.white),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF2A2A2A),
            onSelected: (value) {
              // TODO: Implementar ações do menu
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'appointment',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Ver agendamento', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Limpar conversa', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Bloquear', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Mensagens
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == widget.chat.professionalId;
                final showDate = index == 0 ||
                    !_isSameDay(
                      _messages[index - 1].timestamp,
                      message.timestamp,
                    );

                return Column(
                  children: [
                    if (showDate) _buildDateDivider(message.timestamp),
                    _buildMessage(message, isMe),
                  ],
                );
              },
            ),
          ),
          
          // Indicador de digitando
          if (widget.chat.isClientTyping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    '${widget.chat.clientName} está digitando',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 20,
                    height: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (index) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[500],
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          
          // Input de mensagem
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Botões de anexo
                IconButton(
                  onPressed: () {
                    _showAttachmentOptions();
                  },
                  icon: const Icon(Icons.attach_file, color: Colors.grey),
                ),
                // Campo de texto
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      maxLines: null,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Digite uma mensagem...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: InputBorder.none,
                      ),
                      onChanged: (text) {
                        setState(() {
                          _isTyping = text.isNotEmpty;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Botão de enviar
                Container(
                  decoration: BoxDecoration(
                    color: _isTyping ? const Color(0xFF4A90E2) : Colors.grey[700],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _isTyping ? _sendMessage : null,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF4A90E2) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.type == MessageType.location)
              _buildLocationMessage(message, isMe)
            else if (message.type == MessageType.image)
              _buildImageMessage(message, isMe)
            else
              Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.grey[300],
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead ? Colors.white : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationMessage(ChatMessageModel message, bool isMe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isMe ? Colors.white.withOpacity(0.2) : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on,
                color: isMe ? Colors.white : const Color(0xFF4A90E2),
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.locationAddress ?? 'Localização',
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.grey[300],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageMessage(ChatMessageModel message, bool isMe) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder para imagem
          Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.image,
              color: Colors.grey,
              size: 40,
            ),
          ),
          if (message.content.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.grey[300],
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateDivider(DateTime date) {
    String dateText;
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == DateTime(now.year, now.month, now.day)) {
      dateText = 'Hoje';
    } else if (messageDate == yesterday) {
      dateText = 'Ontem';
    } else {
      dateText = DateFormat('dd/MM/yyyy').format(date);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.grey[700],
              thickness: 0.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              dateText,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey[700],
              thickness: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enviar anexo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    icon: Icons.image,
                    label: 'Imagem',
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implementar envio de imagem
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.camera_alt,
                    label: 'Câmera',
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implementar captura de foto
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.location_on,
                    label: 'Localização',
                    color: const Color(0xFFFF9800),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implementar envio de localização
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.insert_drive_file,
                    label: 'Documento',
                    color: const Color(0xFF9C27B0),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implementar envio de documento
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}