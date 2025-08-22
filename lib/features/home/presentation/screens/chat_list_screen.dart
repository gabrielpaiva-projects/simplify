import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/chat_message_model.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock data - substituir por dados reais do Firebase
  final List<ChatModel> _mockChats = [
    ChatModel(
      id: '1',
      professionalId: 'prof123',
      professionalName: 'João Profissional',
      clientId: 'client1',
      clientName: 'Maria Santos',
      lastMessage: 'Ok, estarei aí às 10h conforme combinado',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      appointmentId: 'apt1',
    ),
    ChatModel(
      id: '2',
      professionalId: 'prof123',
      professionalName: 'João Profissional',
      clientId: 'client2',
      clientName: 'João Silva',
      lastMessage: 'Pode ser amanhã à tarde?',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      appointmentId: 'apt2',
    ),
    ChatModel(
      id: '3',
      professionalId: 'prof123',
      professionalName: 'João Profissional',
      clientId: 'client3',
      clientName: 'Ana Paula',
      lastMessage: 'Muito obrigada pelo serviço!',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    ChatModel(
      id: '4',
      professionalId: 'prof123',
      professionalName: 'João Profissional',
      clientId: 'client4',
      clientName: 'Carlos Oliveira',
      lastMessage: 'Você enviou uma foto',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
      unreadCount: 1,
      isClientTyping: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  List<ChatModel> get _filteredChats {
    if (_searchQuery.isEmpty) {
      return _mockChats;
    }
    return _mockChats.where((chat) {
      return chat.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (chat.lastMessage?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalUnread = _mockChats.fold<int>(0, (sum, chat) => sum + chat.unreadCount);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Conversas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (totalUnread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF44336),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  totalUnread.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implementar nova conversa
            },
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF2A2A2A),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Pesquisar conversas...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                        icon: Icon(Icons.clear, color: Colors.grey[500]),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          // Lista de conversas
          Expanded(
            child: _filteredChats.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    itemCount: _filteredChats.length,
                    separatorBuilder: (context, index) => const Divider(
                      color: Color(0xFF2A2A2A),
                      height: 1,
                      thickness: 1,
                    ),
                    itemBuilder: (context, index) {
                      return _buildChatItem(_filteredChats[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(ChatModel chat) {
    final bool hasUnread = chat.unreadCount > 0;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(chat: chat),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
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
                        chat.clientName.split(' ').map((e) => e[0]).take(2).join().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Indicador de digitando
                  if (chat.isClientTyping)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1A1A1A),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  // Indicador online
                  if (!chat.isClientTyping)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1A1A1A),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              
              // Conteúdo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            chat.clientName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatTime(chat.lastMessageTime),
                          style: TextStyle(
                            color: hasUnread ? const Color(0xFF4A90E2) : Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: chat.isClientTyping
                              ? Text(
                                  'digitando...',
                                  style: TextStyle(
                                    color: const Color(0xFF4CAF50),
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              : Text(
                                  chat.lastMessage ?? 'Sem mensagens',
                                  style: TextStyle(
                                    color: hasUnread ? Colors.grey[300] : Colors.grey[500],
                                    fontSize: 14,
                                    fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF4A90E2),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              chat.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (chat.appointmentId != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90E2).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 10,
                              color: const Color(0xFF4A90E2),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Agendamento relacionado',
                              style: TextStyle(
                                color: const Color(0xFF4A90E2),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.chat_bubble_outline,
              size: 48,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'Nenhuma conversa encontrada'
                : 'Sem conversas',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Tente buscar por outro termo'
                : 'Suas conversas com clientes aparecerão aqui',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays < 7) {
      return DateFormat('EEE', 'pt_BR').format(dateTime);
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }
}