import 'dart:io';

import 'package:AstrowayCustomer/controllers/astromallController.dart';
import 'package:AstrowayCustomer/controllers/search_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:AstrowayCustomer/utils/global.dart' as global;

import 'astromall/productDetailScreen.dart';

class SearchByNameScreen extends StatelessWidget {
  final int productCategoryId;
  const SearchByNameScreen({Key? key, required this.productCategoryId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
          kIsWeb? Icons.arrow_back:    Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
            color: Get.theme.iconTheme.color,
          ),
        ),
        title: GetBuilder<SearchControllerCustom>(builder: (searchController) {
          return TextField(
            autofocus: true,
            onChanged: (value) async {
              searchController.productSearchText = value;
              if (value.length > 2) {
                global.showOnlyLoaderDialog(context);
                await searchController.getProductSearchResult(
                    productCategoryId, value);
                searchController.update();
                global.hideLoader();
              }
            },
            decoration: InputDecoration(
              hintText: 'Search by Name',
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
          );
        }),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.search,
                color: Get.theme.iconTheme.color,
              ))
        ],
      ),
      body: GetBuilder<SearchControllerCustom>(builder: (searchController) {
        return searchController.astroCategoryProduct.isEmpty &&
                searchController.productSearchText != ""
            ? Center(
                child: Text('Product not available').tr(),
              )
            : ListView.builder(
                itemCount: searchController.astroCategoryProduct.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      AstromallController astromallController =
                          Get.find<AstromallController>();
                      global.showOnlyLoaderDialog(context);
                      await astromallController.getproductById(
                          searchController.astroCategoryProduct[index].id);
                      global.hideLoader();
                      Get.to(() => ProductDetailScreen(
                            index: index,
                          ));
                    },
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      height: 200,
                      padding: EdgeInsets.all(10),
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.4), BlendMode.darken),
                          image: NetworkImage(
                              "${global.imgBaseurl}${searchController.astroCategoryProduct[index].productImage}"),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${searchController.astroCategoryProduct[index].name}",
                            maxLines: 2,
                            textAlign: TextAlign.start,
                            style: Get.textTheme.titleMedium!
                                .copyWith(color: Colors.white, fontSize: 12),
                          ).tr(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)}${searchController.astroCategoryProduct[index].amount} /-',
                                  style: Get.textTheme.titleMedium!.copyWith(
                                      color: Colors.white, fontSize: 11)),
                              SizedBox(
                                height: 28,
                                child: TextButton(
                                    onPressed: () async {
                                      AstromallController astromallController =
                                          Get.find<AstromallController>();
                                      global.showOnlyLoaderDialog(context);
                                      await astromallController.getproductById(
                                          searchController
                                              .astroCategoryProduct[index].id);
                                      global.hideLoader();
                                      Get.to(() => ProductDetailScreen(
                                            index: index,
                                          ));
                                    },
                                    child: Text(
                                      'Buy',
                                      style: Get.textTheme.titleMedium!
                                          .copyWith(
                                              color: Colors.white,
                                              fontSize: 11),
                                    ).tr(),
                                    style: ButtonStyle(
                                      shape: WidgetStateProperty.all(
                                          RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.white),
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      )),
                                    )),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
      }),
    );
  }
}
