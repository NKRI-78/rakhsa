import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/features/document/presentation/provider/document_notifier.dart';
import 'package:rakhsa/features/document/presentation/widgets/button_update_document.dart';
import 'package:rakhsa/features/document/presentation/widgets/document_preview.dart';

class VisaDocumentPage extends StatefulWidget {
  const VisaDocumentPage({super.key});

  @override
  State<VisaDocumentPage> createState() => _VisaDocumentPageState();
}

class _VisaDocumentPageState extends State<VisaDocumentPage> {
  late DocumentNotifier documentNotifier;

  @override
  void initState() {
    super.initState();
    documentNotifier = context.read<DocumentNotifier>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      documentNotifier.getVisaUrlFromProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // app bar
          SliverAppBar(
            backgroundColor: ColorResources.backgroundColor,
            leading: CupertinoNavigationBarBackButton(
              onPressed: () => Navigator.of(context).pop(),
              color: ColorResources.black,
            ),
          ),

          // title kategori
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Text(
                "Visa digital anda...",
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeOverLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // visa view
          SliverFillRemaining(
            hasScrollBody: false,
            child: Consumer<DocumentNotifier>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    // view visa
                    Expanded(
                      child: DocumentPreview(
                        provider,
                        type: DocumentType.visa,
                        hasDocument: provider.hasVisa,
                        loading: provider.visaIsLoading,
                      ),
                    ),

                    // button update document
                    // tombol update dokumen hanya muncul ketika dokumen sudah terpilih
                    // document path != null
                    if (provider.hasVisa)
                      ButtonUpdateDocument(
                        label: 'Update Visa',
                        onTap: () async =>
                            await provider.updateDocument(DocumentType.visa),
                      )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}