import 'package:AstrowayCustomer/utils/images.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class zoomImageWidget extends StatelessWidget {
  final String url;
  const zoomImageWidget({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: Container(
        height: 100.h,
        width: 100.w,
        child: Center(
          child: CachedNetworkImage(
            height: 50.h,
            width: 100.w,
            imageUrl: url,
            imageBuilder: (context, imageProvider) => Image.network(
              url,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fill,
            ),
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Image.asset(
              Images.blog,
              height: 180,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}
