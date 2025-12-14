import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../domain/entities/article.dart';

class ArticleReadPage extends StatelessWidget {
  final ArticleEntity article;

  const ArticleReadPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final title = (article.title ?? '').trim();
    final author = (article.author ?? '').trim();
    final publishedAt = (article.publishedAt ?? '').trim();

    final desc = _cleanText((article.description ?? '').trim());
    final content = _cleanText((article.content ?? '').trim());

    final body = (content.isNotEmpty)
        ? content
        : (desc.isNotEmpty ? desc : 'No content available.');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: const Icon(Ionicons.chevron_back, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.isEmpty ? 'Untitled' : title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              if (author.isNotEmpty || publishedAt.isNotEmpty)
                Row(
                  children: [
                    if (author.isNotEmpty)
                      Text(
                        author,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (author.isNotEmpty && publishedAt.isNotEmpty)
                      Text(' • ',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: Colors.grey.shade500)),
                    if (publishedAt.isNotEmpty)
                      Text(
                        publishedAt,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),

              const SizedBox(height: 16),

              SelectableText(
                body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.65,
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _cleanText(String s) {
    // Limpia el típico "...[+950 chars]" que a veces manda el API
    return s.replaceAll(RegExp(r'\[\+\d+\schars\]'), '').trim();
  }
}
