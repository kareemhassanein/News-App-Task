import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news_app_task/constrant/colors.dart';
import 'package:shimmer/shimmer.dart';

import '../Utils/Localization/Language/Languages.dart';

Widget loadImage(url,
        {BoxFit? fit,
        double? width,
        double? height,
        Color? color,
        Color? tint}) =>
    Container(
      color: Colors.grey.withOpacity(0.4),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        height: height,
        width: width,
        color: tint,
        filterQuality: FilterQuality.low,
        placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey.withOpacity(0.4),
            highlightColor: Colors.white.withOpacity(0.5),
            period: const Duration(milliseconds: 700),
            child: Container(
              color: Colors.white,
            )),
        errorWidget: (context, url, error) => Center(
          child: Text(
            Languages.of(context)!.noImage,
            style: GoogleFonts.cairo(color: AppColors.txtColor, fontSize: 14),
          ),
        ),
      ),
    );
