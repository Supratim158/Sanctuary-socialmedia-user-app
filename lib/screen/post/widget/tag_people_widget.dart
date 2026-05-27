import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sanctuary/services/auth_services.dart';

class TagPeopleWidget extends StatefulWidget {

  final List<Map<String, dynamic>> taggedUsers;
  final VoidCallback onTagsChanged;

  const TagPeopleWidget({
    super.key,
    required this.taggedUsers,
    required this.onTagsChanged,
  });

  @override
  State<TagPeopleWidget> createState() =>
      _TagPeopleWidgetState();
}

class _TagPeopleWidgetState
    extends State<TagPeopleWidget> {

  void _showTagPeopleSheet() async {

    final result = await showModalBottomSheet<List<Map<String, dynamic>>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {

        return _TagPeopleBottomSheet(
          alreadyTagged: widget.taggedUsers,
        );
      },
    );

    if (result != null) {
      widget.taggedUsers.clear();
      widget.taggedUsers.addAll(result);
      widget.onTagsChanged();
    }
  }

  void _removeTag(int index) {
    widget.taggedUsers.removeAt(index);
    widget.onTagsChanged();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 2,
      ),

      child: Column(
        children: [

          // TAG PEOPLE BUTTON
          ListTile(
            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 4,
            ),

            onTap: _showTagPeopleSheet,

            leading: Icon(
              Icons.person_add_outlined,
              color: Colors.white.withOpacity(0.5),
              size: 22,
            ),

            title: Text(
              "Tag People",

              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                if (widget.taggedUsers.isNotEmpty)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.purpleAccent
                          .withOpacity(0.15),
                      borderRadius:
                      BorderRadius.circular(12),
                    ),

                    child: Text(
                      "${widget.taggedUsers.length}",

                      style: GoogleFonts.inter(
                        color: Colors.purpleAccent
                            .shade100,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(width: 6),

                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.2),
                  size: 20,
                ),
              ],
            ),
          ),

          // TAGGED USERS CHIPS
          if (widget.taggedUsers.isNotEmpty)
            SizedBox(
              height: 44,

              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.taggedUsers.length,

                itemBuilder: (context, index) {

                  final user =
                  widget.taggedUsers[index];

                  return Container(
                    margin:
                    const EdgeInsets.only(right: 8),

                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.06),

                      borderRadius:
                      BorderRadius.circular(20),

                      border: Border.all(
                        color: Colors.white
                            .withOpacity(0.1),
                      ),
                    ),

                    child: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [

                        CircleAvatar(
                          radius: 12,

                          backgroundColor:
                          Colors.white
                              .withOpacity(0.1),

                          backgroundImage:
                          user['avatarUrl'] != null &&
                              (user['avatarUrl']
                              as String)
                                  .isNotEmpty
                              ? NetworkImage(
                              user['avatarUrl'])
                              : null,

                          child:
                          user['avatarUrl'] == null ||
                              (user['avatarUrl']
                              as String)
                                  .isEmpty
                              ? Text(
                            (user['userName'] ?? '?')
                                .toString()
                                .substring(0, 1)
                                .toUpperCase(),

                            style:
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          )
                              : null,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          user['userName'] ?? 'User',

                          style: GoogleFonts.inter(
                            color: Colors.white
                                .withOpacity(0.8),
                            fontSize: 12,
                            fontWeight:
                            FontWeight.w500,
                          ),
                        ),

                        const SizedBox(width: 4),

                        GestureDetector(
                          onTap: () =>
                              _removeTag(index),

                          child: Icon(
                            Icons.close,
                            color: Colors.white
                                .withOpacity(0.4),
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}


// ─── TAG PEOPLE BOTTOM SHEET ────────────────────────

class _TagPeopleBottomSheet extends StatefulWidget {

  final List<Map<String, dynamic>> alreadyTagged;

  const _TagPeopleBottomSheet({
    required this.alreadyTagged,
  });

  @override
  State<_TagPeopleBottomSheet> createState() =>
      _TagPeopleBottomSheetState();
}

class _TagPeopleBottomSheetState
    extends State<_TagPeopleBottomSheet> {

  List<dynamic> _allUsers = [];
  List<dynamic> _filteredUsers = [];
  List<Map<String, dynamic>> _selected = [];

  bool _isLoading = true;

  final TextEditingController _searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    _selected =
    List<Map<String, dynamic>>.from(widget.alreadyTagged);

    _loadUsers();
  }

  Future<void> _loadUsers() async {

    final users = await AuthServices.fetchUsers();

    if (mounted) {
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {

    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers.where((user) {

          final name =
          (user['userName'] ?? '').toString().toLowerCase();

          final email =
          (user['email'] ?? '').toString().toLowerCase();

          return name.contains(query.toLowerCase()) ||
              email.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  bool _isSelected(dynamic user) {

    final userId = user['_id'] ?? user['userId'] ?? '';

    return _selected.any((s) =>
    (s['_id'] ?? s['userId'] ?? '') == userId);
  }

  void _toggleUser(dynamic user) {

    final userId = user['_id'] ?? user['userId'] ?? '';

    setState(() {
      if (_isSelected(user)) {

        _selected.removeWhere((s) =>
        (s['_id'] ?? s['userId'] ?? '') == userId);

      } else {

        _selected.add(
          Map<String, dynamic>.from(user),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,

      builder: (context, scrollController) {

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),

          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 30,
              sigmaY: 30,
            ),

            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D)
                    .withOpacity(0.95),

                borderRadius:
                const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),

                border: Border(
                  top: BorderSide(
                    color: Colors.white
                        .withOpacity(0.08),
                  ),
                ),
              ),

              child: Column(
                children: [

                  const SizedBox(height: 12),

                  // DRAG HANDLE
                  Container(
                    height: 5,
                    width: 50,

                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TITLE
                  Text(
                    "Tag People",

                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // SEARCH BAR
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),

                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.06),

                        borderRadius:
                        BorderRadius.circular(14),

                        border: Border.all(
                          color: Colors.white
                              .withOpacity(0.08),
                        ),
                      ),

                      child: TextField(
                        controller: _searchController,

                        onChanged: _onSearchChanged,

                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                        ),

                        decoration: InputDecoration(
                          hintText:
                          "Search users...",

                          hintStyle: TextStyle(
                            color: Colors.white
                                .withOpacity(0.3),
                          ),

                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white
                                .withOpacity(0.3),
                          ),

                          border: InputBorder.none,

                          contentPadding:
                          const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // SELECTED COUNT
                  if (_selected.isNotEmpty)
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),

                      child: Row(
                        children: [

                          Text(
                            "${_selected.length} selected",

                            style: GoogleFonts.inter(
                              color:
                              Colors.purpleAccent
                                  .shade100,
                              fontSize: 13,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),

                          const Spacer(),

                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selected.clear();
                              });
                            },

                            child: Text(
                              "Clear all",

                              style:
                              GoogleFonts.inter(
                                color: Colors.white
                                    .withOpacity(
                                    0.4),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // USER LIST
                  Expanded(
                    child: _isLoading

                        ? const Center(
                      child:
                      CircularProgressIndicator(
                        color:
                        Colors.purpleAccent,
                      ),
                    )

                        : _filteredUsers.isEmpty

                        ? Center(
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                        children: [

                          Icon(
                            Icons
                                .person_search_outlined,
                            color: Colors.white
                                .withOpacity(
                                0.2),
                            size: 48,
                          ),

                          const SizedBox(
                              height: 12),

                          Text(
                            "No users found",

                            style:
                            GoogleFonts.inter(
                              color: Colors.white
                                  .withOpacity(
                                  0.3),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )

                        : ListView.builder(
                      controller:
                      scrollController,

                      itemCount:
                      _filteredUsers.length,

                      itemBuilder:
                          (context, index) {

                        final user =
                        _filteredUsers[
                        index];

                        final isSelected =
                        _isSelected(user);

                        final avatarUrl =
                            user['avatarUrl']
                            as String? ??
                                '';

                        final userName =
                            user['userName']
                            as String? ??
                                'User';

                        final email =
                            user['email']
                            as String? ??
                                '';

                        return ListTile(
                          onTap: () =>
                              _toggleUser(
                                  user),

                          leading:
                          CircleAvatar(
                            radius: 22,

                            backgroundColor:
                            Colors.white
                                .withOpacity(
                                0.08),

                            backgroundImage:
                            avatarUrl
                                .isNotEmpty
                                ? NetworkImage(
                                avatarUrl)
                                : null,

                            child: avatarUrl
                                .isEmpty
                                ? Text(
                              userName
                                  .substring(
                                  0, 1)
                                  .toUpperCase(),

                              style:
                              const TextStyle(
                                color: Colors
                                    .white,
                                fontWeight:
                                FontWeight
                                    .w600,
                                fontSize:
                                16,
                              ),
                            )
                                : null,
                          ),

                          title: Text(
                            userName,

                            style:
                            GoogleFonts.inter(
                              color:
                              Colors.white,
                              fontWeight:
                              FontWeight
                                  .w600,
                              fontSize: 14,
                            ),
                          ),

                          subtitle: Text(
                            email,

                            style: TextStyle(
                              color: Colors
                                  .white
                                  .withOpacity(
                                  0.4),
                              fontSize: 12,
                            ),
                          ),

                          trailing:
                          AnimatedContainer(
                            duration:
                            const Duration(
                              milliseconds:
                              200,
                            ),

                            width: 28,
                            height: 28,

                            decoration:
                            BoxDecoration(
                              shape: BoxShape
                                  .circle,

                              color: isSelected
                                  ? Colors
                                  .purpleAccent
                                  : Colors
                                  .transparent,

                              border:
                              Border.all(
                                color: isSelected
                                    ? Colors
                                    .purpleAccent
                                    : Colors
                                    .white
                                    .withOpacity(
                                    0.2),
                                width: 2,
                              ),
                            ),

                            child: isSelected
                                ? const Icon(
                              Icons.check,
                              color: Colors
                                  .white,
                              size: 16,
                            )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),

                  // DONE BUTTON
                  Padding(
                    padding:
                    const EdgeInsets.all(20),

                    child: SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                              context, _selected);
                        },

                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          Colors.purpleAccent,

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                                14),
                          ),

                          elevation: 0,
                        ),

                        child: Text(
                          _selected.isEmpty
                              ? "Done"
                              : "Tag ${_selected.length} ${_selected.length == 1 ? 'person' : 'people'}",

                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
