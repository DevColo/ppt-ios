// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:precious/providers/audio_books_provider.dart';
import 'package:precious/screens/audio_player_screen.dart';
import 'package:precious/utils/config.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:provider/provider.dart';

class HomeDownloadedAudiosScreen extends StatefulWidget {
  const HomeDownloadedAudiosScreen({super.key});

  @override
  State<HomeDownloadedAudiosScreen> createState() =>
      _HomeDownloadedAudiosScreenState();
}

class _HomeDownloadedAudiosScreenState
    extends State<HomeDownloadedAudiosScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedFiles();
  }

  Future<void> _loadDownloadedFiles() async {
    setState(() {
      _isLoading = true;
    });

    await Provider.of<AudioBooksProvider>(context, listen: false)
        .refreshDownloadedFiles();

    setState(() {
      _isLoading = false;
    });
  }

  String _extractBookTitle(String fileName) {
    // Assuming format is BookTitle_ChapterName.mp3
    final parts = fileName.split('_');
    if (parts.length > 1) {
      return parts[0];
    }
    return fileName;
  }

  String _extractChapterName(String fileName) {
    // Assuming format is BookTitle_ChapterName.mp3
    final parts = fileName.split('_');
    if (parts.length > 1) {
      // Remove .mp3 extension from chapter name
      final chapterWithExt = parts.sublist(1).join('_');
      return chapterWithExt.replaceAll('.mp3', '');
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Config.greyColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Config.primaryColor,
              ),
            )
          : Consumer<AudioBooksProvider>(
              builder: (context, provider, child) {
                final downloadedFiles = provider.downloadedFiles;
                if (downloadedFiles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Config.darkColor,
                          ),
                          onPressed: _loadDownloadedFiles,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          LocalizationService().translate('noData'),
                          style: const TextStyle(
                            color: Config.darkColor,
                            fontFamily: 'Montserrat-Medium',
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    itemCount: downloadedFiles.length,
                    itemBuilder: (context, index) {
                      final filePath = downloadedFiles[index];
                      final fileName = filePath.split('/').last;
                      final bookTitle = _extractBookTitle(fileName);
                      final chapterName = _extractChapterName(fileName);

                      return audioCard(
                        context,
                        fileName,
                        filePath,
                        bookTitle,
                        chapterName,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget audioCard(
    BuildContext context,
    String fileName,
    String filePath,
    String bookTitle,
    String chapterName,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AudioPlayerScreen(filePath: filePath),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Audio icon or thumbnail
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Config.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.music_note,
                  color: Config.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              // Audio info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookTitle,
                      style: const TextStyle(
                        color: Config.darkColor,
                        fontFamily: 'Montserrat-SemiBold',
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (chapterName.isNotEmpty)
                      Text(
                        chapterName,
                        style: TextStyle(
                          color: Config.darkColor.withOpacity(0.7),
                          fontFamily: 'Montserrat-Regular',
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Delete button
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title:
                          Text(LocalizationService().translate('delete_file')),
                      content: Text(
                          '${LocalizationService().translate('delete_confirmation')} "$fileName"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child:
                              Text(LocalizationService().translate('cancel')),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            final file = File(filePath);
                            if (file.existsSync()) {
                              file.deleteSync();
                              Provider.of<AudioBooksProvider>(context,
                                      listen: false)
                                  .removeDownloadedFile(filePath);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${LocalizationService().translate('file_deleted')}'),
                                ),
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child:
                              Text(LocalizationService().translate('delete')),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
