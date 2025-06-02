import 'package:flutter/material.dart';
import 'package:kyuser/resources/Color_Manager.dart';
import 'package:kyuser/resources/StringManager.dart';

class InfoUs extends StatelessWidget {
  const InfoUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 800;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: isLargeScreen
                  ? _buildLargeScreenLayout(context, constraints)
                  : _buildSmallScreenLayout(context, constraints),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorManager.primaryByOpacity.withOpacity(0.9),
              ColorManager.primary,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "من نحن",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                      fontFamily:StringConstant.fontName,
                    fontSize: MediaQuery.sizeOf(context).width > 700 ? 22 : 18,
                  ),
                ),
                const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildLargeScreenLayout(BuildContext context, BoxConstraints constraints) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Card(
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildContent(context, constraints),
        ),
      ),
    );
  }

  Widget _buildSmallScreenLayout(BuildContext context, BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: _buildContent(context, constraints),
    );
  }

  Widget _buildContent(BuildContext context, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        _buildSection(context, constraints, "نـبـذة عنــا", StringConstant.aboutOur),
        _buildSection(context, constraints, "مهمتنــــــا", StringConstant.ourRole),
        _buildSection(context, constraints, "رؤيتنـــــــــا", StringConstant.ourVision),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSection(BuildContext context, BoxConstraints constraints, String headerText, String bodyText) {
    return Column(
      children: [
        _buildHeader(context, constraints, headerText),
        const SizedBox(height: 12),
        _buildBody(context, bodyText),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, BoxConstraints constraints, String text) {
    final width = MediaQuery.of(context).size.width;
    final headerWidth = constraints.maxWidth > 800 ? 200.0 : width * 0.35;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          Expanded(child: Divider(color: ColorManager.primaryByOpacity)),
          const SizedBox(width: 8),
          Container(
            width: headerWidth,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorManager.primary,
                  ColorManager.primaryByOpacity.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(45),
            ),
            child: Center(
              child: Text(
                text,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontFamily:StringConstant.fontName,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: ColorManager.primaryByOpacity)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, String text) {
    return Card(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 15,fontFamily:StringConstant.fontName),
          textAlign: TextAlign.justify,

          overflow: TextOverflow.ellipsis, // Prevents overflow with ellipsis
          maxLines: 10, // Limits the number of lines (adjust as needed)
          softWrap: true, // Ensures text wraps properly
        ),
      ),
    );
  }
}